//
//  SYPreferences.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let clientsChanged = Notification.Name("SYPreferences.clientsChanged")
}

class SYPreferences: NSObject {
    // MARK: Init
    static let shared = SYPreferences()
    
    
    override init() {
        super.init()
        loadClients()
        loadMirrors()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ubiquitousStoreChanged(notification:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackgroundNotification),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    // MARK: Clients
    private static let clientsPrefKey = "clients_ids"
    private(set) var clients: [SYClient] = [] {
        didSet {
            saveClients()
            NotificationCenter.default.post(name: .clientsChanged, object: self)
        }
    }
    
    private func saveClients() {
        do {
            let json = try JSONEncoder().encode(clients)
            UserDefaults.standard.set(json, forKey: SYPreferences.clientsPrefKey)
            NSUbiquitousKeyValueStore.default.set(json, forKey: SYPreferences.clientsPrefKey)
        }
        catch {
            print("Couldn't encode to JSON: \(error)")
        }
    }
    
    private func loadClients() {
        do {
            let jsonUserDefaults = UserDefaults.standard.data(forKey: SYPreferences.clientsPrefKey)
            let jsonUbiquitous = NSUbiquitousKeyValueStore.default.data(forKey: SYPreferences.clientsPrefKey)
            guard let json = jsonUserDefaults ?? jsonUbiquitous else { return }
            let parsed = try JSONDecoder().decode([SYClient].self, from: json)
            clients = parsed
       }
        catch {
            print("Couldn't decode JSON: \(error)")
        }

    }

    // MARK: Mirrors
    private static let savedAvailableMirrorsPrefKey = "available_mirrors"
    var savedAvailableMirrors: [URL] = [] {
        didSet {
            if savedAvailableMirrors != oldValue {
                saveMirrors()
            }
        }
    }
    
    private func saveMirrors() {
        UserDefaults.standard.set(savedAvailableMirrors.map { $0.absoluteString }, forKey: SYPreferences.savedAvailableMirrorsPrefKey)
    }
    
    private func loadMirrors() {
        if let urlStrings = UserDefaults.standard.array(forKey: SYPreferences.savedAvailableMirrorsPrefKey) as? [String] {
            savedAvailableMirrors = urlStrings.compactMap { URL(string: $0) }
        }
    }
    
    // MARK: Ubiquitous KV Store
    @objc private func ubiquitousStoreChanged(notification: Notification) {
        guard let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        switch reason {
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            print("Over quota")
            
        case NSUbiquitousKeyValueStoreAccountChange:
            print("Account changed")
            
        case NSUbiquitousKeyValueStoreInitialSyncChange, NSUbiquitousKeyValueStoreServerChange:
            guard let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
            let store = NSUbiquitousKeyValueStore.default
            for key in keys {
                if key != SYPreferences.clientsPrefKey {
                    print("unsupported key changed", key)
                }
                
                let value = store.object(forKey: key)
                if let value = value {
                    // added / updated
                    UserDefaults.standard.set(value, forKey: key)
                }
                else {
                    // deleted
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            
            loadClients()
            
        default:
            print("Unknown reason:", reason)
        }
    }
    
    // MARK: Public methods
    func clientWithIdentifier(_ identifier: String) -> SYClient? {
        return clients.first { $0.id == identifier }
    }
    
    func addClient(_ client: SYClient) {
        var clients = self.clients.filter { $0.id != client.id }
        clients.append(client)
        self.clients = clients
    }
    
    func removeClient(_ client: SYClient) {
        clients = clients.filter { $0.id != client.id }
    }
    
    // MARK: UIApplication notifications
    @objc private func applicationEnterBackgroundNotification() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
