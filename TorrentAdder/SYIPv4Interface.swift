//
//  SYIPv4Interface.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

struct SYIPv4Interface {
    // MARK: Init
    init(address: SYIPv4Address, netmask: SYIPv4Address, name: String?) {
        self.address = address
        self.netmask = netmask
        self.name = name
    }
    
    init?(addressString: String?, netmaskString: String?, name: String?) {
        guard let addressString = addressString, let netmaskString = netmaskString else { return nil }
        guard let address = SYIPv4Address(string: addressString), let netmask = SYIPv4Address(string: netmaskString) else { return nil }
        self.address = address
        self.netmask = netmask
        self.name = name
    }
    
    // MARK: Properties
    let address: SYIPv4Address
    let netmask: SYIPv4Address
    let name: String?
    
    // MARK: IPv4 methods
    func addressesOnSubnet(ignoringMine: Bool) -> [SYIPv4Address] {
        
        let decimalIP   = address.decimalRepresentation
        let decimalMask = netmask.decimalRepresentation
        
        let firstIP =  decimalMask & decimalIP
        let count   = ~decimalMask;

        var IPs = (0..<count)
            .compactMap { SYIPv4Address(decimal: $0 + firstIP) }
            .filter { $0.isValidIP }
        
        if ignoringMine {
            IPs = IPs.filter { $0.decimalRepresentation != decimalIP }
        }
        
        return IPs
    }
}

extension SYIPv4Interface : CustomStringConvertible {
    var description: String {
        return "SYIPv4Interface: if=\(name ?? ""), ip=\(address.stringRepresentation), sub=\(netmask.stringRepresentation)"
    }
}

extension SYIPv4Interface {
    static func deviceNetworks(filterLocalInterfaces: Bool) -> [SYIPv4Interface] {
        
        // Get list of all interfaces on the local machine
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        defer { freeifaddrs(ifaddr) }
        guard let firstAddr = ifaddr else { return [] }
        
        // Iterate over interfaces
        let nativeInterfaces = sequence(first: firstAddr, next: { $0.pointee.ifa_next })
        var interfaces = nativeInterfaces.compactMap { interface -> SYIPv4Interface? in
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            let flags = Int32(interface.pointee.ifa_flags)
            let isRunning = flags & (IFF_UP|IFF_RUNNING) == (IFF_UP|IFF_RUNNING)
            let isLoopback = flags & IFF_LOOPBACK == IFF_LOOPBACK
            
            guard isRunning && !isLoopback else { return nil }
            
            // Converts to usable data type if IPv4, else nil
            guard let addressIN = sockaddr_in_from_sockaddr(interface.pointee.ifa_addr)?.pointee.sin_addr else { return nil }
            guard let netmaskIN = sockaddr_in_from_sockaddr(interface.pointee.ifa_netmask)?.pointee.sin_addr else { return nil }
            
            // Convert interface address to a human readable string:
            let addressString = inet_ntoa(addressIN).map { String(utf8String: $0) } ?? nil
            let netmaskString = inet_ntoa(netmaskIN).map { String(utf8String: $0) } ?? nil
            
            // Retreive name
            let name = String(utf8String: interface.pointee.ifa_name)
            
            return SYIPv4Interface(addressString: addressString, netmaskString: netmaskString, name: name)
        }
        
        if filterLocalInterfaces {
            interfaces = interfaces.filter { $0.name?.hasPrefix("en") == true && $0.netmask.stringRepresentation == "255.255.255.0" }
        }
        
        return interfaces
    }
}

