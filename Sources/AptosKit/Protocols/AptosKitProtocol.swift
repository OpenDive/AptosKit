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
    
    func getTableItem(_ handle: String, _ keyType: String, _ valueType: String, _ key: any EncodingContainer, _ ledgerVersion: Int?) async throws -> JSON
    
    func aggregatorValue(_ accountAddress: AccountAddress, _ resourceType: String, _ aggregatorPath: [String]) async throws -> Int
    
    func info() async throws -> InfoResponse
    
    func simulateTransaction(_ transaction: RawTransaction, _ sender: Account) async throws -> JSON
    
    func submitBcsTransaction(_ signedTransaction: SignedTransaction) async throws -> String
    
    func submitTransaction(_ sender: Account, _ payload: [String: Any]) async throws -> String
    
    func transactionPending(_ txnHash: String) async throws -> Bool
    
    func waitForTransaction(_ txnHash: String) async throws
    
    func createMultiAgentBcsTransaction(_ sender: Account, _ secondaryAccounts: [Account], _ payload: TransactionPayload) async throws -> SignedTransaction
    
    func createBcsTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> RawTransaction
    
    func createBcsSignedTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> SignedTransaction
    
    func transfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String
    
    func bcsTransfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String
    
    func createCollection(_ account: Account, _ name: String, _ description: String, _ uri: String) async throws -> String
    
    func createToken(_ account: Account, _ collectionName: String, _ name: String, _ description: String, _ supply: Int, _ uri: String, _ royaltyPointsPerMillion: Int) async throws -> String
    
    func offerToken(_ account: Account, _ receiver: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int, _ amount: Int) async throws -> String
    
    func claimToken(_ account: Account, _ sender: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> String
    
    func directTransferToken(_ sender: Account, _ receiver: Account, _ creatorAddress: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int, _ amount: Int) async throws -> String
    
    func getToken(_ owner: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> JSON
    
    func getTokenBalance(_ owner: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> String
    
    func getTokenData(_ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> JSON
    
    func getCollection(_ creator: AccountAddress, _ collectionName: String) async throws -> JSON
}
