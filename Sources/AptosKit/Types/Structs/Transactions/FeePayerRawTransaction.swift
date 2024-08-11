//
//  FeePayerRawTransaction.swift
//  AptosKit
//
//  Copyright (c) 2024 OpenDive
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
