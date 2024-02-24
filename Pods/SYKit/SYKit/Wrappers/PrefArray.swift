//
//  PrefArray.swift
//  SYKit
//
//  Created by syan on 21/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import os
#endif

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
@propertyWrapper
public class PrefArray<T: Codable & Identifiable<String>, V: Comparable>: NSObject {
    
    // MARK: Init
    public init(prefix: String, sortedBy: KeyPath<T, V>, order: Order, local: UserDefaults = .standard, ubiquitous: NSUbiquitousKeyValueStore? = .default, notification: Notification.Name? = nil) {
        self.prefix = prefix
        self.keyPath = sortedBy
        self.order = order
        self.local = local
        self.ubiquitous = ubiquitous
        self.notification = notification
        super.init()

        if let ubiquitous {
            // https://stackoverflow.com/a/13476127/1439489
            ubiquitous.set(Int.random(in: 0..<100), forKey: "random_key_to_start_syncing")
            ubiquitous.synchronize()

            NotificationCenter.default.addObserver(
                self, selector: #selector(self.ubiquitousStoreChanged(notification:)),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: ubiquitous
            )
        }
        
        contentChanged(notifiy: false)
    }

    // MARK: Configuration
    private let prefix: String
    private let keyPath: KeyPath<T, V>
    private let order: Order
    private let local: UserDefaults
    private let ubiquitous: NSUbiquitousKeyValueStore?
    private let notification: Notification.Name?
    
    public enum Order {
        case asc, desc
    }
    
    // MARK: Content
    public private(set) var wrappedValue: [T] = []
    
    private func contentChanged(notifiy: Bool = true) {
        self.wrappedValue = storedElements()
        ubiquitous?.synchronize()
        if notifiy {
            postNotification()
        }
    }
    
    private func storedElements() -> [T] {
        let keys = local.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        
        var elementsData = [(String, Data)]()
        var missingData = [String]()
        
        keys.forEach { key in
            if let data = local.data(forKey: key) {
                elementsData.append((key, data))
            }
            else {
                missingData.append(key)
            }
        }

        if missingData.isNotEmpty {
            log("Missing data for keys: \(missingData)")
        }

        var elements = elementsData.compactMap { (key, data) in
            do {
                return try JSONDecoder().decode(T.self, from: data)
            }
            catch {
                log("Couldn't decode value for key \(key): \(error)")
                return nil
            }
        }
        elements = elements.sorted(by: keyPath)
        if order == .desc {
            elements = Array(elements.reversed())
        }
        return elements
    }

    // MARK: Public methods
    public func insert(_ elements: [T]) {
        elements.forEach { element in
            let key = "\(prefix)\(element.id)"
            do {
                let data = try JSONEncoder().encode(element)
                local.set(data, forKey: key)
                ubiquitous?.set(data, forKey: key)
            }
            catch {
                log("Couldn't encode value for key \(key): \(error)")
            }
        }
        contentChanged()
    }
    
    public func insert(_ element: T) {
        insert([element])
    }
    
    public func remove(ids: [T.ID]) {
        ids.forEach { id in
            let key = "\(prefix)\(id)"
            local.removeObject(forKey: key)
            ubiquitous?.removeObject(forKey: key)
        }
        contentChanged()
    }
    
    public func remove(id: String) {
        remove(ids: [id])
    }
    
    public func remove(_ element: T) {
        remove(id: element.id)
    }
    
    public func remove(_ elements: [T]) {
        remove(ids: elements.map(\.id))
    }

    public func clear() {
        remove(ids: wrappedValue.map(\.id))
    }

    // MARK: Sync
    private func postNotification() {
        guard let notification else { return }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notification, object: nil)
        }
    }

    @objc private func ubiquitousStoreChanged(notification: Notification) {
        guard let ubiquitous else { return }
        guard let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }

        switch reason {
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            log("Over quota")
            
        case NSUbiquitousKeyValueStoreAccountChange:
            log("Account changed")
            
        case NSUbiquitousKeyValueStoreInitialSyncChange, NSUbiquitousKeyValueStoreServerChange:
            guard let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }

            let impactedKeys = keys.filter { $0.hasPrefix(prefix) }
            impactedKeys.forEach { key in
                let value = ubiquitous.object(forKey: key)
                if let data = value as? Data {
                    // added / updated
                    local.setValue(data, forKey: key)
                }
                else if let value {
                    // added / updated, but unknown type
                    log("Received new synced value for key \(key), but it is not a Data type: \(type(of: value))")
                }
                else {
                    // deleted
                    local.removeObject(forKey: key)
                }
            }
            contentChanged()
            
        default:
            log("Unknown sync reason: \(reason)")
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private extension PrefArray {
    func log(_ message: String) {
        let tag = "PrefArray[\(self.prefix)]"
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "SYKit", category: tag)
        os_log(.debug, log: osLog, "%@", message)
        #else
        print("\(tag) \(message)")
        #endif
    }
}
