//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation
import CryptoSwift

public struct MultiAgentRawTransaction {
    public var rawTransaction: RawTransaction
    public var secondarySigners: [AccountAddress]
    
    public func inner() -> RawTransaction {
        return self.rawTransaction
    }
    
    public func prehash() throws -> Data {
        guard let data = "APTOS::RawTransactionWithData".data(using: .utf8) else {
            throw NSError(domain: "Invalid String", code: -1)
        }
        return data.sha3(.sha256)
    }
    
    public func keyed() throws -> Data {
        let ser = Serializer()
        try Serializer.u8(ser, UInt8(0))
        try Serializer._struct(ser, value: self.rawTransaction)
        try ser.sequence(self.secondarySigners, Serializer._struct)
        var prehash = Array(try prehash()).map { Data([$0]) }
        prehash.append(ser.output())
        return prehash.reduce(Data(), { $0 + $1 })
    }
    
    public func sign(_ key: PrivateKey) throws -> Signature {
        return try key.sign(data: self.keyed())
    }
    
    public func verify(_ key: PublicKey, _ signature: Signature) throws -> Bool {
        return try key.verify(data: self.keyed(), signature: signature)
    }
}
