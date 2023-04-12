//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct TransactionArgument {
    public let value: Any
    public let encoder: (Serializer, Any) -> ()
    
    public func encode() -> Data {
        let ser = Serializer()
        self.encoder(ser, self.value)
        return ser.output()
    }
}
