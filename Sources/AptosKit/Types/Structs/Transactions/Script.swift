//
//  File 3.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct Script: TransactionProtocol {
    public var code: Data
    public var args: [ScriptArgument]
    public var tyArgs: [TypeTag]
    
    public static func deserialize(from deserializer: Deserializer) throws -> Script {
        let code = try Deserializer.toBytes(deserializer)
        let tyArgs = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        let args = try deserializer.sequence(valueDecoder: ScriptArgument.deserialize)
        
        return Script(code: code, args: args, tyArgs: tyArgs)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.code)
        try serializer.sequence(self.tyArgs, Serializer._struct)
        try serializer.sequence(self.args, Serializer._struct)
    }
}
