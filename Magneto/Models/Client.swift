//
//  Client.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Disco

class Client: Codable, Hashable, Identifiable {
    private(set) var id: String
    var name: String        = ""
    var host: String        = "127.0.0.1"
    var port: Int?          = nil
    var username: String?   = ""
    var password: String?   = ""
    
    var portOrDefault: Int {
        port ?? 9091
    }
    
    init(host: String, name: String) {
        self.id         = UUID().uuidString
        self.host       = host
        self.name       = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case host = "host"
        case port = "port"
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
        comps.path = "/transmission/rpc/"
        return comps.url!
    }
    
    var webURL: URL {
        var comps = baseComponents
        comps.path = "/transmission/web/"
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

extension Array where Element == Client {
    private func sortableString(for element: Element) -> String {
        let position: Int
        switch HostStatusManager.shared.status(for: .init(host: element.host, port: element.portOrDefault)) {
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
