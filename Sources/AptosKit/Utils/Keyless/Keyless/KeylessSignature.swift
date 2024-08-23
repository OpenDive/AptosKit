//
//  KeylessSignature.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
//

public struct KeylessSignature: AptosSignatureProtocol {
    public var description: String

    public func serialize(_ serializer: Serializer) throws {
        <#code#>
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> KeylessSignature {
        <#code#>
    }
}
