//
//  PublicKey.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import TweetNacl

public struct PublicKey: Equatable, KeyProtocol, CustomStringConvertible {
    public static let LENGTH: Int = 32
    
    let key: Data

    public init(data: Data) throws {
        guard data.count <= PublicKey.LENGTH else {
            throw AptosError.other("Invalid public key input")
        }
        self.key = data
    }
    
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.key == rhs.key
    }
    
    public var description: String {
        return "0x\(key.hexEncodedString())"
    }
    
    public func verify(data: Data, signature: Signature) throws -> Bool {
        do {
            return try NaclSign.signDetachedVerify(
                message: data,
                sig: signature.data(),
                publicKey: self.key
            )
        } catch {
            return false
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != PublicKey.LENGTH {
            throw NSError(domain: "Length Mismatch", code: -1)
        }
        return try PublicKey(data: key)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        Serializer.toBytes(serializer, self.key)
    }
}
