//
//  Preferences.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

extension NSNotification.Name {
    static let clientsChanged = Notification.Name("Preferences.clientsChanged")
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

    // MARK: Mirrors
    @PrefValue(key: "available_mirrors", defaultValue: [])
    var savedAvailableMirrors: [URL]
    
    // MARK: Mirrors blacklist
    @PrefValue(key: "mirrors_blacklist", defaultValue: [])
    var mirrorBlacklist: [URL]
    
    // MARK: Suggestions
    @PrefValue(key: "prev_searches", defaultValue: [])
    private(set) var prevSearches: [String]
    
    func addPrevSearch(_ value: String) {
        var prevSearches = self.prevSearches.filter { $0.compare(value, options: [.diacriticInsensitive, .caseInsensitive]) != .orderedSame }
        prevSearches.insert(value, at: 0)
        self.prevSearches = Array(prevSearches.subarray(maxCount: 80))
    }
    
    func clearPrevSearches() {
        prevSearches = []
    }
}
