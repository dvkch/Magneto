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
        loadFromUserDefaults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ubiquitousStoreChanged(notification:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackgroundNotification),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    // MARK: Properties
    private static let computersPrefKey = "computers_ids"
    private static let savedAvailableMirrorsPrefKey = "available_mirrors"
    
    var computers: [SYComputerModel] = [] {
        didSet {
            if computers != oldValue {
                updateUserDefaults()
                updateUbiquitousStore()
                NotificationCenter.default.post(name: .computersChanged, object: self)
            }
        }
    }
    var savedAvailableMirrors: [URL] = [] {
        didSet {
            if savedAvailableMirrors != oldValue {
                updateUserDefaults()
            }
        }
    }
    
    // MARK: Preferences
    private func updateUserDefaults() {
        UserDefaults.standard.set(savedAvailableMirrors, forKey: SYPreferences.savedAvailableMirrorsPrefKey)
        // guard let json = try JSONEncoder().encode(computers) else { return }
        // UserDefaults.standard.set(json, forKey: SYPreferences.computersPrefKey)
    }
    private func loadFromUserDefaults() {
        savedAvailableMirrors = UserDefaults.standard.array(forKey: SYPreferences.savedAvailableMirrorsPrefKey) as? [URL] ?? []
        // guard let json = UserDefaults.standard.data(forKey: SYPreferences.computersPrefKey) else { return }
        // guard let parsed = try? JSONDecoder().decode([SYComputerModel], from: json) else { return }
        // computers = parsed
    }
    
    // MARK: Ubiquitous KV Store
    private func updateUbiquitousStore() {
        // guard let json = try JSONEncoder().encode(computers) else { return }
        // NSUbiquitousKeyValueStore.default.set(json, forKey: SYPreferences.computersPrefKey)
    }
    
    private func loadFromUbiquitousStore() {
        // guard let json = NSUbiquitousKeyValueStore.default.data(forKey: SYPreferences.computersPrefKey) else { return }
        // guard let parsed = try? JSONDecoder().decode([SYComputerModel], from: json) else { return }
        // computers = parsed
    }
    
    @objc private func ubiquitousStoreChanged(notification: Notification) {
        guard let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        switch reason {
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            print("Over quota")
            break
            
        case NSUbiquitousKeyValueStoreAccountChange:
            loadFromUbiquitousStore()
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
            
            loadFromUserDefaults()
        default:
            print("Unknown reason:", reason)
            break
        }
    }
    
    // MARK: Public methods
    func computerWithIdentifier(_ identifier: String) -> SYComputerModel? {
        return computers.first { $0.identifier == identifier }
    }
    
    func addComputer(_ computer: SYComputerModel) {
        var computers = self.computers.filter { $0.identifier != computer.identifier }
        computers.append(computer)
        // TODO: computers.sort()
        self.computers = computers
    }
    
    func removeComputer(_ computer: SYComputerModel) {
        computers = computers.filter { $0.identifier != computer.identifier }
    }
    
    // MARK: UIApplication notifications
    @objc private func applicationEnterBackgroundNotification() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
