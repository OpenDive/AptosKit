//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation

public struct Collection: CustomStringConvertible {
    public let creator: AccountAddress
    public let _description: String
    public let name: String
    public let uri: String
    
    public let structTag: String = "0x4::collection::Collection"
    
    public init(
        creator: AccountAddress,
        _description: String,
        name: String,
        uri: String
    ) {
        self.creator = creator
        self._description = _description
        self.name = name
        self.uri = uri
    }
    
    public var description: String {
        return "AccountAddress[creator: \(self.creator), description: \(self._description), name: \(self.name), uri: \(self.uri)]"
    }
    
    public static func parse(_ resource: [String: Any]) throws -> Collection {
        guard let creator = resource["creator"], creator is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let description = resource["description"], description is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let name = resource["name"], name is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let uri = resource["uri"], uri is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        
        return Collection(
            creator: try AccountAddress.fromHex(creator as! String),
            _description: description as! String,
            name: name as! String,
            uri: uri as! String
        )
    }
}
