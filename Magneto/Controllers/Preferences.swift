//
//  Preferences.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

extension NSNotification.Name {
    static let clientsChanged = Notification.Name("Preferences.clientsChanged")
    static let searchAPIChanged = Notification.Name("Preferences.searchAPI")
}

class Preferences: NSObject {
    // MARK: Init
    static let shared = Preferences()
    private override init() {
        super.init()
    }
    
    // MARK: Clients
    @PrefValue(key: "clients_ids", defaultValue: [], notification: .clientsChanged)
    private(set) var clients: [Client]

    func clientWithIdentifier(_ identifier: String) -> Client? {
        return clients.first { $0.id == identifier }
    }
    
    func addClient(_ client: Client) {
        var clients = self.clients.filter { $0.id != client.id }
        clients.append(client)
        self.clients = clients
    }
    
    func removeClient(_ client: Client) {
        clients = clients.filter { $0.id != client.id }
    }

    // MARK: Suggestions
    @PrefValue(key: "prev_searches", defaultValue: [])
    private(set) var prevSearches: [String]
    
    func addPrevSearch(_ value: String) {
        var prevSearches = self.prevSearches.filter { $0.compare(value, options: [.diacriticInsensitive, .caseInsensitive]) != .orderedSame }
        prevSearches.insert(value, at: 0)
        self.prevSearches = Array(prevSearches.subarray(maxCount: 80))
    }
    
    func prevSearches(matching input: String?) -> [String] {
        let filter = input?.lowercased() ?? ""
        return prevSearches.filter { $0.lowercased().contains(filter) }
    }
    
    func clearPrevSearches() {
        prevSearches = []
    }
    
    // MARK: API
    @PrefValue(key: "search_api", defaultValue: .tpb, notification: .searchAPIChanged)
    var searchAPI: SearchAPIKind
}
