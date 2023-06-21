//
//  IPv4Interface.swift
//  Disco
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import Network

public struct IPv4Interface: IPInterface {

    // MARK: Init
    public init(name: String, address: IPv4Address, netmask: IPv4Address, flags: UInt32) {
        self.name = name
        self.address = address
        self.netmask = netmask
        self.flags = flags
    }
    
    // MARK: Properties
    public let name: String
    public let address: IPv4Address
    public let netmask: IPv4Address
    public let flags: UInt32
    
    // MARK: IPv4 methods
    public func addressesOnSubnet(ignoringMine: Bool) -> [IPv4Address] {
        
        let decimalIP   = address.decimalRepresentation
        let decimalMask = netmask.decimalRepresentation
        
        let firstIP =  decimalMask & decimalIP
        let count   = ~decimalMask;
        
        var IPs = (0..<count)
            .compactMap { IPv4Address(decimal: $0 + firstIP) }
            .filter { $0.isValid }
        
        if ignoringMine {
            IPs = IPs.filter { $0.decimalRepresentation != decimalIP }
        }
        
        return IPs
    }
}

extension IPv4Interface {
    public static func availableInterfaces() -> [IPv4Interface] {
        
        // Get list of all interfaces on the local machine
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        defer { freeifaddrs(ifaddr) }
        guard let firstAddr = ifaddr else { return [] }
        
        // Iterate over interfaces
        let nativeInterfaces = sequence(first: firstAddr, next: { $0.pointee.ifa_next })
        return nativeInterfaces.compactMap { interface -> IPv4Interface? in
            
            // Retreive name
            let name = String(utf8String: interface.pointee.ifa_name) ?? ""
            
            // Find valid addresses
            guard let address = interface.pointee.address as? IPv4Address else { return nil }
            guard let netmask = interface.pointee.netmask as? IPv4Address else { return nil }
            
            return IPv4Interface(
                name: name, address: address, netmask: netmask,
                flags: interface.pointee.ifa_flags
            )
        }
    }
}
