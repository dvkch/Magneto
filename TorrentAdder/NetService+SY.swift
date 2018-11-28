//
//  NetService+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension NetService {
    var addressesStrings: [String] {
        let addresses = self.addresses ?? []
        return addresses.compactMap { $0.parseIPAddress() }
    }
}

private extension NSData {
    func castToCPointer<T>() -> T {
        let mem = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
        self.getBytes(mem, length: MemoryLayout<T.Type>.size)
        return mem.move()
    }

}
private extension Data {
    func parseIPAddress() -> String? {
        let data = self as NSData
        
        let inetAddress: sockaddr_in = data.castToCPointer()
        if inetAddress.sin_family == __uint8_t(AF_INET) {
            if let ip = String(cString: inet_ntoa(inetAddress.sin_addr), encoding: .ascii) {
                return ip
            }
        }
        else if inetAddress.sin_family == __uint8_t(AF_INET6) {
            let inetAddress6: sockaddr_in6 = data.castToCPointer()
            var addr = inetAddress6.sin6_addr
            let ipStringBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
            defer { ipStringBuffer.deallocate() }

            if let ipString = inet_ntop(Int32(inetAddress6.sin6_family), &addr, ipStringBuffer, __uint32_t(INET6_ADDRSTRLEN)) {
                if let ip = String(cString: ipString, encoding: .ascii) {
                    return ip
                }
            }
        }
        
        return nil
    }
}
