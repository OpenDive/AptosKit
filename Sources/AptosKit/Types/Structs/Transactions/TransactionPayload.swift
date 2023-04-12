//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct TransactionPayload: KeyProtocol {
    public static let script: Int = 0
    public static let moduleBundle: Int = 1
    public static let scriptFunction: Int = 2
    
    let variant: Int
    let value: any TransactionProtocol
    
    init(payload: any TransactionProtocol) throws {
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
    
    public static func deserialize(from deserializer: Deserializer) throws -> TransactionPayload {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        
    }
}
