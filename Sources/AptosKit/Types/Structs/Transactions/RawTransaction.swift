//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct RawTransaction: KeyProtocol {
    public var sender: AccountAddress
    public var sequenceNumber: UInt64
    public var payload: TransactionPayload
    public var maxGasAmount: UInt64
    public var gasUnitPrice: UInt64
    public var expirationTimestampSecs: UInt64
    public var chainId: UInt8
    
    public func prehash() throws -> Data {
        guard let data = "APTOS::RawTransaction".data(using: .utf8) else {
            throw NSError(domain: "Invalid String", code: -1)
        }
        return sha256(data: data)
    }
    
    public func keyed() throws -> Data {
        let ser = Serializer()
        try self.serialize(ser)
        var prehash = Array(try prehash()).map { Data([$0]) }
        prehash.append(ser.output())
        return prehash.reduce(Data(), { $0 + $1 })
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
        try Serializer.u64(serializer, UInt64(self.sequenceNumber))
        try self.payload.serialize(serializer)
        try Serializer.u64(serializer, UInt64(self.maxGasAmount))
        try Serializer.u64(serializer, UInt64(self.gasUnitPrice))
        try Serializer.u64(serializer, UInt64(self.expirationTimestampSecs))
        try Serializer.u8(serializer, UInt8(self.chainId))
    }
}
