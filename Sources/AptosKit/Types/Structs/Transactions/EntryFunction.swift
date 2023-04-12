//
//  File 2.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct EntryFunction: TransactionProtocol {
    public var module: ModuleId
    public var function: String
    public var tyArgs: [TypeTag]
    public var args: [Data]
    
    public static func natural(
        _ module: String,
        _ function: String,
        _ tyArgs: [TypeTag],
        _ args: [TransactionArgument]
    ) throws -> EntryFunction {
        let moduleId = try ModuleId.fromStr(module)
        var byteArgs: [Data] = []
        
        for arg in args {
            byteArgs.append(arg.encode())
        }
        return EntryFunction(
            module: moduleId,
            function: function,
            tyArgs: tyArgs,
            args: byteArgs
        )
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> EntryFunction {
        let module = try ModuleId.deserialize(from: deserializer)
        let function = try deserializer.string()
        let tyArgs = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        let args: [Data] = try deserializer.sequence(valueDecoder: Deserializer.toBytes)

        return EntryFunction(module: module, function: function, tyArgs: tyArgs, args: args)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.module.serialize(serializer)
        serializer.str(self.function)
        serializer.sequence(self.tyArgs, Serializer._struct)
        serializer.sequence(self.args, Serializer.toBytes)
    }
}
