//
//  HostFinder.swift
//  Disco
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import SwiftyPing
import Network

public protocol HostsFinderDelegate: NSObjectProtocol {
    func hostsFinder(_ hostsFinder: HostsFinder, progressUpdated progress: Float)
    func hostsFinder(_ hostsFinder: HostsFinder, found ip: IPv4Address)
    func hostsFinder(_ hostsFinder: HostsFinder, stopped completed: Bool)
}

public class HostsFinder: NSObject {
    
    // MARK: Init
    public init(interfaces: [IPv4Interface]) {
        self.interfaces = interfaces
        self.queue.name = String(describing: HostsFinder.self)
        self.queue.maxConcurrentOperationCount = 20
        self.queue.qualityOfService = .utility
        super.init()
    }
    
    // MARK: Properties
    public weak var delegate: HostsFinderDelegate?
    private let interfaces: [IPv4Interface]

    private var totalCount: Int = 0
    private var finishedCount: Int = 0

    private let queue = OperationQueue()
    public var isRunning: Bool = false
    
    // MARK: Public methods
    public func start() {
        guard !Thread.isMainThread else {
            DispatchQueue.global(qos: .background).async {
                self.start()
            }
            return
        }
        
        guard !isRunning else { return }
        isRunning = true
        
        let queuedIPs = interfaces
            .map { $0.addressesOnSubnet(ignoringMine: true) }
            .reduce([], +)
        
        totalCount = queuedIPs.count
        
        queuedIPs.forEach { ip in
            let operation = PingOperation(host: ip) { [weak self] available in
                DispatchQueue.main.async {
                    self?.pingFinished(ip, available: available)
                }
            }
            queue.addOperation(operation)
        }
    }
    
    public func stop() {
        DispatchQueue.global(qos: .background).async {
            // it can be slow to cancel all operations
            self.queue.cancelAllOperations()

            DispatchQueue.main.async {
                self.delegate?.hostsFinder(self, stopped: false)
                self.isRunning = false
            }
        }
    }
    
    private func pingFinished(_ ip: IPv4Address, available: Bool) {
        finishedCount += 1

        if available {
            delegate?.hostsFinder(self, found: ip)
        }
        
        if finishedCount < totalCount {
            delegate?.hostsFinder(self, progressUpdated: Float(finishedCount) / Float(totalCount))
        }
        else {
            stop()
        }
    }
}

private class PingOperation: Operation {
    
    init(host: IPv4Address, completion: @escaping (_ available: Bool) -> ()) {
        self.host = host
        self.completion = completion
        super.init()
    }

    fileprivate let host: IPv4Address
    static var queue = DispatchQueue.global(qos: .utility)
    private let completion: (_ available: Bool) -> ()

    override func main() {
        super.main()

        guard let pinger = try? SwiftyPing(
            ipv4Address: host.stringRepresentation,
            config: .init(interval: 0.2, with: 1),
            queue: PingOperation.queue
        ) else {
            completion(false)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var stats: (successes: Int, failures: Int) = (0, 0)

        pinger.targetCount = 3
        pinger.observer = { (response) in
            if response.error == nil {
                stats.successes += 1
            }
            else {
                stats.failures += 1
            }
            if stats.successes + stats.failures == 3 {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        DispatchQueue.main.async {
            do {
                try pinger.startPinging()
            }
            catch {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()

        // no need to use haltPinging() since it will stop by itself
        // after 3 pings. it even cause crashes to do it manually.
        // let's still stop the observer
        pinger.observer = nil

        if !isCancelled {
            completion(stats.successes > stats.failures)
        }
    }
}
