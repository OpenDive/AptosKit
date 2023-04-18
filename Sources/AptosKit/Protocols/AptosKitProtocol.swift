//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/17/23.
//

import Foundation
import SwiftyJSON

public protocol AptosKitProtocol {
    func account(_ accountAddress: AccountAddress, ledgerVersion: Int?) async throws -> AccountResponse
    
    func accountBalance(_ accountAddress: AccountAddress, _ ledgerVersion: Int?) async throws -> Int
    
    func accountSequenceNumber(_ accountAddress: AccountAddress, _ ledgerVersion: Int?) async throws -> Int
    
    func accountResource(_ accountAddress: AccountAddress, _ resourceType: String, _ ledgerVersion: Int?) async throws -> JSON
    
    func getTableItem(_ handle: String, _ keyType: String, _ valueType: String, _ key: any EncodingProtocol, _ ledgerVersion: Int?) async throws -> JSON
    
    func aggregatorValue(_ accountAddress: AccountAddress, _ resourceType: String, _ aggregatorPath: [String]) async throws -> Int
}
