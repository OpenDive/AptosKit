//
//  SECP256K1PublicKey.swift
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
import secp256k1
import Blake2

public struct SECP256K1PublicKey: Equatable, PublicKeyProtocol {
    /// The length of the key in bytes
    public static let LENGTH: Int = 33

    public var key: Data

    public init(data: Data) throws {
        guard data.count == SECP256K1PublicKey.LENGTH else {
            throw AptosError.invalidPublicKey
        }
        self.key = data
    }

    public init(hexString: String) throws {
        var hexValue = hexString
        if hexString.hasPrefix("0x") {
            hexValue = String(hexString.dropFirst(2))
        }
        guard Data(hex: hexValue).count == SECP256K1PublicKey.LENGTH else {
            throw AptosError.invalidPublicKey
        }
        self.key = Data(hex: hexValue)
    }

    public static func == (lhs: SECP256K1PublicKey, rhs: SECP256K1PublicKey) -> Bool {
        return lhs.key == rhs.key
    }

    public var description: String {
        return "0x\(key.hexEncodedString())"
    }

    public func verify(data: Data, signature: Signature) throws -> Bool {
        guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { throw AptosError.invalidContext }
        let hashedData = data.sha256()
        var signatureEcdsa: secp256k1_ecdsa_signature = secp256k1_ecdsa_signature()
        let serializedSignature = Data(signature.signature[0..<64])
        let resultSignature = serializedSignature.withUnsafeBytes { (rawSignaturePtr: UnsafeRawBufferPointer) -> Int32? in
            if let rawPtr = rawSignaturePtr.baseAddress, rawSignaturePtr.count > 0 {
                let ptr = rawPtr.assumingMemoryBound(to: UInt8.self)
                return withUnsafeMutablePointer(to: &signatureEcdsa) { (mutablePtrEcdsa: UnsafeMutablePointer<secp256k1_ecdsa_signature>) -> Int32? in
                    let res = secp256k1_ecdsa_signature_parse_compact(ctx, mutablePtrEcdsa, ptr)
                    return res
                }
            } else {
                return nil
            }
        }
        guard let _ = resultSignature, resultSignature != 0 else { throw AptosError.invalidParsedSignature }
        var pubKeyObject: secp256k1_pubkey = secp256k1_pubkey()
        let pubKeyResult = self.key.withUnsafeBytes { (rawUnsafePubkeyPtr: UnsafeRawBufferPointer) -> Int32? in
            if let rawPubKey = rawUnsafePubkeyPtr.baseAddress, rawUnsafePubkeyPtr.count > 0 {
                let pubKeyPtr = rawPubKey.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_parse(ctx, &pubKeyObject, pubKeyPtr, self.key.count)
                return res
            } else {
                return nil
            }
        }
        guard let _ = pubKeyResult, pubKeyResult != 0 else { throw AptosError.invalidParsedPublicKey }
        return withUnsafePointer(to: signatureEcdsa) { (signaturePtr: UnsafePointer<secp256k1_ecdsa_signature>) -> Bool in
            return hashedData.withUnsafeBytes { (rawUnsafeDataPtr: UnsafeRawBufferPointer) -> Bool in
                if let dataRawPtr = rawUnsafeDataPtr.baseAddress, rawUnsafeDataPtr.count > 0 {
                    let dataPtr = dataRawPtr.assumingMemoryBound(to: UInt8.self)
                    return withUnsafePointer(to: pubKeyObject) { (pubKeyPtr: UnsafePointer<secp256k1_pubkey>) -> Bool in
                        return secp256k1.secp256k1_ecdsa_verify(ctx, signaturePtr, dataPtr, pubKeyPtr) != 0
                    }
                } else {
                    return false
                }
            }
        }
    }

    public func base64() -> String {
        return key.base64EncodedString()
    }

    public func hex() -> String {
        return "0x\(key.hexEncodedString())"
    }

    public static func deserialize(from deserializer: Deserializer) throws -> SECP256K1PublicKey {
        let key = try Deserializer.toBytes(deserializer)
        if key.count != SECP256K1PublicKey.LENGTH {
            throw AptosError.lengthMismatch
        }
        return try SECP256K1PublicKey(data: key)
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.key)
    }
}
