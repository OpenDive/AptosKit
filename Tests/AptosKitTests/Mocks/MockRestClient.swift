//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/17/23.
//

import Foundation
import SwiftyJSON
@testable import AptosKit

public struct MockRestClient: AptosKitProtocol {
    func getDecodedData<T: Decodable>(_ type: T.Type = T.self, with jsonData: String) async throws -> T {
        guard let url = Bundle.test.url(forResource: jsonData, withExtension: "json") else {
            throw NSError(domain: "Getting Url for bundle has failed.", code: -1)
        }

        guard let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "Setting data using contents of url has failed.", code: -1)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        guard let result = try? decoder.decode(T.self, from: data) else {
            throw NSError(domain: "Decoding data has failed.", code: -1)
        }

        return result
    }
    
    public func account(_ accountAddress: AccountAddress, ledgerVersion: Int? = nil) async throws -> AccountResponse {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return AccountResponse(sequenceNumber: "1", authenticationKey: "0x9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d")
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountBalance(_ accountAddress: AccountAddress, _ ledgerVersion: Int? = nil) async throws -> Int {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return 647362
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountSequenceNumber(_ accountAddress: AccountAddress, _ ledgerVersion: Int? = nil) async throws -> Int {
        if accountAddress.address.hexEncodedString() == "9f628c43d1c1c0f54683cf5ccbd2b944608df4ff2649841053b1790a4d7c187d" {
            return 1
        } else {
            throw NSError(domain: "Incorrect Formatting for AccountAddress.", code: -1)
        }
    }
    
    public func accountResource(_ accountAddress: AccountAddress, _ resourceType: String, _ ledgerVersion: Int? = nil) async throws -> JSON {
        return try await getDecodedData(with: "AccountResource") as JSON
    }
    
    public func getTableItem(_ handle: String, _ keyType: String, _ valueType: String, _ key: any EncodingContainer, _ ledgerVersion: Int? = nil) async throws -> JSON {
        guard let key = key as? String else {
            throw NSError(domain: "Key is not a string value.", code: -1)
        }
        
        if key == "0x619dc29a0aac8fa146714058e8dd6d2d0f3bdf5f6331907bf91f3acd81e6935" {
            return 102994413849650711
        } else {
            throw NSError(domain: "Incorrect Formatting for Key.", code: -1)
        }
    }
    
    public func aggregatorValue(_ accountAddress: AccountAddress, _ resourceType: String, _ aggregatorPath: [String]) async throws -> Int {
        var data = try await getDecodedData(with: "AggregatorValue") as JSON
        data = data["data"]
        
        var aggregator = aggregatorPath
        
        while aggregator.count > 0 {
            let key = aggregator.popLast()
            if let key {
                if data[key].exists() {
                    data = data[key]
                } else {
                    throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
                }
            } else {
                break
            }
        }
        
        if !data["vec"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        data = data["vec"]
        if data.count != 1 {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        data = data[0]
        if !data["aggregator"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        data = data["aggregator"]
        if !data["vec"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        data = data["vec"]
        if data.count != 1 {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        data = data[0]
        if !data["handle"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        let handle = data["handle"].stringValue
        if !data["key"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(data)", code: -1)
        }
        guard let key = data["key"].rawValue as? any EncodingProtocol else {
            throw NSError(domain: "Could not decode key: \(data["key"].stringValue)", code: -1)
        }

        return try await self.getTableItem(handle, "address", "u128", key).intValue
    }
    
    public func info() async throws -> InfoResponse {
        return try await getDecodedData(with: "Info") as InfoResponse
    }
    
    public func simulateTransaction(_ transaction: RawTransaction, _ sender: Account) async throws -> JSON {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func submitBcsTransaction(_ signedTransaction: SignedTransaction) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func submitTransaction(_ sender: Account, _ payload: [String : Any]) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func transactionPending(_ txnHash: String) async throws -> Bool {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func waitForTransaction(_ txnHash: String) async throws {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func createMultiAgentBcsTransaction(
        _ sender: Account,
        _ secondaryAccounts: [Account],
        _ payload: TransactionPayload
    ) async throws -> SignedTransaction {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func createBcsTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> RawTransaction {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func createBcsSignedTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> SignedTransaction {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func transfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func bcsTransfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func createCollection(_ account: Account, _ name: String, _ description: String, _ uri: String) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func createToken(
        _ account: Account,
        _ collectionName: String,
        _ name: String,
        _ description: String,
        _ supply: Int,
        _ uri: String,
        _ royaltyPointsPerMillion: Int
    ) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func offerToken(
        _ account: Account,
        _ receiver: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int,
        _ amount: Int
    ) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func claimToken(
        _ account: Account,
        _ sender: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func directTransferToken(
        _ sender: Account,
        _ receiver: Account,
        _ creatorAddress: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int,
        _ amount: Int
    ) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func getToken(
        _ owner: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> JSON {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func getTokenBalance(
        _ owner: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> String {
        throw NSError(domain: "Not Implemented", code: -1)
    }
    
    public func getTokenData(
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> JSON {
        throw NSError(domain: "Not Implemented", code: -1)
    }
}
