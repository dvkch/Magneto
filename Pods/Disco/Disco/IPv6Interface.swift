//
//  IPv6Interface.swift
//  Disco
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import Network

public struct IPv6Interface: IPInterface {

    // MARK: Init
    public init(name: String, address: IPv6Address, netmask: IPv6Address, flags: UInt32) {
        self.name = name
        self.address = address
        self.netmask = netmask
        self.flags = flags
    }
    
    // MARK: Properties
    public let name: String
    public let address: IPv6Address
    public let netmask: IPv6Address
    public let flags: UInt32
}

extension IPv6Interface {
    public static func availableInterfaces() -> [IPv6Interface] {
        
        // Get list of all interfaces on the local machine
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        defer { freeifaddrs(ifaddr) }
        guard let firstAddr = ifaddr else { return [] }
        
        // Iterate over interfaces
        let nativeInterfaces = sequence(first: firstAddr, next: { $0.pointee.ifa_next })
        return nativeInterfaces.compactMap { interface -> IPv6Interface? in
            
            // Retreive name
            let name = String(utf8String: interface.pointee.ifa_name) ?? ""
            
            // Find valid addresses
            guard let address = interface.pointee.address as? IPv6Address else { return nil }
            guard let netmask = interface.pointee.netmask as? IPv6Address else { return nil }
            
            return IPv6Interface(
                name: name, address: address, netmask: netmask,
                flags: interface.pointee.ifa_flags
            )
        }
    }
}

