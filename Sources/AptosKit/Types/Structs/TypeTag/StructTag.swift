//
//  File 9.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct StructTag: TypeProtcol, Equatable {
    let value: StructTagValue
    
    public static func ==(lhs: StructTag, rhs: StructTag) -> Bool {
        return lhs.value == rhs.value
    }
    
    public static func fromStr(_ typeTag: String) throws -> StructTag {
        let name = ""
        let index = 0
        
        while index < typeTag.count {
            var name = ""
            var index = 0
            while index < typeTag.count {
                let letter = typeTag[typeTag.index(typeTag.startIndex, offsetBy: index)]
                index += 1
                if letter == "<" {
                    throw NSError(domain: "Not Implemented", code: -1)
                } else {
                    name.append(letter)
                }
            }
        }
        let split = name.split(separator: "::")
        return try StructTag(
            value: StructTagValue(
                address: AccountAddress.fromHex(String(split[0])),
                module: String(split[1]),
                name: String(split[2]),
                typeArgs: []
            )
        )
    }
    
    public func variant() -> Int {
        return TypeTag._struct
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> StructTag {
        let address = try deserializer._struct(type: AccountAddress.self)
        let module = try Deserializer.string(deserializer)
        let name = try Deserializer.string(deserializer)
        let typeArgs: [TypeTag] = try deserializer.sequence(valueDecoder: TypeTag.deserialize)
        
        return StructTag(
            value: StructTagValue(
                address: address,
                module: module,
                name: name,
                typeArgs: typeArgs
            )
        )
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try self.value.address.serialize(serializer)
        Serializer.str(serializer, self.value.module)
        Serializer.str(serializer, self.value.name)
        serializer.sequence(self.value.typeArgs, Serializer._struct)
    }
}

public struct StructTagValue: Equatable {
    let address: AccountAddress
    let module: String
    let name: String
    let typeArgs: [TypeTag]
    
    public static func == (lhs: StructTagValue, rhs: StructTagValue) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.module == rhs.module &&
            lhs.name == rhs.name &&
            lhs.typeArgs == rhs.typeArgs
    }
}
