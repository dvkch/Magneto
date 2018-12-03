//
//  SYClient.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class SYClient : Codable {
    let id: String          = UUID().uuidString
    var name: String?       = nil
    var host: String        = "127.0.0.1"
    var port: Int?          = nil
    var software: Software  = .transmission
    var username: String?   = ""
    var password: String?   = ""
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case host = "host"
        case port = "port"
        case software = "software"
        case username = "username"
        case password = "password"
    }
}

extension SYClient {
    var isValid: Bool {
        if host.isEmpty {
            return false
        }
        if (password ?? "").count > 0 && (username ?? "").isEmpty {
            return false
        }
        if port == nil || port == 0 {
            return false
        }
        return true
    }
}

extension SYClient : CustomStringConvertible {
    var description: String {
        return "SYClient: \(name ?? "<no name>") -> \(host):\(port ?? 0), auth: \(username ?? "<none>")"
    }
}

extension SYClient {
    convenience init(host: String, name: String?) {
        self.init()
        self.host       = host
        self.name       = name
        self.software   = .transmission
    }
    
    private var baseComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port ?? software.defaultPort
        return components
    }
    
    var apiURL: URL {
        var comps = baseComponents
        comps.path = software.apiPath
        return comps.url!
    }
    
    var webURL: URL {
        var comps = baseComponents
        comps.path = software.webPath
        return comps.url!
    }
}

extension SYClient : Equatable {
    static func == (lhs: SYClient, rhs: SYClient) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SYClient {
    enum Software: Int, Codable {
        case transmission = 0, uTorrent = 1
        
        var defaultPort: Int {
            switch self {
            case .transmission: return 9091
            case .uTorrent:     return 18764
            }
        }
        
        var apiPath: String {
            switch self {
            case .transmission: return "/transmission/rpc/"
            case .uTorrent:     return "/gui/"
            }
        }
        
        var webPath: String {
            switch self {
            case .transmission: return "/transmission/web/"
            case .uTorrent:     return "/gui/"
            }
        }
    }
}
