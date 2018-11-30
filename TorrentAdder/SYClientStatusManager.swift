//
//  SYClientStatusManager.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

protocol SYClientStatusManagerDelegate : NSObjectProtocol {
    func clientStatusManager(_ manager: SYClientStatusManager, changedStatusFor computer: SYComputerModel)
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
    func isComputerLoading(_ computer: SYComputerModel?) -> Bool {
        guard let computer = computer else { return false }
        return loadingComputers.contains(computer.identifier)
    }
    
    func lastStatusForComputer(_ computer: SYComputerModel?) -> ClientStatus {
        guard let computer = computer else { return .unknown }
        
        let status = lastStatuses[computer.identifier]
        let date = status?.0 ?? Date(timeIntervalSince1970: 0)

        // refresh if it's unknown or old
        if status == nil || date.timeIntervalSinceNow < -10 {
            DispatchQueue.main.async {
                self.startStatusUpdate(for: computer)
            }
        }
        
        return status?.1 ?? .unknown
    }
    
    func startStatusUpdate(for computer: SYComputerModel) {
        if isComputerLoading(computer) { return }
        
        setComputerLoading(computer, loading: true)
        
        guard let url = computer.webURL() else { return }
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 4)
        request.computerID = computer.identifier
        request.isIsUpRequest = true
        
        // TODO: could be better with Alamofire + authentication handler instead of auth URL protocol & custom request type
        
        let task = urlSession.dataTask(with: request as URLRequest) { (data, response, error) in
            self.setStatus(error == nil ? .online : .offline, for: computer)
            self.setComputerLoading(computer, loading: false)
        }
        task.resume()
    }
    
    // MARK: Private
    private func setStatus(_ status: ClientStatus, for computer: SYComputerModel) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setStatus(status, for: computer)
            }
            return
        }
        
        // TODO: clean up
        guard computer.identifier != nil else {
            print("invalid id")
            return
        }
        
        let prevStatus = lastStatusForComputer(computer)
        lastStatuses[computer.identifier] = (Date(), status)
        
        if prevStatus != status {
            NotificationCenter.default.post(name: .clientStatusChanged, object: computer)
            delegate?.clientStatusManager(self, changedStatusFor: computer)
        }
    }

    func setComputerLoading(_ computer: SYComputerModel?, loading: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.setComputerLoading(computer, loading: loading)
            }
            return
        }
        
        guard let computer = computer, loading != isComputerLoading(computer) else { return }
        
        if loading {
            loadingComputers.append(computer.identifier)
        }
        else {
            loadingComputers.remove(computer.identifier)
        }
        
        NotificationCenter.default.post(name: .clientStatusChanged, object: computer)
        delegate?.clientStatusManager(self, changedStatusFor: computer)
    }
}

