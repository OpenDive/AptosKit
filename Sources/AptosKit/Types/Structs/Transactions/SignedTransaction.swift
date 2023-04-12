//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct SignedTransaction: KeyProtocol {
    public var transaction: RawTransaction
    public var authenticator: Authenticator
    
    public func bytes() throws -> Data {
        let ser = Serializer()
        try Serializer._struct(ser, value: self)
        return ser.output()
    }
    
    public func verify() throws -> Bool {
        var keyed: Data
        
        if self.authenticator.authenticator is MultiAgentAuthenticator {
            let transaction = MultiAgentRawTransaction(
                rawTransaction: self.transaction,
                secondarySigners: (self.authenticator.authenticator as! MultiAgentAuthenticator).secondaryAddresses()
            )
            keyed = try transaction.keyed()
        } else {
            keyed = try self.transaction.keyed()
        }
        
        return try self.authenticator.verify(keyed)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> SignedTransaction {
        let transaction = try RawTransaction.deserialize(from: deserializer)
        let authenticator = try Authenticator.deserialize(from: deserializer)
        return SignedTransaction(transaction: transaction, authenticator: authenticator)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.transaction.serialize(serializer)
        try self.authenticator.serialize(serializer)
    }
}
