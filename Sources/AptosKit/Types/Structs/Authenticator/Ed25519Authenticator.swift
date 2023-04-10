//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct Ed25519Authenticator: AuthenticatorProtocol {
    public let publicKey: PublicKey
    public let signature: Signature
    
    public func verify(_ data: Data) throws -> Bool {
        return try self.publicKey.verify(data: data, signature: self.signature)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Ed25519Authenticator {
        let key = try deserializer._struct(type: PublicKey.self)
        let signature = try deserializer._struct(type: Signature.self)
        return Ed25519Authenticator(publicKey: key, signature: signature)
    }
    
    public func serialize(_ serializer: Serializer) {
        serializer._struct(value: self.publicKey)
        serializer._struct(value: self.signature)
    }
    
    public func isEqualTo(_ rhs: any AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? Ed25519Authenticator else { return false }
        return self.publicKey == APrhs.publicKey && self.signature == APrhs.signature
    }
}
