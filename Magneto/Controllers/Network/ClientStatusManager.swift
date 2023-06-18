//
//  ClientStatusManager.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit
import Network

extension Notification.Name {
    static let clientStatusChanged = Notification.Name("ClientStatusManager.clientStatusChanged")
}

class ClientStatusManager: NSObject {

    // MARK: Init
    static let shared = ClientStatusManager()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(stop), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(start), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observeClients), name: .clientsChanged, object: nil)
    }
    
    // MARK: Types
    enum ClientStatus {
        case offline, online, unknown
    }
    
    // MARK: Properties
    private(set) var isRunning: Bool = false
    private var queue = DispatchQueue(label: "ClientStatusManager", qos: .utility)
    private var connections: [Client: NWConnection] = [:]
    private var statuses: [Client: ClientStatus] = [:] {
        didSet {
            NotificationCenter.default.post(name: .clientStatusChanged, object: nil)
        }
    }

    // MARK: Public methods
    func statusForClient(_ client: Client) -> ClientStatus {
        return statuses[client] ?? .unknown
    }
    
    @objc func start() {
        guard !isRunning else { return }
        isRunning = true
        
        observeClients()
    }
    
    @objc func stop() {
        isRunning = false

        connections.forEach { $0.value.cancel() }
        connections = [:]
    }
    
    @objc private func observeClients() {
        let unobservedClients = Set(Preferences.shared.clients).subtracting(connections.keys)
        
        unobservedClients.forEach { client in
            let options = NWProtocolTCP.Options()
            options.connectionTimeout = 5

            let connection = NWConnection(
                host: .init(client.host),
                port: .init(rawValue: UInt16(client.portOrDefault))!,
                using: .init(tls: .none, tcp: options)
            )

            connection.stateUpdateHandler = { (newState) in
                switch(newState) {
                case .ready:
                    self.updateClientStatus(client, status: .online)

                case .waiting:
                    self.updateClientStatus(client, status: .offline)

                case .failed:
                    self.updateClientStatus(client, status: .offline)

                default: break
                }
            }
            connection.start(queue: queue)
            self.connections[client] = connection
        }
    }
    
    private func updateClientStatus(_ client: Client, status: ClientStatus) {
        DispatchQueue.main.async {
            self.statuses[client] = status
            self.connections[client]?.stateUpdateHandler = nil
            self.connections[client]?.cancel()
            self.connections.removeValue(forKey: client)
            
            if self.connections.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.observeClients()
                }
            }
        }
    }
}
