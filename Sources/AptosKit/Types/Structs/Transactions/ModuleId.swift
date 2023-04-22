//
//  ModuleId.swift
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

/// Aptos Blockchain Module ID
public struct ModuleId: KeyProtocol, Equatable {
    /// The sender's address
    public var address: AccountAddress

    /// Move module id is a string representation of Move module.
    public var name: String

    /// Deserialize a ModuleId instance from a string representation.
    ///
    /// This function deserializes the given string representation of a ModuleId instance to a ModuleId object.
    ///
    /// - Parameters:
    ///    - moduleId: A string representation of the ModuleId instance to be deserialized.
    ///
    /// - Returns: A ModuleId instance that has been deserialized from the given string representation.
    ///
    /// - Throws: An AptosError indicating that the given string representation is invalid and cannot be deserialized to a ModuleId instance.
    public static func fromStr(_ moduleId: String) throws -> ModuleId {
        let split = moduleId.components(separatedBy: "::")
        return ModuleId(
            address: try AccountAddress.fromHex(String(split[0])),
            name: String(split[1])
        )
    }

    public static func deserialize(from deserializer: Deserializer) throws -> ModuleId {
        let address = try AccountAddress.deserialize(from: deserializer)
        let name = try Deserializer.string(deserializer)
        return ModuleId(address: address, name: name)
    }

    public func serialize(_ serializer: Serializer) throws {
        try self.address.serialize(serializer)
        try Serializer.str(serializer, self.name)
    }
}
