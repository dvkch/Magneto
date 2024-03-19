//
//  AppAPI.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

class AppAPI: NSObject {
    
    // MARK: Init
    static let shared = AppAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        // ignore cache for update management
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = Alamofire.Session(configuration: configuration)
        
        super.init()
    }

    // MARK: Properties
    private var session: Session

    // MARK: Update
    
    private struct BundleInfoPlist: Decodable {
        let version: IntMaybeString
        private enum CodingKeys: String, CodingKey {
            case version = "CFBundleVersion"
        }
    }
    func getLatestBuildNumber() -> Future<Int, AppError> {
        return session
            .request(url: "https://ota.syan.me/apps/Magneto.plist")
            .data()
            .flatMap {
                guard let onlinePlist = try? PropertyListDecoder().decode(BundleInfoPlist.self, from: $0) else {
                    return .init(error: .noAvailableAPI)
                }
                return .init(value: onlinePlist.version.value)
            }
    }
}
