//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

// TODO: Implement struct
public struct MultiAgentAuthenticator: AuthenticatorProtocol {
    public func verify(_ data: Data) throws -> Bool {
        return false
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MultiAgentAuthenticator {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func serialize(_ serializer: Serializer) {
        
    }
    
    public func isEqualTo(_ rhs: AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? MultiAgentAuthenticator else { return false }
        return false
    }
}
