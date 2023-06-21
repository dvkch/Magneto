//
//  ClientAPI.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import BrightFutures
import Alamofire

// https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
// https://github.com/transmission/transmission/blob/1.70/doc/rpc-spec.txt
class ClientAPI: NSObject {

    // MARK: Init
    static let shared = ClientAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        super.init()
        session = Alamofire.Session(configuration: configuration, interceptor: self)
    }
    
    // MARK: Properties
    private var session: Session!
    private var pendingAuthentications = [String: [(RetryResult) -> Void]]()
    private var transmissionSessionIDs = [String: String]()
    
    // MARK: Types
    private struct TransmissionResponse: Decodable {
        struct Item : Decodable {
            let id: Int
            let doneDate: Int
            let name: String
        }
        
        let result: String
        let items: [Item]
        
        private enum CodingKeys: String, CodingKey {
            case result = "result", arguments = "arguments"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            result = try container.decode(String.self, forKey: .result)
            
            if let arguments = try? container.decode([String: [Item]].self, forKey: .arguments) {
                items = arguments["torrents"] ?? []
            }
            else {
                items = []
            }
        }
    }

    // MARK: API
    func addMagnet(_ magnetURL: URL, to client: Client) -> Future<String?, AppError> {
        let parameters: Parameters = [
            "method":"torrent-add",
            "arguments": ["filename": magnetURL.absoluteString]
            ]
            
        return session
            .request(client.apiURL, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseFutureCodable(type: TransmissionResponse.self)
            .map { $0.result }
    }
    
    func removeCompletedTorrents(in client: Client) -> Future<Int, AppError> {
        return self
            .listEndedTorrents(for: client)
            .flatMap { ids in self.removeTorrents(ids: ids, from: client) }
    }

    private func listEndedTorrents(for client: Client) -> Future<[Int], AppError> {
        let parameters: Parameters = [
            "method":"torrent-get",
            "arguments": ["fields": ["id", "doneDate", "name"]]
        ]
        
        return session
            .request(client.apiURL, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseFutureCodable(type: TransmissionResponse.self)
            .map { response in response.items.filter { $0.doneDate > 0 }.map { $0.id } }
    }
    
    private func removeTorrents(ids: [Int], from client: Client) -> Future<Int, AppError> {
        guard !ids.isEmpty else { return Future<Int, AppError>(value: 0) }
        
        let parameters: Parameters = [
            "method":"torrent-remove",
            "arguments": [
                "ids": ids,
                "delete-local-data": false
            ] as [String : Any]
        ]
        
        return session
            .request(client.apiURL, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseFutureCodable(type: TransmissionResponse.self)
            .map { _ in ids.count }
    }
}

extension ClientAPI : RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let client = urlRequest.client else { return completion(.success(urlRequest)) }

        var request = urlRequest
        if let u = client.username, let p = client.password, let base64 = "\(u):\(p)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic " + base64, forHTTPHeaderField: "Authorization")
        }
        if let sessionID = transmissionSessionIDs[client.id] {
            request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        }
        completion(.success(request))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let client = request.request?.client, request.retryCount < 5 else {
            completion(.doNotRetry)
            return
        }
        
        if request.response?.statusCode == 409,
            let sessionID = request.response?.allHeaderFields["X-Transmission-Session-Id"] as? String
        {
            transmissionSessionIDs[client.id] = sessionID
            completion(.retryWithDelay(0.1))
            return
        }

        if request.response?.statusCode == 401 {
            if pendingAuthentications.keys.contains(client.id) {
                pendingAuthentications[client.id]?.append(completion)
                return
            }
            
            pendingAuthentications[client.id] = [completion]

            DispatchQueue.main.async {
                ViewRouter.shared.promptAuthenticationUpdate(for: client) { (cancelled) in
                    let completions = self.pendingAuthentications[client.id] ?? []
                    self.pendingAuthentications.removeValue(forKey: client.id)
                    
                    if cancelled {
                        completions.forEach { $0(.doNotRetry) }
                    }
                    else {
                        completions.forEach { $0(.retryWithDelay(0.1)) }
                    }
                }
            }
            return
        }
        
        completion(.doNotRetry)
    }
}

