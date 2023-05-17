//
//  HostnameResolver.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

extension Notification.Name {
    static let hostnameResolverUpdated = Notification.Name.init("HostnameResolver.updated")
}

/// Used to resolve hostnames from IP addresses
class HostnameResolver: NSObject {
    
    // MARK: Init
    static let shared = HostnameResolver()
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(start),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }
    
    // MARK: Properties
    var isRunning: Bool {
        return browsers.isNotEmpty
    }
    
    // MARK: Internal properties
    private let servicesTypes = ["_smb._tcp", "_afpovertcp._tcp", "_daap._tcp", "_home-sharing._tcp", "_rfb._tcp", "_companion-link._tcp", "_raop._tcp", "_sleep-proxy._udp", "_http._tcp"]
    private var browsers: [NetServiceBrowser] = []
    private var services: [NetService] = []
    private var addresses: [NetService: [String]] = [:] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .hostnameResolverUpdated, object: nil)
            }
        }
    }
    
    // MARK: Access
    func hostname(for ip: String) -> String? {
        let services = addresses.filter({ $0.value.contains(ip) }).keys
        let names = services.compactMap { $0.hostName?.replacingOccurrences(of: "." + $0.domain, with: "") }
        return names.sorted(by: \.count).last
    }
    
    // MARK: Actions
    @objc func start() {
        browsers = servicesTypes.map { service in
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.searchForServices(ofType: service, inDomain: "")
            return browser
        }
    }
    
    func stop() {
        browsers.forEach { $0.stop() }
        browsers = []
    }
}

extension HostnameResolver: NetServiceBrowserDelegate {
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        browsers.remove(browser)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        browsers.remove(browser)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.remove(service)
        addresses.removeValue(forKey: service)
    }
}

extension HostnameResolver: NetServiceDelegate {
    func netServiceDidResolveAddress(_ service: NetService) {
        addresses[service] = service.parsedAddresses?.filter { $0.family == .ip4 }.map { $0.ip }
    }

    func netService(_ service: NetService, didNotResolve errorDict: [String : NSNumber]) {
        services.remove(service)
        addresses.removeValue(forKey: service)
    }
}
