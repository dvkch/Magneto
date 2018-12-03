//
//  SYClientStatusManager.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

protocol SYClientStatusManagerDelegate : NSObjectProtocol {
    func clientStatusManager(_ manager: SYClientStatusManager, changedStatusFor computer: SYClient)
}

extension Notification.Name {
    static let clientStatusChanged = Notification.Name("SYClientStatusManager.clientStatusChanged")
}

class SYClientStatusManager: NSObject {

    // MARK: Init
    static let shared = SYClientStatusManager()
    
    override init() {
        super.init()
        
    }
    
    // MARK: Types
    enum ClientStatus {
        case offline, online, unknown
    }
    
    // MARK: Properties
    weak var delegate: SYClientStatusManagerDelegate?
    private let urlSession = URLSession(configuration: .ephemeral)
    private var loadingComputers: [String] = []
    private var lastStatuses: [String: (Date, ClientStatus)] = [:]

    // MARK: Public methods
    func isComputerLoading(_ computer: SYClient?) -> Bool {
        guard let computer = computer else { return false }
        return loadingComputers.contains(computer.id)
    }
    
    func lastStatusForComputer(_ computer: SYClient?) -> ClientStatus {
        guard let computer = computer else { return .unknown }
        return lastStatuses[computer.id]?.1 ?? .unknown
    }
    
    func startStatusUpdateIfNeeded(for computer: SYClient) {
        let status = lastStatuses[computer.id]
        let date = status?.0 ?? Date(timeIntervalSince1970: 0)
        
        // refresh if it's unknown or old
        if status == nil || date.timeIntervalSinceNow < -10 {
            DispatchQueue.main.async {
                self.startStatusUpdate(for: computer)
            }
        }
    }
    
    // MARK: Private
    private func startStatusUpdate(for computer: SYClient) {
        if isComputerLoading(computer) { return }
        
        setComputerLoading(computer, loading: true)
        
        SYClientAPI.shared.getClientStatus(computer)
            .onSuccess { (online) in
                self.setStatus(online ? .online : .offline, for: computer)
                self.setComputerLoading(computer, loading: false)
        }
    }
    
    private func setStatus(_ status: ClientStatus, for computer: SYClient) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setStatus(status, for: computer)
            }
            return
        }
        
        let prevStatus = lastStatusForComputer(computer)
        lastStatuses[computer.id] = (Date(), status)
        
        if prevStatus != status {
            NotificationCenter.default.post(name: .clientStatusChanged, object: computer)
            delegate?.clientStatusManager(self, changedStatusFor: computer)
        }
    }

    func setComputerLoading(_ computer: SYClient?, loading: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setComputerLoading(computer, loading: loading)
            }
            return
        }
        
        guard let computer = computer, loading != isComputerLoading(computer) else { return }
        
        if loading {
            loadingComputers.append(computer.id)
        }
        else {
            loadingComputers.remove(computer.id)
        }
        
        NotificationCenter.default.post(name: .clientStatusChanged, object: computer)
        delegate?.clientStatusManager(self, changedStatusFor: computer)
    }
}

