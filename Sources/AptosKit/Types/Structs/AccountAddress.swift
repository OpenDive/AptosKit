//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import TweetNacl

enum AuthKeyScheme {
    static let ed25519: Data = Data([0x00])
    static let multiEd25519: Data = Data([0x01])
    static let deriveObjectAddressFromGuid: Data = Data([0xFD])
    static let deriveObjectAddressFromSeed: Data = Data([0xFE])
    static let deriveResourceAccountAddress: Data = Data([0xFF])
}

public struct AccountAddress: KeyProtocol, Equatable, CustomStringConvertible {
    public let address: Data
    static let length: Int = 32

    public init(address: Data) throws {
        self.address = address

        if address.count != AccountAddress.length {
            throw NSError(domain: "Expected address of length 32", code: -1)
        }
    }

    public func hex() -> String {
        return "0x\(address.hexEncodedString())"
    }
    
    public var description: String {
        return self.hex()
    }

    public static func fromHex(_ address: String) throws -> AccountAddress {
        var addr = address

        if address.hasPrefix("0x") {
            addr = String(address.dropFirst(2))
        }

        if addr.count < AccountAddress.length * 2 {
            let pad = String(repeating: "0", count: AccountAddress.length * 2 - addr.count)
            addr = pad + addr
        }

        guard let data = Data(hexString: addr) else {
            throw NSError(domain: "Invalid hex string", code: -1)
        }

        return try AccountAddress(address: data)
    }

    public static func fromKey(_ key: PublicKey) -> AccountAddress {
        var input = Data()
        input.append(contentsOf: [UInt8](key.key))
        input.append(contentsOf: AuthKeyScheme.ed25519)
        let digest = sha256(data: input)
        return try! AccountAddress(address: digest)
    }
    
//    public static func fromMultiEd25519(keys: )
    
    public static func forResourceAccount(_ creator: AccountAddress, seed: Data) -> AccountAddress {
        var input = Data()
        input.append(contentsOf: creator.address)
        input.append(contentsOf: seed)
        input.append(contentsOf: AuthKeyScheme.deriveResourceAccountAddress)
        let digest = sha256(data: input)
        return try! AccountAddress(address: digest)
    }
    
    public static func forNamedObject(_ creator: AccountAddress, seed: Data) -> AccountAddress {
        var input = Data()
        input.append(contentsOf: creator.address)
        input.append(contentsOf: seed)
        input.append(contentsOf: AuthKeyScheme.deriveObjectAddressFromSeed)
        let digest = sha256(data: input)
        return try! AccountAddress(address: digest)
    }
    
    public static func forNamedToken(_ creator: AccountAddress, _ collectionName: String, _ tokenName: String) throws -> AccountAddress {
        guard let collectionData = collectionName.data(using: .utf8) else {
            throw NSError(domain: "Unable to unwrap collection", code: -1)
        }
        guard let tokenData = tokenName.data(using: .utf8) else {
            throw NSError(domain: "Unable to unwrap token", code: -1)
        }
        guard let seperatorData = "::".data(using: .utf8) else {
            throw NSError(domain: "Unable to unwrap seperator", code: -1)
        }
        return AccountAddress.forNamedObject(creator, seed: collectionData + seperatorData + tokenData)
    }
    
    public static func forNamedCollection(_ creator: AccountAddress, _ collectionName: String) throws -> AccountAddress {
        guard let collectionData = collectionName.data(using: .utf8) else {
            throw NSError(domain: "Unable to unwrap collection", code: -1)
        }
        return AccountAddress.forNamedObject(creator, seed: collectionData)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> AccountAddress {
        return try AccountAddress(address: deserializer.fixedBytes(length: AccountAddress.length))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.address)
    }
}
