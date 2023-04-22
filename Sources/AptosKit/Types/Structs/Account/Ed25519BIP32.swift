//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/21/23.
//

import Foundation
import CryptoSwift

public struct Ed25519BIP32 {
    private static let curve: String = "ed25519 seed"
    private let hardendedOffset: UInt = 0x80000000
    private var _masterKey: Data
    private var _chainCode: Data
    
    public init(seed: Data) {
        (_masterKey, _chainCode) = Ed25519BIP32.getMasterKeyFromSeed(seed)
    }
    
    private static func getMasterKeyFromSeed(_ seed: Data) -> (key: Data, chainCode: Data) {
        return hmacSha512(Ed25519BIP32.curve.data(using: .utf8)!, seed)
    }
    
    private static func getChildKeyDerivation(key: Data, chainCode: Data, index: UInt32) -> (key: Data, chainCode: Data) {
        var buffer = Data()

        buffer.append(UInt8(0))
        buffer.append(key)
        let indexBytes = withUnsafeBytes(of: index.bigEndian) { Data($0) }
        buffer.append(indexBytes)

        return hmacSha512(chainCode, buffer)
    }
    
    private static func hmacSha512(_ keyBuffer: Data, _ data: Data) -> (key: Data, chainCode: Data) {
        do {
            let hmac = HMAC(key: keyBuffer.bytes, variant: .sha2(.sha512))
            let i = try hmac.authenticate(data.bytes)
            
            let il = Data(i[0..<32])
            let ir = Data(i[32...])
            
            return (key: il, chainCode: ir)
        } catch {
            print("Error computing HMAC SHA512: \(error)")
            return (key: Data(), chainCode: Data())
        }
    }
    
    private static func isValidPath(path: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^m(\\/[0-9]+')+$")
        let range = NSRange(location: 0, length: path.utf16.count)

        if regex.firstMatch(in: path, options: [], range: range) == nil {
            return false
        }

        let components = path.split(separator: "/").dropFirst()
        let valid = components.allSatisfy { component in
            if let _ = UInt32(component.replacingOccurrences(of: "'", with: "")) {
                return true
            }
            return false
        }

        return valid
    }

    public func derivePath(path: String) throws -> (key: Data, chainCode: Data) {
        if !Ed25519BIP32.isValidPath(path: path) {
            throw NSError(domain: "Invalid derivation path", code: -1)
        }

        let hardenedOffset: UInt32 = 0x80000000
        let segments = path.split(separator: "/").dropFirst().map { component -> UInt32 in
            return UInt32(component.replacingOccurrences(of: "'", with: ""))! + hardenedOffset
        }

        var results = (_masterKey, _chainCode)

        for next in segments {
            results = Ed25519BIP32.getChildKeyDerivation(key: results.0, chainCode: results.1, index: next)
        }

        return results
    }
}
