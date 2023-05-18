//
//  Pinger.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import GBPing

protocol PingerDelegate: NSObjectProtocol {
    func pinger(_ pinger: Pinger, progressUpdated progress: Float)
    func pinger(_ pinger: Pinger, found ip: String)
    func pinger(_ pinger: Pinger, stopped completed: Bool)
}

class Pinger: NSObject {
    
    // MARK: Init
    init(networks: [IPv4Interface]) {
        self.networks = networks
        self.queue.name = "Pinger"
        self.queue.maxConcurrentOperationCount = 20
        self.queue.qualityOfService = .utility
        super.init()
    }
    
    // MARK: Properties
    weak var delegate: PingerDelegate?
    private let networks: [IPv4Interface]

    private var totalCount: Int = 0
    private var finishedCount: Int = 0

    private var queue = OperationQueue()
    private var isRunning: Bool = false
    
    // MARK: Public methods
    func start() {
        guard !Thread.isMainThread else {
            DispatchQueue.global(qos: .background).async {
                self.start()
            }
            return
        }
        
        guard !isRunning else { return }
        isRunning = true
        
        let queuedIPs = networks
            .map { $0.addressesOnSubnet(ignoringMine: true) }
            .reduce([], +)
            .map { $0.stringRepresentation }
        
        totalCount = queuedIPs.count
        
        queuedIPs.forEach { ip in
            let operation = PingerOperation(ip: ip) { [weak self] available in
                DispatchQueue.main.async {
                    self?.pingFinished(ip, available: available)
                }
            }
            queue.addOperation(operation)
        }
    }
    
    func stop() {
        queue.cancelAllOperations()
        delegate?.pinger(self, stopped: false)
    }
    
    private func pingFinished(_ ip: String, available: Bool) {
        finishedCount += 1

        if available {
            delegate?.pinger(self, found: ip)
        }
        
        if finishedCount < totalCount {
            delegate?.pinger(self, progressUpdated: Float(finishedCount) / Float(totalCount))
        }
        else {
            isRunning = false
            delegate?.pinger(self, stopped: true)
        }
    }
}

private class PingerOperation: Operation, GBPingDelegate {
    
    init(ip: String, completion: @escaping (_ available: Bool) -> ()) {
        self.ip = ip
        self.completion = completion
        super.init()
    }

    let ip: String
    private let completion: (_ available: Bool) -> ()
    private let ping = GBPing()
    
    private var pingDispatchGroup = DispatchGroup()
    private var stats: (successes: Int, failures: Int) = (0, 0)

    override func main() {
        super.main()
        preparePing()
        runPing()
    }
    
    private func preparePing() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        ping.host = ip
        ping.delegate = self
        ping.pingPeriod = 0.2
        ping.timeout = 1
        ping.setup { success, _ in
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        runPing()
    }
    
    private func runPing() {
        guard ping.isReady else { return }
        
        pingDispatchGroup.enter()
        ping.startPinging()
        pingDispatchGroup.wait()
    }
    
    private func updateStats(success: Bool) {
        guard !Thread.isMainThread else {
            DispatchQueue.global(qos: .background).async {
                self.updateStats(success: success)
            }
            return
        }

        if success {
            stats.successes += 1
        }
        else {
            stats.failures += 1
        }

        if stats.successes + stats.failures == 3 {
            // prevent a crash in which GBPing continues pinging even though it was stopped, and it causes an assert crash
            // because stopping releases a lot of properties necessaries to ping. we're shutting down the loop early and
            // waiting a bit before properly stopping
            ping.setValue(false, forKey: "isPinging")
            usleep(UInt32(ping.pingPeriod * TimeInterval(1_000_000)))

            ping.stop()
            pingDispatchGroup.leave()
            
            completion(stats.successes >= stats.failures)
        }
    }
    
    func ping(_ pinger: GBPing, didReceiveReplyWith summary: GBPingSummary) {
        updateStats(success: true)
    }

    func ping(_ pinger: GBPing, didReceiveUnexpectedReplyWith summary: GBPingSummary) {
        updateStats(success: true)
    }

    func ping(_ pinger: GBPing, didTimeoutWith summary: GBPingSummary) {
        updateStats(success: false)
    }

    func ping(_ pinger: GBPing, didFailWithError error: Error) {
        updateStats(success: false)
    }

    func ping(_ pinger: GBPing, didFailToSendPingWith summary: GBPingSummary, error: Error) {
        updateStats(success: false)
    }
}
