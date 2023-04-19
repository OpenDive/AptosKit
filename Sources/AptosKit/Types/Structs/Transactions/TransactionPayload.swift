//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct TransactionPayload: KeyProtocol, Equatable {
    public static let script: Int = 0
    public static let moduleBundle: Int = 1
    public static let scriptFunction: Int = 2
    
    let variant: Int
    let value: any TransactionProtocol
    
    public init(payload: any TransactionProtocol) throws {
        if payload is Script {
            self.variant = TransactionPayload.script
        } else if payload is ModuleBundle {
            self.variant = TransactionPayload.moduleBundle
        } else if payload is EntryFunction {
            self.variant = TransactionPayload.scriptFunction
        } else {
            throw NSError(domain: "Invalid Type", code: -1)
        }
        
        self.value = payload
    }
    
    public static func == (lhs: TransactionPayload, rhs: TransactionPayload) -> Bool {
        if lhs.value is Script && rhs.value is Script {
            let lhsValue = lhs.value as! Script
            let rhsValue = rhs.value as! Script
            
            return
                lhs.variant == rhs.variant &&
                lhsValue == rhsValue
        } else if lhs.value is ModuleBundle && rhs.value is ModuleBundle {
            return false
        } else if lhs.value is EntryFunction && rhs.value is EntryFunction {
            let lhsValue = lhs.value as! EntryFunction
            let rhsValue = rhs.value as! EntryFunction
            
            return
                lhs.variant == rhs.variant &&
                lhsValue == rhsValue
        } else {
            return false
        }
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionPayload {
        let variant = try deserializer.uleb128()
        var payload: any TransactionProtocol
        if variant == TransactionPayload.script {
            payload = try Script.deserialize(from: deserializer)
        } else if variant == TransactionPayload.moduleBundle {
            payload = try ModuleBundle.deserialize(from: deserializer)
        } else if variant == TransactionPayload.scriptFunction {
            payload = try EntryFunction.deserialize(from: deserializer)
        } else {
            throw NSError(domain: "Not Implemented", code: -1)
        }
        
        return try TransactionPayload(payload: payload)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try serializer.uleb128(UInt(self.variant))
        try self.value.serialize(serializer)
    }
}
