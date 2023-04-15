//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public protocol KeyProtocol: EncodingProtocol {
    func serialize(_ serializer: Serializer) throws
    
    static func deserialize(from deserializer: Deserializer) throws -> Self
}
