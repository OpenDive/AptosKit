//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct TransactionArgument<T: EncodingContainer> {
    public let value: T
    public let encoder: (Serializer, T) throws -> ()
    
    public init(
        value: T,
        encoder: @escaping (Serializer, T) throws -> Void
    ) {
        self.value = value
        self.encoder = encoder
    }
    
    public func encode() throws -> Data {
        let ser = Serializer()
        try self.encoder(ser, self.value)
        return ser.output()
    }
}
