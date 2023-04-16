//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation
import CryptoSwift

public struct RawTransaction: KeyProtocol, Equatable {
    public var sender: AccountAddress
    public var sequenceNumber: UInt64
    public var payload: TransactionPayload
    public var maxGasAmount: UInt64
    public var gasUnitPrice: UInt64
    public var expirationTimestampSecs: UInt64
    public var chainId: UInt8
    
    public static func == (lhs: RawTransaction, rhs: RawTransaction) -> Bool {
        return
            lhs.sender == rhs.sender &&
            lhs.sequenceNumber == rhs.sequenceNumber &&
            lhs.payload == rhs.payload &&
            lhs.maxGasAmount == rhs.maxGasAmount &&
            lhs.gasUnitPrice == rhs.gasUnitPrice &&
            lhs.expirationTimestampSecs == rhs.expirationTimestampSecs &&
            lhs.chainId == rhs.chainId
    }
    
    public func prehash() throws -> Data {
        guard let data = "APTOS::RawTransaction".data(using: .utf8) else {
            throw NSError(domain: "Invalid String", code: -1)
        }
        return data.sha3(.sha256)
    }
    
    public func keyed() throws -> Data {
        let ser = Serializer()
        try self.serialize(ser)
        var prehash = try prehash()
        prehash.append(ser.output())
        return prehash
    }
    
    public func sign(_ key: PrivateKey) throws -> Signature {
        return try key.sign(data: self.keyed())
    }
    
    public func verify(_ key: PublicKey, _ signature: Signature) throws -> Bool {
        return try key.verify(data: self.keyed(), signature: signature)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> RawTransaction {
        return RawTransaction(
            sender: try AccountAddress.deserialize(from: deserializer),
            sequenceNumber: UInt64(try Deserializer.u64(deserializer)),
            payload: try TransactionPayload.deserialize(from: deserializer),
            maxGasAmount: UInt64(try Deserializer.u64(deserializer)),
            gasUnitPrice: UInt64(try Deserializer.u64(deserializer)),
            expirationTimestampSecs: UInt64(try Deserializer.u64(deserializer)),
            chainId: UInt8(try Deserializer.u8(deserializer))
        )
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.sender.serialize(serializer)
        try Serializer.u64(serializer, self.sequenceNumber)
        try self.payload.serialize(serializer)
        try Serializer.u64(serializer, self.maxGasAmount)
        try Serializer.u64(serializer, self.gasUnitPrice)
        try Serializer.u64(serializer, self.expirationTimestampSecs)
        try Serializer.u8(serializer, self.chainId)
    }
}
