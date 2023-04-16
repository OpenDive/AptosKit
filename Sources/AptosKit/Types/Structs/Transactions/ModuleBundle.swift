//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct ModuleBundle: TransactionProtocol, Equatable {
    public var tyArgs: [TypeTag]
    
    init(tyArgs: [TypeTag]) throws {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ModuleBundle {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        throw NSError(domain: "Not Implemented", code: -1)
    }
}
