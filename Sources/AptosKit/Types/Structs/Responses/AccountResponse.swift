//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation

public struct AccountResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case sequenceNumber = "sequence_number"
        case authenticationKey = "authentication_key"
    }
    
    public var sequenceNumber: String
    public var authenticationKey: String
}
