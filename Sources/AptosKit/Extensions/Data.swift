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
    
    var bytes: [UInt8] {
        Array(self)
    }
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
