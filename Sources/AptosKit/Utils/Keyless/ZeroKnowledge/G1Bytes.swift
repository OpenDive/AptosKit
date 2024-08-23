//
//  G1Bytes.swift
//  
//
//  Created by Marcus Arnett on 8/14/24.
//

import Foundation

public struct G1Bytes: KeyProtocol, Equatable {
    public var data: Data

    public init(data: Data) throws {
        guard data.count == 32 else {
            throw AptosError.invalidLength
        }
        self.data = data
    }
    
    public func serialize(_ serializer: Serializer) throws {
        serializer.fixedBytes(self.data)
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> G1Bytes {
        return try G1Bytes(data: deserializer.fixedBytes(length: 32))
    }
}
