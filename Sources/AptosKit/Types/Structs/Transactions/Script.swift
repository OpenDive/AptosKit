//
//  Script.swift
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

public struct Script: TransactionProtocol, Equatable {
    /// The code for the script itself
    public var code: Data

    /// The arguments used for the script
    public var args: [ScriptArgument]

    /// The types used within the script
    public var tyArgs: [TypeTag]

    public static func == (lhs: Script, rhs: Script) -> Bool {
        return
            lhs.code == rhs.code &&
            lhs.args == rhs.args &&
            lhs.tyArgs == rhs.tyArgs
    }

    public static func deserialize(from deserializer: Deserializer) throws -> Script {
        let code = try Deserializer.toBytes(deserializer)
        let tyArgs = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        let args = try deserializer.sequence(valueDecoder: ScriptArgument.deserialize)

        return Script(code: code, args: args, tyArgs: tyArgs)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.code)
        try serializer.sequence(self.tyArgs, Serializer._struct)
        try serializer.sequence(self.args, Serializer._struct)
    }
}
