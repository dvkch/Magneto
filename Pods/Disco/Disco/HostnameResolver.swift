//
//  HostnameResolver.swift
//  Disco
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#endif

extension Notification.Name {
    public static let hostnameResolverUpdated = Notification.Name.init("HostnameResolver.updated")
}

/// Used to resolve hostnames from IP addresses
public class HostnameResolver: NSObject {
    
    // MARK: Init
    public static let shared = HostnameResolver()
    private override init() {
        super.init()
        
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self, selector: #selector(start),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        #endif
    }
    
    // MARK: Properties
    public var isRunning: Bool {
        return !browsers.isEmpty
    }
    
    // MARK: Internal properties
    public var servicesTypes = [
        "_smb._tcp", "_afpovertcp._tcp", "_daap._tcp",
        "_home-sharing._tcp", "_rfb._tcp", "_companion-link._tcp",
        "_raop._tcp", "_sleep-proxy._udp", "_http._tcp"
    ] {
        didSet {
            stop()
            start()
        }
    }
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
    public func hostname(for ip: String) -> String? {
        let services = addresses.filter({ $0.value.contains(ip) }).keys
        let names = services.compactMap { $0.hostName?.replacingOccurrences(of: "." + $0.domain, with: "") }
        return names.sorted(by: { $0.count < $1.count }).last
    }
    
    // MARK: Actions
    @objc public func start() {
        browsers = servicesTypes.map { service in
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.searchForServices(ofType: service, inDomain: "")
            return browser
        }
    }
    
    public func stop() {
        browsers.forEach { $0.stop() }
        browsers = []
    }
}

extension HostnameResolver: NetServiceBrowserDelegate {
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        browsers.removeAll(where: { $0 == browser })
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        browsers.removeAll(where: { $0 == browser })
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5)
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.removeAll(where: { $0 == service })
        addresses.removeValue(forKey: service)
    }
}

extension HostnameResolver: NetServiceDelegate {
    public func netServiceDidResolveAddress(_ service: NetService) {
        addresses[service] = service.netAddresses(resolvingHost: false)?.filter { $0.family == .ip4 }.map { $0.ip }
    }

    public func netService(_ service: NetService, didNotResolve errorDict: [String : NSNumber]) {
        services.removeAll(where: { $0 == service })
        addresses.removeValue(forKey: service)
    }
}
