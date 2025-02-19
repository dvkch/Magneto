//
//  Crypto+SY.swift
//  Magneto
//
//  Created by syan on 19/02/2025.
//  Copyright © 2025 Syan. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    var sha1: Data {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> () in
            _ = CC_SHA1(bytes.baseAddress, CC_LONG(self.count), &digest)
        }
        return Data(bytes: digest, count: Int(CC_SHA1_DIGEST_LENGTH))
    }

    var sha256: Data {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> () in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &digest)
        }
        return Data(bytes: digest, count: Int(CC_SHA256_DIGEST_LENGTH))
    }
    
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    var sha1String: String {
        return (data(using: .utf8) ?? Data()).sha1.hexString
    }

    var sha256String: String {
        return (data(using: .utf8) ?? Data()).sha256.hexString
    }
    
    // https://stackoverflow.com/a/52785143/1439489
    func hmac256(key: String) -> Data {
        return hmac256(key: key.data(using: .utf8)!)
    }
    
    func hmac256(key: Data) -> Data {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        defer { result.deallocate() }
        
        key.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> () in
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), bytes.baseAddress, key.count, str!, strLen, result)
        }
        
        return Data(bytes: result, count: digestLen)
    }
}

