//
//  SYClientAPI.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import BrightFutures
import Alamofire
import Fuzi
import Result

class SYClientAPI: NSObject {

    // MARK: Init
    static let shared = SYClientAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        manager = Alamofire.SessionManager(configuration: configuration)
        super.init()
        manager.adapter = self
        manager.retrier = self
    }
    
    // MARK: Properties
    private let manager: SessionManager
    private var pendingAuthentications = [String: [RequestRetryCompletion]]()
    private var transmissionSessionIDs = [String: String]()
    
    // MARK: Online status methods
    func getClientStatus(_ client: SYClient) -> Future<Bool, NoError> {
        return manager.request(client.apiURL)
            .validate()
            .responseFutureData()
            .map { _ in true }
            .recover { error in
                if case let .alamofire(afError) = error, afError.response != nil {
                    return true
                }
                return false
        }
    }
    
    // MARK: Magnet methods
    func addMagnet(_ magnetURL: URL, to client: SYClient) -> Future<String?, SYError> {
        switch client.software {
        case .transmission:
            return self.addMagnet(magnetURL, toTransmission: client)
        case .uTorrent:
            return self
                .getUTorrentToken(client)
                .flatMap { token in self.addMagnet(magnetURL, toUTorrent: client, token: token)}
        }
    }
    
    // MARK: Private methods

    private struct SYTransmissionResponse: Decodable {
        let result: String
    }

    // https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
    private func addMagnet(_ magnetURL: URL, toTransmission client: SYClient) -> Future<String?, SYError> {
        let parameters: Parameters = [
            "method":"torrent-add",
            "arguments": ["filename": magnetURL.absoluteString]
            ]
            
        return manager
            .request(client.apiURL, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding(), headers: nil)
            .validate()
            .responseFutureCodable(type: SYTransmissionResponse.self)
            .map { $0.result }
    }
    
    // http://stackoverflow.com/questions/22079581/utorrent-api-add-url-giving-400-invalid-request
    // http://forum.utorrent.com/topic/21814-web-ui-api/#entry207447
    // http://forum.utorrent.com/topic/49588-%C2%B5torrent-webui/
    private func getUTorrentToken(_ client: SYClient) -> Future<String, SYError> {
        return manager
            .request(client.apiURL.appendingPathComponent("token.html"))
            .validate()
            .responseFutureHTML()
            .flatMap { html -> BrightResult<String, SYError> in
                if let token = html.firstChild(css: "div#token")?.text {
                    return BrightResult(value: token)
                }
                return BrightResult(error: SYError.noUTorrentToken)
        }
    }
    private func addMagnet(_ magnetURL: URL, toUTorrent client: SYClient, token: String) -> Future<String?, SYError> {
        return manager
            .request(client.apiURL, parameters: ["token": token, "action": "add-url", "s": magnetURL.absoluteString], encoding: URLEncoding(), headers: nil)
            .validate()
            .responseFutureJSON()
            .map { json in nil }
    }
    
}

extension SYClientAPI : RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let client = urlRequest.client else { return urlRequest }
        var request = urlRequest
        if let u = client.username, let p = client.password, let base64 = "\(u):\(p)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic " + base64, forHTTPHeaderField: "Authorization")
        }
        if let sessionID = transmissionSessionIDs[client.id] {
            request.setValue(sessionID, forHTTPHeaderField: "X-Transmission-Session-Id")
        }
        return request
    }
}

extension SYClientAPI : RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let client = request.request?.client, request.retryCount < 5 else {
            completion(false, 0)
            return
        }
        
        if client.software == .transmission, request.response?.statusCode == 409,
            let sessionID = request.response?.allHeaderFields["X-Transmission-Session-Id"] as? String
        {
            transmissionSessionIDs[client.id] = sessionID
            completion(true, 0.1)
            return
        }

        if request.response?.statusCode == 401 {
            if pendingAuthentications.keys.contains(client.id) {
                pendingAuthentications[client.id]?.append(completion)
                return
            }
            
            pendingAuthentications[client.id] = [completion]

            DispatchQueue.main.async {
                AppDelegate.obtain.promptAuthenticationUpdate(for: client) { (cancelled) in
                    let completions = self.pendingAuthentications[client.id] ?? []
                    self.pendingAuthentications.removeValue(forKey: client.id)
                    
                    if cancelled {
                        completions.forEach { $0(false, 0) }
                    }
                    else {
                        completions.forEach { $0(true, 0.1) }
                    }
                }
            }
            return
        }
        
        completion(false, 0)
    }
}

