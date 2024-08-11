//
//  MultiAgentRawTransaction.swift
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
import CryptoSwift

/// Aptos Blockchain Multi-Agent Raw Transaction
public struct MultiAgentRawTransaction: RawTransactionWithData {
    /// The raw transaction itself
    public var rawTransaction: RawTransaction

    /// The other parties involved
    public var secondarySigners: [AccountAddress]

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.u8(serializer, UInt8(0))
        try Serializer._struct(serializer, value: self.rawTransaction)
        try serializer.sequence(self.secondarySigners, Serializer._struct)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MultiAgentRawTransaction {
        throw AptosError.notImplemented
    }
}
