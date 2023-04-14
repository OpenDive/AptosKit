//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation
import CryptoSwift

enum AuthKeyScheme {
    static let ed25519: UInt8 = 0x00
    static let multiEd25519: UInt8 = 0x01
    static let deriveObjectAddressFromGuid: Data = Data([0xFD])
    static let deriveObjectAddressFromSeed: UInt8 = 0xFE
    static let deriveResourceAccountAddress: UInt8 = 0xFF
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

        return try AccountAddress(address: Data(hex: addr))
    }

    public static func fromKey(_ key: PublicKey) throws -> AccountAddress {
        var addressBytes = Data(count: key.key.count + 1)
        addressBytes[0..<key.key.count] = key.key[0..<key.key.count]
        addressBytes[key.key.count] = AuthKeyScheme.ed25519
        let result = addressBytes.sha3(.sha256)
        
        return try AccountAddress(address: result)
    }
    
    public static func fromMultiEd25519(keys: MultiPublicKey) throws -> AccountAddress {
        let keysBytes = keys.toBytes()
        var addressBytes = Data(count: keysBytes.count + 1)
        addressBytes[0..<keysBytes.count] = keysBytes[0..<keysBytes.count]
        addressBytes[keysBytes.count] = AuthKeyScheme.multiEd25519
        let result = addressBytes.sha3(.sha256)
        
        return try AccountAddress(address: result)
    }
    
    public static func forResourceAccount(_ creator: AccountAddress, seed: Data) throws -> AccountAddress {
        var addressBytes = Data(count: creator.address.count + seed.count + 1)
        addressBytes[0..<creator.address.count] = creator.address[0..<creator.address.count]
        addressBytes[creator.address.count..<creator.address.count + seed.count] = seed[0..<seed.count]
        addressBytes[creator.address.count + seed.count] = AuthKeyScheme.deriveResourceAccountAddress
        let result = addressBytes.sha3(.sha256)
        
        return try AccountAddress(address: result)
    }
    
    public static func forNamedObject(_ creator: AccountAddress, seed: Data) throws -> AccountAddress {
        var addressBytes = Data(count: creator.address.count + seed.count + 1)
        addressBytes[0..<creator.address.count] = creator.address[0..<creator.address.count]
        addressBytes[creator.address.count..<creator.address.count + seed.count] = seed[0..<seed.count]
        addressBytes[creator.address.count + seed.count] = AuthKeyScheme.deriveObjectAddressFromSeed
        let result = addressBytes.sha3(.sha256)
        
        return try AccountAddress(address: result)
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
        return try AccountAddress.forNamedObject(creator, seed: collectionData + seperatorData + tokenData)
    }
    
    public static func forNamedCollection(_ creator: AccountAddress, _ collectionName: String) throws -> AccountAddress {
        guard let collectionData = collectionName.data(using: .utf8) else {
            throw NSError(domain: "Unable to unwrap collection", code: -1)
        }
        return try AccountAddress.forNamedObject(creator, seed: collectionData)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> AccountAddress {
        return try AccountAddress(address: deserializer.fixedBytes(length: AccountAddress.length))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.address)
    }
}
