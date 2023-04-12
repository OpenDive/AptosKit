//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

// TODO: Implement struct
public struct MultiEd25519Authenticator: AuthenticatorProtocol {
    public var publicKey: Int
    public var signature: Int
    
    public func verify(_ data: Data) throws -> Bool {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MultiEd25519Authenticator {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func isEqualTo(_ rhs: AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? MultiEd25519Authenticator else { return false }
        return self.publicKey == APrhs.publicKey && self.signature == APrhs.signature
    }
}
