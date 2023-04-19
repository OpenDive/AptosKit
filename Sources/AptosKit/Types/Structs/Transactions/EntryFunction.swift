//
//  File 2.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct EntryFunction: TransactionProtocol, Equatable {
    public var module: ModuleId
    public var function: String
    public var tyArgs: [TypeTag]
    public var args: [Data]
    
    public static func natural(
        _ module: String,
        _ function: String,
        _ tyArgs: [TypeTag],
        _ args: [AnyTransactionArgument]
    ) throws -> EntryFunction {
        let moduleId = try ModuleId.fromStr(module)
        var byteArgs: [Data] = []
        
        for arg in args {
            byteArgs.append(try arg.encode())
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
        let function = try Deserializer.string(deserializer)
        let tyArgs = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        let args: [Data] = try deserializer.sequence(valueDecoder: Deserializer.toBytes)

        return EntryFunction(module: module, function: function, tyArgs: tyArgs, args: args)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.module.serialize(serializer)
        try Serializer.str(serializer, self.function)
        try serializer.sequence(self.tyArgs, Serializer._struct)
        try serializer.sequence(self.args, Serializer.toBytes)
    }
}
