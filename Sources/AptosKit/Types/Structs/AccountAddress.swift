//
//  AccountAddress.swift
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

/// An enum representing the available authorization key schemes for Aptos Blockchain accounts.
enum AuthKeyScheme {
    /// The ED25519 authorization key scheme value.
    static let ed25519: UInt8 = 0x00

    /// The multi-ED25519 authorization key scheme value.
    static let multiEd25519: UInt8 = 0x01

    /// The authorization key scheme value used to derive an object address from a GUID.
    static let deriveObjectAddressFromGuid: UInt8 = 0xFD

    /// The authorization key scheme value used to derive an object address from a seed.
    static let deriveObjectAddressFromSeed: UInt8 = 0xFE

    /// The authorization key scheme value used to derive a resource account address.
    static let deriveResourceAccountAddress: UInt8 = 0xFF
}

/// The Aptos Blockchain Account Address
public struct AccountAddress: KeyProtocol, Equatable, CustomStringConvertible, Hashable {
    /// The address data itself
    public let address: Data

    /// The length of the data in bytes
    static let length: Int = 32

    public init(address: Data) throws {
        self.address = address

        if address.count != AccountAddress.length {
            throw AptosError.invalidAddressLength
        }
    }

    public var description: String {
        // Convert the address to a hexadecimal string
        let suffix = "\(self.address.hexEncodedString())"

        // Check if the address is special and adjust the suffix accordingly
        var adjustedSuffix: String

        // Check if the address is special and adjust the suffix accordingly
        if self.isSpecial() {
            adjustedSuffix = String(suffix.drop(while: { $0 == "0" })) // Remove leading zeros
            adjustedSuffix = adjustedSuffix.isEmpty ? "0" : adjustedSuffix // Ensure the string is not empty
        } else {
            adjustedSuffix = suffix
        }
        // Prefix the suffix with "0x" and return the result
        return "0x\(adjustedSuffix)"
    }

    /// Returns whether the address is a "special" address. 
    ///
    /// Addresses are considered
    /// special if the first 63 characters of the hex string are zero. In other words,
    /// an address is special if the first 31 bytes are zero and the last byte is
    /// smaller than `0b10000` (16). In other words, special is defined as an address
    /// that matches the following regex: `^0x0{63}[0-9a-f]$`. In short form this means
    /// the addresses in the range from `0x0` to `0xf` (inclusive) are special.
    ///
    /// For more details see the v1 address standard defined as part of AIP-40:
    /// https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-40.md
    /// - Returns: A boolean that represents whether the address meets the criteria above or not.
    public func isSpecial() -> Bool {
        return self.address.dropLast().allSatisfy { $0 == 0 } && self.address.last! < 16
    }

    /// Creates an instance of AccountAddress from a hex string.
    ///
    /// This function allows only the strictest formats defined by AIP-40. In short this
    /// means only the following formats are accepted:
    /// - LONG
    /// - SHORT for special addresses
    ///
    /// Where:
    /// - LONG is defined as 0x + 64 hex characters.
    ///- SHORT for special addresses is 0x0 to 0xf inclusive without padding zeroes.
    ///
    /// This means the following are not accepted:
    /// - SHORT for non-special addresses.
    /// - Any address without a leading 0x.
    ///
    /// Learn more about the different address formats by reading AIP-40:
    /// https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-40.md.
    /// - Parameter address: A hex string representing an account address.
    /// - Returns: An instance of `AccountAddress`.
    /// - Note: This function has strict parsing behavior. For relaxed behavior, please use `from_string_relaxed` function.
    public static func fromStr(_ address: String) throws -> AccountAddress {
        guard address.hasPrefix("0x") else { throw AptosError.notImplemented }
        let out = try AccountAddress.fromStrRelaxed(address)

        if address.count != AccountAddress.length * 2 + 2 {
            if !out.isSpecial() { throw AptosError.notImplemented }
            else {
                if address.count != 3 { throw AptosError.notImplemented }
            }
        }

        if String(address.suffix(from: address.index(address.startIndex, offsetBy: 2))).count != AccountAddress.length * 2 && !out.isSpecial() {
            throw AptosError.notImplemented
        }

        return out
    }

