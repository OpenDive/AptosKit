//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/11/23.
//

import Foundation

public struct ModuleId: KeyProtocol, Equatable {
    public var address: AccountAddress
    public var name: String
    
    public static func fromStr(_ moduleId: String) throws -> ModuleId {
        let split = moduleId.split(separator: "::")
        return ModuleId(
            address: try AccountAddress.fromHex(String(split[0])),
            name: String(split[1])
        )
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> ModuleId {
        let address = try AccountAddress.deserialize(from: deserializer)
        let name = try Deserializer.string(deserializer)
        return ModuleId(address: address, name: name)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.address.serialize(serializer)
        try Serializer.str(serializer, self.name)
    }
}
