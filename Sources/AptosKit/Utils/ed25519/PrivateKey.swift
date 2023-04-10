//
//  PrivateKey.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import TweetNacl

public struct PrivateKey: Equatable, KeyProtocol {
    public static let LENGTH: Int = 32
    
    public let key: Data
    
    public init(key: Data) {
        self.key = key
    }
    
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func description() -> String {
        return self.hex()
    }
    
    public func hex() -> String {
        return "0x" + self.key.toHexString()
    }
    
    public static func fromHex(_ value: String) -> PrivateKey {
        var hexValue = value
        if value.hasPrefix("0x") {
            hexValue = String(value.dropFirst(2))
        }
        guard let hexData = Data(hexString: hexValue) else {
            fatalError("Invalid hex string.")
        }
        return PrivateKey(key: hexData)
    }
    
    public func publicKey() throws -> PublicKey {
        let keys = try NaclSign.KeyPair.keyPair(fromSecretKey: self.key)
        return try PublicKey(data: keys.publicKey)
    }
    
    public static func random() throws -> PrivateKey {
        return PrivateKey(key: try NaclSign.KeyPair.keyPair().secretKey)
    }
    
    public func sign(data: Data) throws -> Signature {
        return try Signature(signature: NaclSign.sign(message: data, secretKey: self.key))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PrivateKey {
        let key = try deserializer.toBytes()
        if key.count != PrivateKey.LENGTH {
            throw NSError(domain: "Length mismatch", code: -1)
        }
        return PrivateKey(key: key)
    }
    
    public func serialize(_ serializer: Serializer) {
        serializer.toBytes(self.key)
    }
}
