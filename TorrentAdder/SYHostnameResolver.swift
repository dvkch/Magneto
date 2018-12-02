//
//  SYHostnameResolver.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let hostnameResolverUpdated = Notification.Name.init("SYHostnameResolver.bonjourClientUpdated")
}

/// Used to resolve hostnames from IP addresses
class SYHostnameResolver: NSObject {
    
    // MARK: Init
    static let shared = SYHostnameResolver()
    
    override init() {
        super.init()
    }
    
    // MARK: Properties
    private var isRunning: Bool = false
    private let servicesTypes = ["_smb._tcp", "_afpovertcp._tcp", "_daap._tcp", "_home-sharing._tcp", "_rfb._tcp"]
    private var browsers: [NetServiceBrowser] = []
    private var services: [NetService] = []

    // MARK: Public methods
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        browsers = servicesTypes.map { (type) in
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.searchForServices(ofType: type, inDomain: "local.")
            browser.schedule(in: .main, forMode: .common)
            return browser
        }
    }
    
    func hostnameForIP(_ ip: String) -> String? {
        let names = services
            .filter { $0.addressesStrings.contains(ip) }
            .compactMap { $0.hostName?.replacingOccurrences(of: "." + $0.domain, with: "") }
        
        return names
            .sorted { n1, n2 in n1.count > n2.count }
            .first
    }
    
}

extension SYHostnameResolver: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.remove(service)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .hostnameResolverUpdated, object: nil)
        }
    }
}

extension SYHostnameResolver: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .hostnameResolverUpdated, object: nil)
        }
    }
}
