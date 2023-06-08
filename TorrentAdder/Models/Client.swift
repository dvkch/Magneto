//
//  Client.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class Client: Codable, Hashable {
    private(set) var id: String
    var name: String        = ""
    var host: String        = "127.0.0.1"
    var port: Int?          = nil
    var software: Software  = .transmission
    var username: String?   = ""
    var password: String?   = ""
    
    var portOrDefault: Int {
        port ?? software.defaultPort
    }
    
    init(host: String, name: String) {
        self.id         = UUID().uuidString
        self.host       = host
        self.name       = name
        self.software   = .transmission
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case host = "host"
        case port = "port"
        case software = "software"
        case username = "username"
        case password = "password"
    }
    
    static func ==(lhs: Client, rhs: Client) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func copy(keepID: Bool) -> Self {
        let data = try! JSONEncoder().encode(self)
        let copy = try! JSONDecoder().decode(Self.self, from: data)
        if !keepID {
            copy.id = UUID().uuidString
        }
        return copy
    }
}

extension Client : CustomStringConvertible {
    var description: String {
        return "Client: \(name) -> \(host):\(port ?? 0), auth: \(username ?? "<none>")"
    }
}

extension Client {
    private var baseComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = portOrDefault
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
    
    var webURLWithAuth: URL {
        guard let username = username?.nilIfEmpty, let password = password?.nilIfEmpty else { return webURL }

        var components = URLComponents(url: webURL, resolvingAgainstBaseURL: true)!
        components.user = username
        components.password = password
        return components.url!
    }
}

extension Client {
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

extension Array where Element == Client {
    private func sortableString(for element: Element) -> String {
        let position: Int
        switch ClientStatusManager.shared.statusForClient(element) {
        case .online:  position = 0
        case .unknown: position = 1
        case .offline: position = 2
        }
        return "\(position)-\(element.name.uppercased())"
    }
    
    var sortedByAvailability: [Element] {
        return sorted { client1, client2 in
            sortableString(for: client1) < sortableString(for: client2)
        }
    }
}
