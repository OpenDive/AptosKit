//
//  PublicKey.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import TweetNacl

public struct PublicKey: Equatable, KeyProtocol {
    public static let LENGTH: Int = 32
    
    let key: [UInt8]
    
    public init(string: String?) throws {
        guard let string = string, string.utf8.count >= PublicKey.LENGTH
        else {
            throw AptosError.other("Invalid public key input")
        }
        let bytes = Base58.decode(string)
        self.key = bytes
    }

    public init(data: Data) throws {
        guard data.count <= PublicKey.LENGTH else {
            throw AptosError.other("Invalid public key input")
        }
        self.key = [UInt8](data)
    }

    public init(bytes: [UInt8]?) throws {
        guard let bytes = bytes, bytes.count <= PublicKey.LENGTH else {
            throw AptosError.other("Invalid public key input")
        }
        self.key = bytes
    }
    
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func verify(data: Data, signature: Signature) throws -> Bool {
        do {
            return try NaclSign.signDetachedVerify(
                message: data,
                sig: signature.data(),
                publicKey: Data(fromUInt8Array: self.key)
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
    
    public func serialize(_ serializer: Serializer) {
        Serializer.toBytes(serializer, Data(fromUInt8Array: self.key))
    }
}
