//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation

public struct Object: CustomStringConvertible {
    let allowUngatedTransfer: Bool
    let owner: AccountAddress
    
    public init(allowUngatedTransfer: Bool, owner: AccountAddress) {
        self.allowUngatedTransfer = allowUngatedTransfer
        self.owner = owner
    }
    
    public var description: String {
        return "Object[allow_ungated_transfer: \(self.allowUngatedTransfer), owner: \(self.owner.description)]"
    }
    
    public static func parse(_ resource: [String: Any]) throws -> Object {
        guard let allowUngatedTranser = resource["allow_untaged_transfer"], allowUngatedTranser is Bool else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let accountAddress = resource["owner"], accountAddress is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        return Object(
            allowUngatedTransfer: allowUngatedTranser as! Bool,
            owner: try AccountAddress.fromHex(accountAddress as! String)
        )
    }
}
