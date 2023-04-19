//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation
import SwiftyJSON

public struct Royalty: CustomStringConvertible {
    public let numerator: Int
    public let denominator: Int
    public let payeeAddress: AccountAddress
    
    public let structTag: String = "0x4::royalty::Royalty"
    
    public init(numerator: Int, denominator: Int, payeeAddress: AccountAddress) {
        self.numerator = numerator
        self.denominator = denominator
        self.payeeAddress = payeeAddress
    }
    
    public var description: String {
        return "Royalty[numberator: \(self.numerator), denominator: \(self.denominator), payee_address: \(self.payeeAddress.description)]"
    }
    
    public static func parse(_ resource: JSON) throws -> Royalty {
        return Royalty(
            numerator: resource["numerator"].intValue,
            denominator: resource["denominator"].intValue,
            payeeAddress: try AccountAddress.fromHex(resource["payee_address"].stringValue)
        )
    }
}
