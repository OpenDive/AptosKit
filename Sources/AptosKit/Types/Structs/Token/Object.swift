//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import SwiftyJSON

public struct Object: CustomStringConvertible {
    public let allowUngatedTransfer: Bool
    public let owner: AccountAddress
    
    public init(allowUngatedTransfer: Bool, owner: AccountAddress) {
        self.allowUngatedTransfer = allowUngatedTransfer
        self.owner = owner
    }
    
    public var description: String {
        return "Object[allow_ungated_transfer: \(self.allowUngatedTransfer), owner: \(self.owner.description)]"
    }
    
    public static func parse(_ resource: JSON) throws -> Object {
        return Object(
            allowUngatedTransfer: resource["allow_ungated_transfer"].boolValue,
            owner: try AccountAddress.fromHex(resource["owner"].stringValue)
        )
    }
}
