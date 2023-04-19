//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import SwiftyJSON

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
    
    public static func parse(_ resource: JSON) throws -> Collection {
        return Collection(
            creator: try AccountAddress.fromHex(resource["creator"].stringValue),
            _description: resource["description"].stringValue,
            name: resource["name"].stringValue,
            uri: resource["uri"].stringValue
        )
    }
}
