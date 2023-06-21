//
//  HostStatusManager.swift
//  Disco
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import Network

#if os(iOS)
import UIKit
#endif

extension Notification.Name {
    public static let hostStatusChanged = Notification.Name("HostStatusManager.hostStatusChanged")
}

public class HostStatusManager: NSObject {

    // MARK: Init
    public static let shared = HostStatusManager()
    
    private override init() {
        super.init()

        #if os(iOS)
        NotificationCenter.default.addObserver(
            self, selector: #selector(stop),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(start),
            name: UIApplication.willEnterForegroundNotification, object: nil
        )
        #endif
    }
    
    // MARK: Types
    public enum HostStatus {
        case offline, online, unknown
    }
    
    public struct Host: Hashable {
        public let host: String
        public let port: Int
        
        public init(host: String, port: Int) {
            self.host = host
            self.port = port
        }
    }
    
    // MARK: Properties
    public var hosts: [Host] = [] {
        didSet {
            observeHosts()
        }
    }
    public var interval: TimeInterval = 5
    private(set) var isRunning: Bool = false
    private var queue = DispatchQueue(label: String(describing: HostStatusManager.self), qos: .utility)
    private var connections: [Host: NWConnection] = [:]
    private var statuses: [Host: HostStatus] = [:]

    // MARK: Public methods
    public func status(for host: Host) -> HostStatus {
        return statuses[host] ?? .unknown
    }
    
    @objc public func start() {
        guard !isRunning else { return }
        isRunning = true
        
        observeHosts()
    }
    
    @objc public func stop() {
        isRunning = false

        connections.forEach { $0.value.cancel() }
        connections = [:]
    }
    
    @objc private func observeHosts() {
        let unobservedHosts = Set(hosts).subtracting(connections.keys)
        
        unobservedHosts.forEach { host in
            let options = NWProtocolTCP.Options()
            options.connectionTimeout = 5

            let connection = NWConnection(
                host: .init(host.host),
                port: .init(rawValue: UInt16(host.port))!,
                using: .init(tls: .none, tcp: options)
            )

            connection.stateUpdateHandler = { (newState) in
                switch(newState) {
                case .ready:
                    self.updateHostStatus(host, status: .online)

                case .waiting:
                    self.updateHostStatus(host, status: .offline)

                case .failed:
                    self.updateHostStatus(host, status: .offline)

                default: break
                }
            }
            connection.start(queue: queue)
            self.connections[host] = connection
        }
    }
    
    private func updateHostStatus(_ host: Host, status: HostStatus) {
        DispatchQueue.main.async {
            self.statuses[host] = status
            self.connections[host]?.stateUpdateHandler = nil
            self.connections[host]?.cancel()
            self.connections.removeValue(forKey: host)
            NotificationCenter.default.post(name: .hostStatusChanged, object: host)

            if self.connections.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.interval) {
                    self.observeHosts()
                }
            }
        }
    }
}
