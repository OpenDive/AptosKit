//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

// TODO: Implement struct
public struct MultiAgentAuthenticator: AuthenticatorProtocol {
    public var sender: Authenticator
    public var secondarySigner: [(AccountAddress, Authenticator)]
    
    public func secondaryAddresses() -> [AccountAddress] {
        return secondarySigner.map { $0.0 }
    }
    
    public func verify(_ data: Data) throws -> Bool {
        if !(try self.sender.verify(data)) {
            return false
        }
        return !(try secondarySigner.map { try $0.1.verify(data) }.contains(false))
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> MultiAgentAuthenticator {
        let sender = try deserializer._struct(type: Authenticator.self)
        let secondaryAddresses = try deserializer.sequence(valueDecoder: AccountAddress.deserialize)
        let secondaryAuthenticator = try deserializer.sequence(valueDecoder: Authenticator.deserialize)
        return MultiAgentAuthenticator(sender: sender, secondarySigner: Array(zip(secondaryAddresses, secondaryAuthenticator)))
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.sender)
        serializer.sequence(self.secondarySigner.map { $0.0 }, Serializer._struct)
        serializer.sequence(self.secondarySigner.map { $0.1 }, Serializer._struct)
    }
    
    public func isEqualTo(_ rhs: AuthenticatorProtocol) -> Bool {
        guard let APrhs = rhs as? MultiAgentAuthenticator else { return false }
        for (signer, rhsSigner) in zip(self.secondarySigner, APrhs.secondarySigner) {
            if signer.0 != rhsSigner.0 || signer.1 != rhsSigner.1 {
                return false
            }
        }
        return self.sender == APrhs.sender
    }
}
