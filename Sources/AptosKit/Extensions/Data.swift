//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import CommonCrypto
import Foundation

public extension Data {
    /// Two octet checksum as defined in RFC-4880. Sum of all octets, mod 65536
    func checksum() -> UInt16 {
        let s = withUnsafeBytes { buf in
            buf.lazy.map(UInt32.init).reduce(UInt32(0), +)
        }
        return UInt16(s % 65535)
    }
}

public extension Data {
    init(hex: String) {
        self.init([UInt8](hex: hex))
    }
    
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        var hexIndex = hexString.startIndex
        for _ in 0..<length {
            let byteString = hexString[hexIndex..<hexString.index(after: hexIndex)]
            hexIndex = hexString.index(after: hexIndex)
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
        }
        self = data
    }
    
    init(fromUInt8Array array: [UInt8]) {
        self.init()
        self.append(contentsOf: array)
    }
    
    var bytes: [UInt8] {
        Array(self)
    }
    
    func toHexString() -> String {
        bytes.toHexString()
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
}
