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
        
        if clients.isEmpty {
            _clients.insert(deprecatedClients)
            deprecatedClients = []
        }
    }
    
    // MARK: Clients
    @PrefValue(key: "clients_ids", defaultValue: [], notification: .clientsChanged)
    private var deprecatedClients: [Client]
    
    @PrefArray(prefix: "clients-", sortedBy: \.id, order: .asc, notification: .clientsChanged)
    var clients: [Client]

    func clientWithIdentifier(_ identifier: String) -> Client? {
        return clients.first { $0.id == identifier }
    }
    
    func addClient(_ client: Client) {
        _clients.insert(client)
    }
    
    func removeClient(_ client: Client) {
        _clients.remove(client)
    }

    // MARK: Suggestions
    @PrefValue(key: "prev_searches", defaultValue: [])
    private var deprecatedPrevSearches: [String]
    
    @PrefArray(prefix: "history-", sortedBy: \.date, order: .desc)
    var history: [HistoryItem]
    
    func addHistory(_ value: String) {
        // remove old elements
        history.dropFirst(80).forEach { oldItem in
            _history.remove(oldItem)
        }
        
        // insert our item
        _history.insert(HistoryItem(search: value))
    }
    
    func prevSearches(matching input: String?) -> [String] {
        let filter = input?.lowercased() ?? ""
        return history.filter { $0.matches(filter) }.map(\.search)
    }
    
    func clearPrevSearches() {
        _history.clear()
    }
    
    // MARK: API
    @PrefValue(key: "search_api", defaultValue: .tpb, notification: .searchAPIChanged)
    var searchAPI: SearchAPIKind
}
