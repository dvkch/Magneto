//
//  IPInterface.swift
//  Disco
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import Network

public protocol IPInterface <Address>: Equatable, Hashable, CustomStringConvertible {
    
    associatedtype Address: IPAddress & Hashable & CustomDebugStringConvertible
    
    var name: String { get }
    var address: Address { get }
    var netmask: Address { get }
    var flags: UInt32 { get }
}

// MARK: Flags
extension IPInterface {
    public var isRunning: Bool {
        return Int32(flags) & (IFF_UP|IFF_RUNNING) == (IFF_UP|IFF_RUNNING)
    }
    
    public var isLoopback: Bool {
        return Int32(flags) & IFF_LOOPBACK == IFF_LOOPBACK
    }
    
    public var isLocal: Bool {
        return name.hasPrefix("en")
    }
}

extension IPInterface {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address && lhs.netmask == rhs.netmask
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(netmask)
        hasher.combine(name)
    }
}

extension IPInterface {
    public var description: String {
        return "\(String(describing: Self.self)): if=\(name), ip=\(address.debugDescription), msk=\(netmask.debugDescription)"
    }
}
