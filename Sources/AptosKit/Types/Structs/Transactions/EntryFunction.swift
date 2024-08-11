//
//  EntryFunction.swift
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

/// Aptos Blockchain Entry Function
public struct EntryFunction: TransactionProtocol, Equatable {
    /// The module's ID
    public var module: ModuleId

    /// The function's name
    public var function: String

    /// The type tag arguments
    public var tyArgs: [TypeTag]

    /// The arguments themselves
    public var args: [Data]

    /// Create an EntryFunction instance using the given natural parameters.
    ///
    /// This function creates an EntryFunction instance using the given natural parameters and returns the resulting instance.
    ///
    /// - Parameters:
    ///    - module: A string representation of the ModuleId of the entry function.
    ///    - function: A string representation of the name of the entry function.
    ///    - tyArgs: An array of TypeTag objects representing the type arguments of the entry function.
    ///    - args: An array of AnyTransactionArgument objects representing the arguments of the entry function.
    ///
    /// - Returns: An EntryFunction instance created using the given natural parameters.
    ///
    /// - Throws: An error of type AptosError indicating that the ModuleId instance cannot be created from the given string representation or that an argument cannot be encoded.
    public static func natural(
        _ module: String,
        _ function: String,
        _ tyArgs: [TypeTag],
        _ args: [AnyTransactionArgument]
    ) throws -> EntryFunction {
        let moduleId = try ModuleId.fromStr(module)
        var byteArgs: [Data] = []
        
        for arg in args {
            byteArgs.append(try arg.encode())
        }
        return EntryFunction(
            module: moduleId,
            function: function,
            tyArgs: tyArgs,
            args: byteArgs
        )
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EntryFunction {
        let module = try ModuleId.deserialize(from: deserializer)
        let function = try Deserializer.string(deserializer)
        let tyArgs = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        let args: [Data] = try deserializer.sequence(valueDecoder: Deserializer.toBytes)

        return EntryFunction(module: module, function: function, tyArgs: tyArgs, args: args)
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.module.serialize(serializer)
        try Serializer.str(serializer, self.function)
        try serializer.sequence(self.tyArgs, Serializer._struct)
        try serializer.sequence(self.args, Serializer.toBytes)
    }
}
