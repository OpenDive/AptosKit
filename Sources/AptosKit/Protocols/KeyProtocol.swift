//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public protocol KeyProtocol {
    func serialize(_ serializer: Serializer)
    
    static func deserialize(from deserializer: Deserializer) throws -> Self
}
