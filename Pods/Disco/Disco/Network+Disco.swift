//
//  Network+Disco.swift
//  Disco
//
//  Created by syan on 24/02/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Network

extension IPv4Address {
    public var stringRepresentation: String {
        return debugDescription
    }
    
    public var decimalRepresentation: UInt32 {
        assert(rawValue.count == 4)
        return rawValue.withUnsafeBytes { bytes in
            return bytes.assumingMemoryBound(to: UInt32.self).first!.bigEndian
        }
    }
    
    public init?(decimal: UInt32) {
        var value = decimal.bigEndian
        let data = Data(bytes: &value, count: MemoryLayout<UInt32>.size)
        self.init(data)
    }
    
    public var isValid: Bool {
        let low = (decimalRepresentation >>  0) & 0xFF
        return low > 0 && low < 255
    }
}

extension IPv6Address {
    public var stringRepresentation: String {
        return debugDescription
    }
}

internal extension ifaddrs {
    var address: IPAddress? {
        ifa_addr.address
    }
    
    var netmask: IPAddress? {
        ifa_netmask.address
    }
}

internal extension UnsafeMutablePointer where Pointee == sockaddr {
    var address: IPAddress? {
        if pointee.sa_family == AF_INET {
            return self.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { pointer in
                var addr = pointer.pointee.sin_addr
                var chars = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                inet_ntop(
                    AF_INET,
                    &addr,
                    &chars,
                    socklen_t(INET_ADDRSTRLEN)
                )
                let string = String(cString: chars)
                return IPv4Address(string)
            }
        }
        if pointee.sa_family == AF_INET6 {
            return self.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { pointer in
                var addr = pointer.pointee.sin6_addr
                var chars = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                inet_ntop(
                    AF_INET6,
                    &addr,
                    &chars,
                    socklen_t(INET6_ADDRSTRLEN)
                )
                let string = String(cString: chars)
                return IPv6Address(string)
            }
        }
        return nil
    }
}
