//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import Foundation

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
    
    public static func parse(_ resource: [String: Any]) throws -> Royalty {
        guard let numerator = resource["numerator"], numerator is Int else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let denominator = resource["denominator"], denominator is Int else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        guard let payeeAddress = resource["payee_address"], payeeAddress is String else {
            throw NSError(domain: "Invalid resource", code: -1)
        }
        
        return Royalty(
            numerator: numerator as! Int,
            denominator: denominator as! Int,
            payeeAddress: try AccountAddress.fromHex(payeeAddress as! String)
        )
    }
}
