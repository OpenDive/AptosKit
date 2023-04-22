//
//  TransactionPayload.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

/// Aptos Blockchain Transaction Payload
public struct TransactionPayload: KeyProtocol, Equatable {
    /// Script Payload
    public static let script: Int = 0

    /// Module Bundle Payload
    public static let moduleBundle: Int = 1

    /// Script Function Payload
    public static let scriptFunction: Int = 2

    /// The Type Tag Variant
    let variant: Int

    /// The value itself
    let value: any TransactionProtocol

    public init(payload: any TransactionProtocol) throws {
        if payload is Script {
            self.variant = TransactionPayload.script
        } else if payload is ModuleBundle {
            self.variant = TransactionPayload.moduleBundle
        } else if payload is EntryFunction {
            self.variant = TransactionPayload.scriptFunction
        } else {
            throw AptosError.invalidTransactionType
        }
        
        self.value = payload
    }

    public static func == (lhs: TransactionPayload, rhs: TransactionPayload) -> Bool {
        if lhs.value is Script && rhs.value is Script {
            let lhsValue = lhs.value as! Script
            let rhsValue = rhs.value as! Script

            return
                lhs.variant == rhs.variant &&
                lhsValue == rhsValue
        } else if lhs.value is ModuleBundle && rhs.value is ModuleBundle {
            return false
        } else if lhs.value is EntryFunction && rhs.value is EntryFunction {
            let lhsValue = lhs.value as! EntryFunction
            let rhsValue = rhs.value as! EntryFunction

            return
                lhs.variant == rhs.variant &&
                lhsValue == rhsValue
        } else {
            return false
        }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> TransactionPayload {
        let variant = try deserializer.uleb128()
        var payload: any TransactionProtocol
        if variant == TransactionPayload.script {
            payload = try Script.deserialize(from: deserializer)
        } else if variant == TransactionPayload.moduleBundle {
            payload = try ModuleBundle.deserialize(from: deserializer)
        } else if variant == TransactionPayload.scriptFunction {
            payload = try EntryFunction.deserialize(from: deserializer)
        } else {
            throw AptosError.notImplemented
        }

        return try TransactionPayload(payload: payload)
    }

    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.variant))
        try self.value.serialize(serializer)
    }
}
