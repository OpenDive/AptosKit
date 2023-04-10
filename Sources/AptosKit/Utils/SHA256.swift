//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import CommonCrypto
import Foundation

public func sha256(data: Data) -> Data {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash)
}

