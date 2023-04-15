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
import ed25519swift

public struct PrivateKey: Equatable, KeyProtocol, CustomStringConvertible {
    public static let LENGTH: Int = 32
    
    public let key: Data
    
    public init(key: Data) {
        self.key = key
    }
    
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }
    
    public var description: String {
        return self.hex()
    }
    
    public func hex() -> String {
        return "0x" + self.key.hexEncodedString()
    }
    
    public static func fromHex(_ value: String) -> PrivateKey {
        var hexValue = value
        if value.hasPrefix("0x") {
            hexValue = String(value.dropFirst(2))
        }
        let hexData = Data(hex: hexValue)
        return PrivateKey(key: hexData)
    }
    
    public func publicKey() throws -> PublicKey {
        let key = Ed25519.calcPublicKey(secretKey: [UInt8](self.key))
        return try PublicKey(data: Data(key))
    }
    
    public static func random() throws -> PrivateKey {
        let privateKeyArray = Ed25519.generateKeyPair().secretKey
        return PrivateKey(key: Data(privateKeyArray))
    }
    
    public func sign(data: Data) throws -> Signature {
        let signedMessage = Ed25519.sign(message: [UInt8](data), secretKey: [UInt8](self.key))
        return Signature(signature: Data(signedMessage))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PrivateKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != PrivateKey.LENGTH {
            throw NSError(domain: "Length mismatch", code: -1)
        }
        return PrivateKey(key: key)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
