//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import SwiftyJSON

public struct Token: CustomStringConvertible {
    let collection: AccountAddress
    let collectionId: Int
    let creatorName: String?
    let _description: String
    let name: String
    let uri: String
    
    let structTag: String = "0x4::token::Token"
    
    public init(
        collection: AccountAddress,
        collectionId: Int,
        creatorName: String? = nil,
        _description: String,
        name: String,
        uri: String
    ) {
        self.collection = collection
        self.collectionId = collectionId
        self.creatorName = creatorName
        self._description = _description
        self.name = name
        self.uri = uri
    }
    
    public var description: String {
        return "Token[collection: \(self.collection), collection_id: \(self.collectionId), creation_name: \(self.creatorName ?? ""), description: \(self._description), name: \(self.name), uri: \(self.uri)]"
    }
    
    public static func parse(resource: JSON) throws -> Token {
        return Token(
            collection: try AccountAddress.fromHex(resource["collection"]["inner"].stringValue),
            collectionId: resource["collection_id"].intValue,
            creatorName: resource["creation_name"]["vec"].intValue == 1 ? resource["creation_name"]["vec"][0].stringValue : nil,
            _description: resource["description"].stringValue,
            name: resource["name"].stringValue,
            uri: resource["uri"].stringValue
        )
    }
}
