//
//  EphemeralPublicKey.swift
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
import ed25519swift

public struct EphemeralPublicKey: PublicKeyProtocol {
    public var key: Data

    public var description: String { "\([UInt8](self.key))" }

    public init(data: Data) throws {
        guard data.count <= ED25519PublicKey.LENGTH else {
            throw AptosError.invalidPublicKey
        }
        self.key = data
    }

    public func serialize(_ serializer: Serializer) throws {
        throw AptosError.notImplemented
    }

    public static func deserialize(from deserializer: Deserializer) throws -> EphemeralPublicKey {
        throw AptosError.notImplemented
    }
}