    /// Creates an instance of AccountAddress from a hex string.
    ///
    /// This function allows all formats defined by AIP-40. In short, this means the
    /// following formats are accepted:
    /// - LONG, with or without leading 0x
    /// - SHORT, with or without leading 0x
    ///
    /// Where:
    /// - LONG is 64 hex characters.
    /// - SHORT is 1 to 63 hex characters inclusive.
    /// - Padding zeroes are allowed, e.g., 0x0123 is valid.
    ///
    /// Learn more about the different address formats by reading AIP-40:
    /// https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-40.md.
    /// - Parameter address: A hex string representing an account address.
    /// - Returns: An instance of `AccountAddress`.
    /// - Note: This function has relaxed parsing behavior. For strict behavior, please use
    /// the `from_string` function. Where possible, use `from_string` rather than this function. 
    /// `from_string_relaxed` is only provided for backwards compatibility.
    public static func fromStrRelaxed(_ address: String) throws -> AccountAddress {
        var addr = address

        if address.hasPrefix("0x") {
            addr = String(address.suffix(from: address.index(address.startIndex, offsetBy: 2)))
        }

        guard addr.count >= 1, addr.count <= 64 else { throw AptosError.notImplemented }

        if addr.count < AccountAddress.length * 2 {
            let padding = String(repeating: "0", count: (AccountAddress.length * 2) - addr.count)
            addr = padding + addr
        }

        return try AccountAddress(address: Data.init(hex: addr))
    }

    /// Create an AccountAddress instance from a PublicKey.
    ///
    /// This function creates an AccountAddress instance from a provided PublicKey. The function generates a new address by appending the ED25519 authorization key
    /// scheme value to the byte representation of the provided public key, and then computes the SHA3-256 hash of the resulting byte array. The resulting hash is used to
    /// create a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - key: A PublicKey instance representing the public key to create the AccountAddress instance from.
    ///
    /// - Returns: An AccountAddress instance created from the provided PublicKey.
    ///
    /// - Throws: An error of type AptosError indicating that the provided PublicKey is invalid and cannot be converted to an AccountAddress instance.
    public static func fromKey(_ key: ED25519PublicKey) throws -> AccountAddress {
        var addressBytes = Data(count: key.key.count + 1)
        addressBytes[0..<key.key.count] = key.key[0..<key.key.count]
        addressBytes[key.key.count] = AuthKeyScheme.ed25519
        let result = addressBytes.sha3(.sha256)

        return try AccountAddress(address: result)
    }

    /// Create an AccountAddress instance from a MultiPublicKey.
    ///
    /// This function creates an AccountAddress instance from a provided MultiPublicKey. The function generates a new address by appending the Multi ED25519 authorization key
    /// scheme value to the byte representation of the provided MultiPublicKey, and then computes the SHA3-256 hash of the resulting byte array. The resulting hash is used to create
    /// a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - keys: A MultiPublicKey instance representing the multiple public keys to create the AccountAddress instance from.
    ///
    /// - Returns: An AccountAddress instance created from the provided MultiPublicKey.
    ///
    /// - Throws: An error of type AptosError indicating that the provided MultiPublicKey is invalid and cannot be converted to an AccountAddress instance.
    public static func fromMultiEd25519(keys: MultiED25519PublicKey) throws -> AccountAddress {
        let keysBytes = keys.toBytes()
        var addressBytes = Data(count: keysBytes.count + 1)
        addressBytes[0..<keysBytes.count] = keysBytes[0..<keysBytes.count]
        addressBytes[keysBytes.count] = AuthKeyScheme.multiEd25519
        let result = addressBytes.sha3(.sha256)

        return try AccountAddress(address: result)
    }

    /// Create an AccountAddress instance for a resource account.
    ///
    /// This function creates an AccountAddress instance for a resource account given the creator's address and a seed value. The function generates a new address by concatenating the byte
    /// representation of the creator's address, the provided seed value, and the DERIVE_RESOURCE_ACCOUNT_ADDRESS authorization key scheme value. It then computes the SHA3-256
    /// hash of the resulting byte array to generate a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - creator: An AccountAddress instance representing the address of the account that will create the resource account.
    ///    - seed: A Data value used to create a unique resource account.
    ///
    /// - Returns: An AccountAddress instance representing the newly created resource account.
    ///
    /// - Throws: An error of type AptosError indicating that the provided creator address or seed is invalid and cannot be used to create a resource account.
    public static func forResourceAccount(_ creator: AccountAddress, seed: Data) throws -> AccountAddress {
        var addressBytes = Data(count: creator.address.count + seed.count + 1)
        addressBytes[0..<creator.address.count] = creator.address[0..<creator.address.count]
        addressBytes[creator.address.count..<creator.address.count + seed.count] = seed[0..<seed.count]
        addressBytes[creator.address.count + seed.count] = AuthKeyScheme.deriveResourceAccountAddress
        let result = addressBytes.sha3(.sha256)

        return try AccountAddress(address: result)
    }

