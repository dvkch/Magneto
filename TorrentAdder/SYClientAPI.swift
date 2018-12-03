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
    private var pendingAuthentications = [SYComputerModel:[RequestRetryCompletion]]()
    
    // MARK: Online status methods
    func getClientStatus(_ computer: SYComputerModel) -> Future<Bool, NoError> {
        // TODO: implement
        return Future<Bool, NoError>.init(value: false)
    }
    
    // MARK: Magnet methods
    func addMagnet(_ magnetURL: URL, to computer: SYComputerModel) -> Future<String?, SYError> {
        switch computer.client {
        case SYClientSoftware_Transmission:
            return self.addMagnet(magnetURL, toTransmission: computer, sessionID: nil)
        case SYClientSoftware_uTorrent:
            return self
                .getUTorrentToken(computer: computer)
                .flatMap { token in self.addMagnet(magnetURL, toUTorrent: computer, token: token)}
        default: break;
        }
        
        // TODO: remove
        return Future<String?, SYError>.init(error: SYError.noMagnetFound)
    }
    
    // MARK: Private methods

    private struct SYTransmissionResponse: Decodable {
        let result: String
    }

    // https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt
    private func addMagnet(_ magnetURL: URL, toTransmission computer: SYComputerModel, sessionID: String?) -> Future<String?, SYError> {
        let parameters: Parameters = [
            "method":"torrent-add",
            "arguments": ["filename": magnetURL.absoluteString]
            ]
            
        var headers: HTTPHeaders = [:]
        if let sessionID = sessionID {
            headers["X-Transmission-Session-Id"] = sessionID
        }
        
        return manager
            .request(computer.apiURL()!, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding(), headers: headers)
            .validate()
            .responseFutureCodable(type: SYTransmissionResponse.self)
            .map { $0.result }
            .recoverWith { error in
                if error.isTransmissionMissingSessionID, let newSessionID = error.transmissionSessionID {
                    return self.addMagnet(magnetURL, toTransmission: computer, sessionID: newSessionID)
                }
                return Future<String?, SYError>(error: error)
            }
    }
    
    // http://stackoverflow.com/questions/22079581/utorrent-api-add-url-giving-400-invalid-request
    // http://forum.utorrent.com/topic/21814-web-ui-api/#entry207447
    // http://forum.utorrent.com/topic/49588-%C2%B5torrent-webui/
    private func getUTorrentToken(computer: SYComputerModel) -> Future<String, SYError> {
        return manager
            .request(computer.apiURL()!.appendingPathComponent("token.html"))
            .validate()
            .responseFutureHTML()
            .flatMap { html -> BrightResult<String, SYError> in
                if let token = html.firstChild(css: "div#token")?.text {
                    return BrightResult(value: token)
                }
                return BrightResult(error: SYError.noUTorrentToken)
        }
    }
    private func addMagnet(_ magnetURL: URL, toUTorrent computer: SYComputerModel, token: String) -> Future<String?, SYError> {
        return manager
            .request(computer.apiURL()!, parameters: ["token": token, "action": "add-url", "s": magnetURL.absoluteString], encoding: URLEncoding(), headers: nil)
            .validate()
            .responseFutureJSON()
            .map { json in nil }
    }
    
}

extension SYClientAPI : RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let computer = urlRequest.computer, let u = computer.username, let p = computer.password, let base64 = "\(u):\(p)".data(using: .utf8)?.base64EncodedString() {
            var request = urlRequest
            request.addValue("Basic " + base64, forHTTPHeaderField: "Authorization")
            return request
        }
        return urlRequest
    }
}

extension SYClientAPI : RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard let computer = request.request?.computer else {
            completion(false, 0)
            return
        }
        
        if request.response?.statusCode == 401 {
            if pendingAuthentications.keys.contains(computer) {
                pendingAuthentications[computer]?.append(completion)
                return
            }
            
            pendingAuthentications[computer] = [completion]

            DispatchQueue.main.async {
                AppDelegate.obtain.promptAuthenticationUpdate(for: computer) { (cancelled) in
                    let completions = self.pendingAuthentications[computer] ?? []
                    self.pendingAuthentications.removeValue(forKey: computer)
                    
                    if cancelled {
                        completions.forEach { $0(false, 0) }
                    }
                    else {
                        completions.forEach { $0(true, 1) }
                    }
                }
            }
            return
        }
        
        completion(false, 0)
    }
}


private extension SYError {
    var isTransmissionMissingSessionID: Bool {
        if case let .alamofire(afError) = self, afError.response?.statusCode == 409 {
            return true
        }
        return false
    }
    
    var transmissionSessionID: String? {
        if case let .alamofire(afError) = self, let newSessionID = afError.response?.allHeaderFields["X-Transmission-Session-Id"] as? String, !newSessionID.isEmpty {
            return newSessionID
        }
        return nil
    }
}

