//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/20/24.
//

import Foundation

public struct FeePayerRawTransaction: RawTransactionWithData {
    public var rawTransaction: RawTransaction
    public var secondarySigners: [AccountAddress]
    public var feePayer: AccountAddress?

    public init(
        rawTransaction: RawTransaction,
        secondarySigners: [AccountAddress],
        feePayer: AccountAddress?
    ) {
        self.rawTransaction = rawTransaction
        self.secondarySigners = secondarySigners
        self.feePayer = feePayer
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, UInt8(1))
        try Serializer._struct(serializer, value: self.rawTransaction)
        try serializer.sequence(self.secondarySigners, Serializer._struct)
        let feePayer = try self.feePayer ?? AccountAddress.fromStr("0x0")
        try Serializer._struct(serializer, value: feePayer)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> FeePayerRawTransaction {
        throw AptosError.notImplemented
    }
}
