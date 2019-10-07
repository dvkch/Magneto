//
//  Pinger.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SPLPing

class Pinger: NSObject {
    
    // MARK: Init
    init(networks: [IPv4Interface]) {
        self.networks = networks
        super.init()
    }
    
    // MARK: Properties
    private let networks: [IPv4Interface]
    private let pingConfig = SPLPingConfiguration(pingInterval: 0.1, timeoutInterval: 1)
    private var totalCount: Int = 0
    private var queuedIPs: [String] = []
    private var runningIPs: [String: PingStats] = [:]
    private var endedIPs: [String: Bool] = [:]
    private var pingers: [SPLPing] = []
    private var isCancelled = false
    
    var progressBlock: ((_ progress: Float) -> Void)?
    var ipFoundBlock: ((_ ip: String) -> Void)?
    var finishedBlock: ((_ finished: Bool) -> Void)?

    // MARK: Public methods
    func start() {
        guard queuedIPs.isEmpty else { return }
        
        queuedIPs = networks
            .map { $0.addressesOnSubnet(ignoringMine: true) }
            .reduce([], +)
            .map { $0.stringRepresentation }
        
        totalCount = queuedIPs.count
        
        executeQueue()
    }
    
    func stop() {
        isCancelled = true
        finishedBlock?(isCancelled)
    }
    
    // MARK: Private
    struct PingStats {
        var failures: Int = 0
        var successes: Int = 0
    }
    
    private func executeQueue() {
        while runningIPs.count < 64 {
            guard !isCancelled && !queuedIPs.isEmpty else { return }
            
            let ip = queuedIPs.removeFirst()
            runningIPs[ip] = PingStats()

            SPLPing.ping(toHost: ip, configuration: pingConfig) { [weak self] (ping, error) in
                if let error = error {
                    self?.runningIPs.removeValue(forKey: ip)
                    self?.endedIPs[ip] = false
                    print("Error creating pinger: ", error)
                }
                if let ping = ping {
                    self?.startPing(ping, ip: ip)
                }
            }
        }
    }
    
    private func startPing(_ ping: SPLPing, ip: String) {
        pingers.append(ping)
        ping.observer = { [weak self] ping, response in
            self?.processResponse(response, ping: ping, ip: ip)
        }
        ping.start()
    }
    
    private func processResponse(_ response: SPLPingResponse, ping: SPLPing, ip: String) {
        if response.error == nil {
            runningIPs[ip]?.successes += 1
        }
        else {
            runningIPs[ip]?.failures += 1
        }
        
        if response.sequenceNumber > 3 {
            ping.stop()
            pingers.remove(ping)
            
            endedIPs[ip] = runningIPs[ip]?.successes ?? 0 > 0
            runningIPs.removeValue(forKey: ip)
            
            executeQueue()
            
            pingFinished(ip)
        }
    }
    
    private func pingFinished(_ ip: String) {
        let success = endedIPs[ip] ?? false
        
        if success {
            ipFoundBlock?(ip)
        }
        
        if endedIPs.count < totalCount {
            progressBlock?(Float(endedIPs.count) / Float(totalCount))
        }
        else {
            finishedBlock?(true)
        }
    }
}
