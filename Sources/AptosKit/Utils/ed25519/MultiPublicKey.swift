//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/13/23.
//

import Foundation

public struct MultiPublicKey: CustomStringConvertible {
    public var keys: [PublicKey]
    public var threshold: Int
    
    public let minKeys: Int = 2
    public let maxKeys: Int = 32
    public let minThreshold: Int = 1
    
    init(keys: [PublicKey], threshold: Int, checked: Bool = true) throws {
        if checked {
            if self.minKeys >= keys.count || self.maxKeys <= keys.count {
                throw NSError(domain: "Must have between \(self.minKeys) and \(self.maxKeys) keys.", code: -1)
            }
            if self.minThreshold >= threshold || threshold >= keys.count {
                throw NSError(domain: "Threshold must be between \(self.minThreshold) and \(keys.count).", code: -1)
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
}
