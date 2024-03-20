//
//  MultiPublicKey.swift
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

/// The ED25519 Multi-Public Key
public struct MultiED25519PublicKey: EncodingProtocol, PublicKeyProtocol, Equatable {
    /// The Public Keys themselves
    public var key: [ED25519PublicKey]

    /// The current amount of keys in the keys array
    public var threshold: Int

    /// The minimum amount of keys to initialize this class
    public static let minKeys: Int = 2

    /// The maximum amount of keys allowed for initialization
    public static let maxKeys: Int = 32

    /// The minimum threshold amount
    public static let minThreshold: Int = 1

    public init(keys: [ED25519PublicKey], threshold: Int, checked: Bool = true) throws {
        if checked {
            if MultiED25519PublicKey.minKeys > keys.count || MultiED25519PublicKey.maxKeys < keys.count {
                throw AptosError.keysCountOutOfRange(min: MultiED25519PublicKey.minKeys, max: MultiED25519PublicKey.maxKeys)
            }
            if MultiED25519PublicKey.minThreshold > threshold || threshold > keys.count {
                throw AptosError.thresholdOutOfRange(min: MultiED25519PublicKey.minThreshold, max: keys.count)
            }
        }

        self.key = keys
        self.threshold = threshold
    }

    public var description: String {
        return "\(self.threshold)-of-\(self.key.count) Multi-Ed25519 public key"
    }

    public func verify(data: Data, signature: MultiSignature) throws -> Bool {
        // Step 1: Ensure that the bitmap matches the expected number of signers based on the threshold
        let signerCount = self.key.count
        let bitmap = UInt32(bigEndian: signature.bitmap.withUnsafeBytes { $0.load(as: UInt32.self) })
        var validSignaturesCount = 0

        for index in 0..<signerCount {
            // If the bit at the index's position is set, it indicates the presence of a signature
            if bitmap & (1 << (31 - index)) != 0 {
                // Try to verify the signature at this index
                let publicKey = self.key[index]
                let individualSignature = signature.signatures[validSignaturesCount]
                
                if try publicKey.verify(data: data, signature: individualSignature) {
                    validSignaturesCount += 1
                } else {
                    // If any signature fails to verify, the entire verification fails
                    return false
                }
            }
        }

        // Check if the number of valid signatures meets or exceeds the threshold
        if validSignaturesCount >= self.threshold {
            return true
        } else {
            return false
        }
    }

    /// Serialize the threshold and concatenated keys of a given threshold signature scheme instance to a Data object.
    ///
    /// This function concatenates the keys of the instance and serializes the threshold and concatenated keys to a Data object.
    ///
    /// - Returns: A Data object containing the serialized threshold and concatenated keys.
    public func toBytes() -> Data {
        var concatenatedKeys: Data = Data()
        for key in self.key {
            concatenatedKeys += key.key
        }
        return concatenatedKeys + Data([UInt8(self.threshold)])
    }

    /// Deserialize a Data object to a MultiPublicKey instance.
    ///
    /// This function deserializes the given Data object to a MultiPublicKey instance by extracting the threshold and keys from it.
    ///
    /// - Parameters:
    ///    - key: A Data object containing the serialized threshold and keys of a MultiPublicKey instance.
    ///
    /// - Returns: A MultiPublicKey instance initialized with the deserialized keys and threshold.
    ///
    /// - Throws: An AptosError object indicating that the given Data object is invalid or cannot be deserialized to a MultiPublicKey instance.
    public static func fromBytes(_ key: Data) throws -> MultiED25519PublicKey {
        let minKeys = MultiED25519PublicKey.minKeys
        let maxKeys = MultiED25519PublicKey.maxKeys
        let minThreshold = MultiED25519PublicKey.minThreshold

        let nSigners = Int(key.count / ED25519PublicKey.LENGTH)

        if minKeys > nSigners || nSigners > maxKeys {
            throw AptosError.keysCountOutOfRange(min: minKeys, max: maxKeys)
        }

        guard let keyThreshold = key.last else {
            throw AptosError.noContentInKey
        }

        let threshold = Int(keyThreshold)

        if minThreshold > threshold || threshold > nSigners {
            throw AptosError.thresholdOutOfRange(min: minThreshold, max: nSigners)
        }

        var keys: [ED25519PublicKey] = []

        for i in 0..<nSigners {
            let startByte = i * ED25519PublicKey.LENGTH
            let endByte = (i + 1) * ED25519PublicKey.LENGTH
            keys.append(try ED25519PublicKey(data: Data(key[startByte..<endByte])))
        }

        return try MultiED25519PublicKey(keys: keys, threshold: threshold)
    }

    /// Serializes an output instance using the given Serializer.
    ///
    /// - Parameter serializer: The Serializer instance used to serialize the data.
    ///
    /// - Throws: An error if the serialization fails.
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.toBytes())
    }

    public static func deserialize(from deserializer: Deserializer) throws -> MultiED25519PublicKey {
        throw AptosError.notImplemented
    }
}
