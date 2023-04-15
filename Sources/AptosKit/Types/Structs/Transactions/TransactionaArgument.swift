//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct TransactionArgument {
    public let value: any EncodingProtocol
    public let encoder: (Serializer, any EncodingProtocol) throws -> ()
    
    public func encode() throws -> Data {
        let ser = Serializer()
        try self.encoder(ser, self.value)
        return ser.output()
    }
}
