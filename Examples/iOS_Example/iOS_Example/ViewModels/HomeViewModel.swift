//
//  HomeViewModel.swift
//  iOS_Example
//
//  Created by Marcus Arnett on 4/21/23.
//

import Foundation
import AptosKit

public class HomeViewModel: ObservableObject {
    @Published var wallets: [Wallet]
    @Published var currentWallet: Wallet
    
    let restBaseUrl = "https://fullnode.devnet.aptoslabs.com/v1"
    let faucetUrl = "https://faucet.devnet.aptoslabs.com"
    
    public init() throws {
        let mnemo = Mnemonic(wordcount: 12, wordlist: Wordlists.english)
        let newWallet = try Wallet(mnemonic: mnemo)
        self.currentWallet = newWallet
        self.wallets = [newWallet]
    }
    
    public init(wallet: Wallet) {
        self.currentWallet = wallet
        self.wallets = [wallet]
    }
    
    public func createWallet() throws {
        let mnemo = Mnemonic(wordcount: 12, wordlist: Wordlists.english)
        try self.initializeWallet(mnemo)
    }
    
    public func restoreWallet(_ phrase: String) throws {
        let mnemo = try Mnemonic(phrase: phrase.components(separatedBy: " "))
        try self.initializeWallet(mnemo)
    }
    
    public func getWalletAddresses() -> [String] {
        return wallets.map { $0.account.address().hex() }
    }
    
    public func getCurrentWalletAddress() -> String {
        return self.currentWallet.account.address().description
    }
    
    public func getCurrentWalletBalance() async throws -> Double {
        let restClient = try await RestClient(baseUrl: restBaseUrl)
        return try await Double(restClient.accountBalance(self.currentWallet.account.accountAddress)) / Double(100_000_000)
    }
    
    public func airdropToCurrentWallet() async throws {
        let restClient = try await RestClient(baseUrl: restBaseUrl)
        let faucetClient = FaucetClient(baseUrl: faucetUrl, restClient: restClient)

        try await faucetClient.fundAccount(self.currentWallet.account.address().description, 100_000_000)
    }
    
    public func createNft(
        _ collectionName: String,
        _ tokenName: String,
        _ tokenDescription: String,
        _ supply: Int,
        _ uri: String,
        _ royalty: Int
    ) async throws -> String {
        let restClient = try await RestClient(baseUrl: restBaseUrl)
        let hash = try await restClient.createToken(
            self.currentWallet.account,
            collectionName,
            tokenName,
            tokenDescription,
            supply,
            uri,
            royalty
        )
        return try await self.waitForTransaction(hash, restClient)
    }
    
    public func createCollection(
        _ collectionName: String,
        _ collectionDescription: String,
        _ collectionUri: String
    ) async throws -> String {
        let restClient = try await RestClient(baseUrl: restBaseUrl)
        let hash = try await restClient.createCollection(
            self.currentWallet.account,
            collectionName,
            collectionDescription,
            collectionUri
        )
        return try await self.waitForTransaction(hash, restClient)
    }
    
    public func createTransaction(_ receiverAddress: String, _ amount: Double) async throws -> String {
        let restClient = try await RestClient(baseUrl: restBaseUrl)
        let amountInt: Int = Int(amount * 100_000_000)
        let hash = try await restClient.transfer(
            self.currentWallet.account,
            AccountAddress.fromHex(receiverAddress),
            amountInt
        )
        return try await self.waitForTransaction(hash, restClient)
    }
    
    private func waitForTransaction(_ hash: String, _ restClient: RestClient) async throws -> String {
        guard hash.contains("0x") else {
            return hash
        }
        
        do {
            try await restClient.waitForTransaction(hash)
        } catch {
            return error.localizedDescription
        }
        
        return hash
    }
    
    private func initializeWallet(_ mnemo: Mnemonic) throws {
        let newWallet = try Wallet(mnemonic: mnemo)
        self.wallets.append(newWallet)
        self.currentWallet = newWallet
    }
}
