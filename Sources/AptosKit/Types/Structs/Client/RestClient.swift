//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation
import SwiftyJSON

public struct RestClient {
    public var chainId: Int?
    public var client: URLSession
    public var clientConfig: ClientConfig
    public var baseUrl: String
    
    init(
        baseUrl: String,
        client: URLSession = URLSession.shared,
        clientConfig: ClientConfig = ClientConfig()
    ) {
        self.baseUrl = baseUrl
        self.client = client
        self.clientConfig = clientConfig
        self.chainId = nil
    }
    
    public func account(
        _ accountAddress: AccountAddress,
        ledgerVersion: Int? = nil
    ) async throws -> AccountResponse {
        var request: String = ""
        if ledgerVersion == nil {
            request = "\(self.baseUrl)/accounts/\(accountAddress)"
        } else {
            request = "\(self.baseUrl)/accounts/\(accountAddress)?ledger_version=\(ledgerVersion!)"
        }
        guard let url = URL(string: request) else { throw NSError(domain: "Invalid URL", code: -1) }
        let result: JSON = try await self.client.decodeUrl(with: url)
        return AccountResponse(
            sequenceNumber: result["sequence_number"].stringValue,
            authenticationKey: result["authentication_key"].stringValue
        )
    }
    
    public func accountBalance(
        _ accountAddress: AccountAddress,
        _ ledgerVersion: Int? = nil
    ) async throws -> Int {
        let resource = try await self.accountResource(
            accountAddress,
            "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>",
            ledgerVersion
        )
        return resource["data"]["coin"]["value"].intValue
    }
    
    public func accountSequenceNumber(
        _ accountAddress: AccountAddress,
        _ ledgerVersion: Int? = nil
    ) async throws -> Int {
        let accountResources = try await self.account(accountAddress, ledgerVersion: ledgerVersion)
        guard let result = Int(accountResources.sequenceNumber) else {
            throw NSError(domain: "Sequence Number is an Invalid Integer", code: -1)
        }
        return result
    }
    
    public func accountResource(
        _ accountAddress: AccountAddress,
        _ resourceType: String,
        _ ledgerVersion: Int? = nil
    ) async throws -> JSON {
        var request: String = ""
        if ledgerVersion == nil {
            request = "\(self.baseUrl)/accounts/\(accountAddress)/resource/\(resourceType.urlEncoded)"
        } else {
            request = "\(self.baseUrl)/accounts/\(accountAddress)/resource/\(resourceType.urlEncoded)?ledger_version=\(ledgerVersion!)"
        }
        guard let url = URL(string: request) else { throw NSError(domain: "Invalid URL", code: -1) }
        return try await self.client.decodeUrl(with: url)
    }
    
    public func getTableItem(
        _ handle: String,
        _ keyType: String,
        _ valueType: String,
        _ key: any EncodingProtocol,
        _ ledgerVersion: Int? = nil
    ) async throws -> JSON {
        var request = ""
        if let ledgerVersion {
            request = "\(self.baseUrl)/tables/\(handle)/item?ledger_version=\(ledgerVersion)"
        } else {
            request = "\(self.baseUrl)/tables/\(handle)/item"
        }
        guard let url = URL(string: request) else { throw NSError(domain: "Invalid URL", code: -1) }
        return try await self.client.decodeUrl(with: url, [
            "key_type": keyType,
            "value_type": valueType,
            "key": key
        ])
    }
}
