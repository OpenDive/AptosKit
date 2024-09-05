//
//  FaucetClient.swift
//  AptosKit
//
//  Copyright (c) 2024 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Aptos Blockchain Faucet Client
public struct FaucetClient {
    public var faucetApi: FaucetApi
    public var restClient: RestClient

    public init(restClient: RestClient, faucetApi: FaucetApi? = nil) {
        self.faucetApi = faucetApi ?? FaucetApi(mode: .devnet)
        self.restClient = restClient
    }

    /// Fund an account on the blockchain with a specified amount of currency.
    ///
    /// This function takes an account address and an amount, and sends a request to the blockchain to
    /// mint the specified amount of currency and deposit it into the account with the specified address.
    /// The request is sent to the endpoint "/mint" on the provided base URL using an HTTP POST method.
    /// The function then waits for the transaction to be confirmed by the blockchain before returning.
    ///
    /// - Parameters:
    ///    - address: The address of the account to fund.
    ///    - amount: The amount of currency to deposit into the account.
    ///
    /// - Returns: A `String` value representing the transaction's hash.
    /// - Throws: An error if the provided URL is invalid, or if the REST client fails to decode the response,
    /// or if the transaction fails to be confirmed by the blockchain.
    public func fundAccount(_ address: String, _ amount: Int, _ wait_for_transaction: Bool = true) async throws -> String {
        guard let url = URL(string: "\(try self.faucetApi.getUrl())/mint?amount=\(amount)&address=\(address)") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        let response = try await self.restClient.client.decodeUrl(with: url, .post)
        if response.null != nil {
            throw AptosError.restError
        }
        let txnHash: String = response.arrayValue[0].stringValue
        if wait_for_transaction {
            try await self.restClient.waitForTransaction(txnHash)
        }
        return txnHash
    }
}
