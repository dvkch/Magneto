//
//  SYPreferences.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
// TODO: remove YapDatabase pod

extension NSNotification.Name {
    static let computersChanged = Notification.Name("SYPreferences.computersChanged")
}

class SYPreferences: NSObject {
    // MARK: Init
    static let shared = SYPreferences()
    
    
    override init() {
        super.init()
        loadComputers()
        loadMirrors()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ubiquitousStoreChanged(notification:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackgroundNotification),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    // MARK: Computers
    private static let computersPrefKey = "computers_ids"
    private(set) var computers: [SYClient] = [] {
        didSet {
            saveComputers()
            NotificationCenter.default.post(name: .computersChanged, object: self)
        }
    }
    
    private func saveComputers() {
        do {
            let json = try JSONEncoder().encode(computers)
            UserDefaults.standard.set(json, forKey: SYPreferences.computersPrefKey)
            NSUbiquitousKeyValueStore.default.set(json, forKey: SYPreferences.computersPrefKey)
            print("Saved: \(computers)")
        }
        catch {
            print("Couldn't encode to JSON: \(error)")
        }
    }
    
    private func loadComputers() {
        do {
            let jsonUserDefaults = UserDefaults.standard.data(forKey: SYPreferences.computersPrefKey)
            let jsonUbiquitous = NSUbiquitousKeyValueStore.default.data(forKey: SYPreferences.computersPrefKey)
            guard let json = jsonUserDefaults ?? jsonUbiquitous else { return }
            let parsed = try JSONDecoder().decode([SYClient].self, from: json)
            computers = parsed
            print("Loaded: \(computers)")
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
                if key != SYPreferences.computersPrefKey {
                    print("unknown key changed", key)
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
            
            loadComputers()
            
        default:
            print("Unknown reason:", reason)
        }
    }
    
    // MARK: Public methods
    func computerWithIdentifier(_ identifier: String) -> SYClient? {
        return computers.first { $0.id == identifier }
    }
    
    func addComputer(_ computer: SYClient) {
        var computers = self.computers.filter { $0.id != computer.id }
        computers.append(computer)
        self.computers = computers
    }
    
    func removeComputer(_ computer: SYClient) {
        computers = computers.filter { $0.id != computer.id }
    }
    
    // MARK: UIApplication notifications
    @objc private func applicationEnterBackgroundNotification() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
