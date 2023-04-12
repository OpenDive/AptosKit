//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct RawTransaction: KeyProtocol {
    public var sender: AccountAddress
    public var sequenceNumber: Int
    public var payload: TransactionPayload
    public var maxGasAmount: Int
    public var gasUnitPrice: Int
    public var expirationTimestampSecs: Int
    public var chainId: Int
    
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
            sequenceNumber: Int(try deserializer.u64()),
            payload: try TransactionPayload.deserialize(from: deserializer),
            maxGasAmount: Int(try deserializer.u64()),
            gasUnitPrice: Int(try deserializer.u64()),
            expirationTimestampSecs: Int(try deserializer.u64()),
            chainId: Int(try deserializer.u8())
        )
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.sender.serialize(serializer)
        serializer.u64(UInt64(self.sequenceNumber))
        try self.payload.serialize(serializer)
        serializer.u64(UInt64(self.maxGasAmount))
        serializer.u64(UInt64(self.gasUnitPrice))
        serializer.u64(UInt64(self.expirationTimestampSecs))
        serializer.u8(UInt8(self.chainId))
    }
}
