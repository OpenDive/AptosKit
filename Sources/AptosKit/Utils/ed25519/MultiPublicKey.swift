//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import Foundation

public struct MultiPublicKey: EncodingProtocol, CustomStringConvertible, Equatable {
    public var keys: [PublicKey]
    public var threshold: Int
    
    public static let minKeys: Int = 2
    public static let maxKeys: Int = 32
    public static let minThreshold: Int = 1
    
    init(keys: [PublicKey], threshold: Int, checked: Bool = true) throws {
        if checked {
            if MultiPublicKey.minKeys > keys.count || MultiPublicKey.maxKeys < keys.count {
                throw NSError(domain: "Must have between \(MultiPublicKey.minKeys) and \(MultiPublicKey.maxKeys) keys.", code: -1)
            }
            if MultiPublicKey.minThreshold > threshold || threshold > keys.count {
                throw NSError(domain: "Threshold must be between \(MultiPublicKey.minThreshold) and \(keys.count).", code: -1)
            }
        }
        
        self.keys = keys
        self.threshold = threshold
    }
    
    public var description: String {
        return "\(self.threshold)-of-\(self.keys.count) Multi-Ed25519 public key"
    }
    
    public func toBytes() -> Data {
        var concatenatedKeys: Data = Data()
        for key in self.keys {
            concatenatedKeys += key.key
        }
        return concatenatedKeys + Data([UInt8(self.threshold)])
    }
    
    public static func fromBytes(_ key: Data) throws -> MultiPublicKey {
        let minKeys = MultiPublicKey.minKeys
        let maxKeys = MultiPublicKey.maxKeys
        let minThreshold = MultiPublicKey.minThreshold
        
        let nSigners = Int(key.count / PublicKey.LENGTH)
        
        if minKeys > nSigners || nSigners > maxKeys {
            throw NSError(domain: "Must have between \(minKeys) and \(maxKeys) keys.", code: -1)
        }
        
        guard let keyThreshold = key.last else {
            throw NSError(domain: "Key must have content.", code: -1)
        }
        
        let threshold = Int(keyThreshold)
        
        if minThreshold > threshold || threshold > nSigners {
            throw NSError(domain: "Threshold must be between \(minThreshold) and \(nSigners).", code: -1)
        }
        
        var keys: [PublicKey] = []
        
        for i in 0..<nSigners {
            let startByte = i * PublicKey.LENGTH
            let endByte = (i + 1) * PublicKey.LENGTH
            keys.append(try PublicKey(data: Data(key[startByte..<endByte])))
        }
        
        return try MultiPublicKey(keys: keys, threshold: threshold)
    }
    
    public func serialize(_ serializer: Serializer) throws {
        try Serializer.toBytes(serializer, self.toBytes())
    }
}
