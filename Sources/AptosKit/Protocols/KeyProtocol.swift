//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public protocol KeyProtocol: EncodingProtocol {
    /// Serializes an output instance using the given Serializer.
    ///
    /// - Parameter serializer: The Serializer instance used to serialize the data.
    ///
    /// - Throws: An error if the serialization fails.
    func serialize(_ serializer: Serializer) throws
    
    /// Deserializes an output instance from a Deserializer.
    ///
    /// - Parameter deserializer: The Deserializer instance used to deserialize the data.
    ///
    /// - Returns: A new PrivateKey instance with the deserialized key data.
    ///
    /// - Throws: An error if the deserialization fails.
    static func deserialize(from deserializer: Deserializer) throws -> Self
}
