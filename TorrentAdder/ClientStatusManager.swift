//
//  ClientStatusManager.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

protocol ClientStatusManagerDelegate : NSObjectProtocol {
    func clientStatusManager(_ manager: ClientStatusManager, changedStatusFor client: Client)
}

extension Notification.Name {
    static let clientStatusChanged = Notification.Name("ClientStatusManager.clientStatusChanged")
}

class ClientStatusManager: NSObject {

    // MARK: Init
    static let shared = ClientStatusManager()
    
    override init() {
        super.init()
        
    }
    
    // MARK: Types
    enum ClientStatus {
        case offline, online, unknown
    }
    
    // MARK: Properties
    weak var delegate: ClientStatusManagerDelegate?
    private let urlSession = URLSession(configuration: .ephemeral)
    private var loadingClients: [String] = []
    private var lastStatuses: [String: (Date, ClientStatus)] = [:]

    // MARK: Public methods
    func isClientLoading(_ client: Client?) -> Bool {
        guard let client = client else { return false }
        return loadingClients.contains(client.id)
    }
    
    func lastStatusForClient(_ client: Client?) -> ClientStatus {
        guard let client = client else { return .unknown }
        return lastStatuses[client.id]?.1 ?? .unknown
    }
    
    func startStatusUpdateIfNeeded(for client: Client) {
        let status = lastStatuses[client.id]
        let date = status?.0 ?? Date(timeIntervalSince1970: 0)
        
        // refresh if it's unknown or old
        if status == nil || date.timeIntervalSinceNow < -10 {
            DispatchQueue.main.async {
                self.startStatusUpdate(for: client)
            }
        }
    }
    
    // MARK: Private
    private func startStatusUpdate(for client: Client) {
        if isClientLoading(client) { return }
        
        setClientLoading(client, loading: true)
        
        ClientAPI.shared.getClientStatus(client)
            .onSuccess { (online) in
                self.setStatus(online ? .online : .offline, for: client)
                self.setClientLoading(client, loading: false)
        }
    }
    
    private func setStatus(_ status: ClientStatus, for client: Client) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setStatus(status, for: client)
            }
            return
        }
        
        let prevStatus = lastStatusForClient(client)
        lastStatuses[client.id] = (Date(), status)
        
        if prevStatus != status {
            NotificationCenter.default.post(name: .clientStatusChanged, object: client)
            delegate?.clientStatusManager(self, changedStatusFor: client)
        }
    }

    func setClientLoading(_ client: Client?, loading: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setClientLoading(client, loading: loading)
            }
            return
        }
        
        guard let client = client, loading != isClientLoading(client) else { return }
        
        if loading {
            loadingClients.append(client.id)
        }
        else {
            loadingClients.remove(client.id)
        }
        
        NotificationCenter.default.post(name: .clientStatusChanged, object: client)
        delegate?.clientStatusManager(self, changedStatusFor: client)
    }
}

