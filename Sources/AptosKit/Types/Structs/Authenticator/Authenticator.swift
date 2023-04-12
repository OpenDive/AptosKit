//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct Authenticator: Equatable, KeyProtocol {
    public static let ed25519: Int = 0
    public static let multiEd25519: Int = 1
    public static let multiAgent: Int = 2
    
    let variant: Int
    let authenticator: any AuthenticatorProtocol
    
    init(authenticator: any AuthenticatorProtocol) {
        if authenticator is Ed25519Authenticator {
            variant = Authenticator.ed25519
        } else if authenticator is MultiEd25519Authenticator {
            variant = Authenticator.multiEd25519
        } else if authenticator is MultiAgentAuthenticator {
            variant = Authenticator.multiAgent
        } else {
            fatalError("Invalid type")
        }
        self.authenticator = authenticator
    }
    
    public static func == (lhs: Authenticator, rhs: Authenticator) -> Bool {
        return lhs.variant == rhs.variant && lhs.authenticator.isEqualTo(rhs.authenticator)
    }
    
    public func verify(_ data: Data) throws -> Bool {
        return try self.authenticator.verify(data)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Authenticator {
        let variant = try deserializer.uleb128()
        
        var authenticator: any AuthenticatorProtocol
        
        if variant == Authenticator.ed25519 {
            authenticator = try Ed25519Authenticator.deserialize(from: deserializer)
        } else if variant == Authenticator.multiEd25519 {
            authenticator = try MultiEd25519Authenticator.deserialize(from: deserializer)
        } else if variant == Authenticator.multiAgent {
            authenticator = try MultiAgentAuthenticator.deserialize(from: deserializer)
        } else {
            fatalError("Invalid type: \(variant)")
        }
        
        return Authenticator(authenticator: authenticator)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.uleb128(UInt(variant))
        try Serializer._struct(serializer, value: self.authenticator)
    }
}
