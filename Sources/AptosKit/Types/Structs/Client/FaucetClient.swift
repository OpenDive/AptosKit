//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/18/23.
//

import Foundation

public struct FaucetClient {
    let baseUrl: String
    let restClient: RestClient
    
    public func fundAccount(_ address: String, _ amount: Int) async throws {
        guard let url = URL(string: "\(self.baseUrl)/mint?amount=\(amount)&address=\(address)") else { throw NSError(domain: "Invalid URL", code: -1) }
        let response = try await self.restClient.client.decodeUrl(with: url, .post)
        for txnHash in response.arrayValue {
            try await self.restClient.waitForTransaction(txnHash.stringValue)
        }
    }
}