    /// Generates an `AccountAddress` for a GUID object.
    ///
    /// This function takes in a creator address and a `creationNum` which it uses to serialize into an array of bytes.
    /// It then appends the creator address and `deriveObjectAddressFromGuid` to this array. It uses this byte array
    /// to compute a SHA-256 hash. This hash is then returned as a new `AccountAddress`.
    ///
    /// - Parameters:
    ///     - creator: The account address of the creator.
    ///     - creationNum: The creation number of the object.
    ///
    /// - Returns: An `AccountAddress` which is generated for a GUID object.
    ///
    /// - Throws: This function throws an error if the process of creating the `AccountAddress` fails.
    ///
    /// Note: This function uses the SHA-256 algorithm for hashing which is a part of the SHA-2 (Secure Hash Algorithm 2) set of cryptographic hash functions.
    /// Hash functions are fundamental to modern cryptography. These functions map binary strings of an arbitrary length to small binary strings of a fixed length.
    public static func forGuidObject(_ creator: AccountAddress, _ creationNum: Int) throws -> AccountAddress {
        let ser = Serializer()
        try Serializer.u64(ser, UInt64(creationNum))

        var addressBytes = Data(count: ser.output().count + creator.address.count + 1)
        addressBytes[0..<ser.output().count] = ser.output()[0..<ser.output().count]
        addressBytes[ser.output().count..<ser.output().count + creator.address.count] = creator.address[0..<creator.address.count]
        addressBytes[ser.output().count + creator.address.count] = AuthKeyScheme.deriveObjectAddressFromGuid
        let result = addressBytes.sha3(.sha256)

        return try AccountAddress(address: result)
    }

    /// Create an AccountAddress instance for a named object.
    ///
    /// This function creates an AccountAddress instance for a named object given the creator's address and a seed value. The function generates a new address by concatenating the byte representation
    /// of the creator's address, the provided seed value, and the DERIVE_OBJECT_ADDRESS_FROM_SEED authorization key scheme value. It then computes the SHA3-256 hash of the resulting byte
    /// array to generate a new AccountAddress instance.
    ///
    /// - Parameters:
    ///    - creator: An AccountAddress instance representing the address of the account that will create the named object.
    ///    - seed: A Data value used to create a unique named object.
    ///
    /// - Returns: An AccountAddress instance representing the newly created named object.
    ///
    /// - Throws: An error of type AptosError indicating that the provided creator address or seed is invalid and cannot be used to create a named object.
    public static func forNamedObject(_ creator: AccountAddress, seed: Data) throws -> AccountAddress {
        var addressBytes = Data(count: creator.address.count + seed.count + 1)
        addressBytes[0..<creator.address.count] = creator.address[0..<creator.address.count]
        addressBytes[creator.address.count..<creator.address.count + seed.count] = seed[0..<seed.count]
        addressBytes[creator.address.count + seed.count] = AuthKeyScheme.deriveObjectAddressFromSeed
        let result = addressBytes.sha3(.sha256)

        return try AccountAddress(address: result)
    }

    /// Generates an AccountAddress for a named token by concatenating the collectionName, the tokenName, and the separator "::"
    /// as a Data and calling the forNamedObject function with the resulting Data as the seed.
    ///
    /// - Parameters:
    ///    - creator: The AccountAddress of the account that creates the token.
    ///    - collectionName: A String that represents the name of the collection to which the token belongs.
    ///    - tokenName: A String that represents the name of the token.
    ///
    /// - Returns: An AccountAddress object that represents the named token.
    ///
    /// - Throws: An error of type AptosError.stringToDataFailure if collectionName, tokenName, or "::" can't be converted into Data.
    public static func forNamedToken(_ creator: AccountAddress, _ collectionName: String, _ tokenName: String) throws -> AccountAddress {
        guard let collectionData = collectionName.data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "\(collectionName)")
        }
        guard let tokenData = tokenName.data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "\(tokenName)")
        }
        guard let seperatorData = "::".data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "::")
        }
        return try AccountAddress.forNamedObject(creator, seed: collectionData + seperatorData + tokenData)
    }

    /// Derive an AccountAddress for a named collection.
    ///
    /// This function takes the creator's AccountAddress and the name of the collection as a String. The collection name is
    /// then converted to data using UTF-8 encoding. The forNamedObject function is called with the creator's address and the
    /// collection name data as the seed. This returns an AccountAddress derived from the creator's address and collection name
    /// seed, which represents the named collection.
    ///
    /// - Parameters:
    ///    - creator: The creator's AccountAddress.
    ///    - collectionName: The name of the collection as a String.
    ///
    /// - Throws: An AptosError object of type stringToDataFailure if the conversion of the collection name string to data
    /// using UTF-8 encoding fails.
    ///
    /// - Returns: An AccountAddress that represents the named collection.
    public static func forNamedCollection(_ creator: AccountAddress, _ collectionName: String) throws -> AccountAddress {
        guard let collectionData = collectionName.data(using: .utf8) else {
            throw AptosError.stringToDataFailure(value: "\(collectionName)")
        }
        return try AccountAddress.forNamedObject(creator, seed: collectionData)
    }

    public static func deserialize(from deserializer: Deserializer) throws -> AccountAddress {
        return try AccountAddress(address: deserializer.fixedBytes(length: AccountAddress.length))
    }

    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.address)
    }
}
