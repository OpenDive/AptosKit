//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation
import SwiftyJSON

public struct RestClient: AptosKitProtocol {
    public var chainId: Int
    public var client: URLSession
    public var clientConfig: ClientConfig
    public var baseUrl: String
    
    public init(
        baseUrl: String,
        client: URLSession = URLSession.shared,
        clientConfig: ClientConfig = ClientConfig()
    ) async throws {
        guard let url = URL(string: baseUrl) else { throw NSError(domain: "Invalid URL", code: -1) }
        
        self.baseUrl = baseUrl
        self.client = client
        self.clientConfig = clientConfig
        self.chainId = try await self.client.decodeUrl(with: url)["chain_id"].intValue
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
        _ key: any EncodingContainer,
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
    
    public func aggregatorValue(
        _ accountAddress: AccountAddress,
        _ resourceType: String,
        _ aggregatorPath: [String]
    ) async throws -> Int {
        let sourceData = try await self.accountResource(accountAddress, resourceType)["data"]
        var data = sourceData
        var aggregator = aggregatorPath
        
        while aggregator.count > 0 {
            let key = aggregator.popLast()
            if let key {
                if data[key].exists() {
                    data = data[key]
                } else {
                    throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
                }
            } else {
                break
            }
        }
        
        if !data["vec"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        data = data["vec"]
        if data.count != 1 {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        data = data[0]
        if !data["aggregator"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        data = data["aggregator"]
        if !data["vec"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        data = data["vec"]
        if data.count != 1 {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        data = data[0]
        if !data["handle"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        let handle = data["handle"].stringValue
        if !data["key"].exists() {
            throw NSError(domain: "aggregator path not found in data: \(sourceData)", code: -1)
        }
        guard let key = data["key"].rawValue as? any EncodingProtocol else {
            throw NSError(domain: "Could not decode key: \(data["key"].stringValue)", code: -1)
        }

        return try await self.getTableItem(handle, "address", "u128", key).intValue
    }
    
    public func info() async throws -> InfoResponse {
        guard let url = URL(string: self.baseUrl) else { throw NSError(domain: "Invalid URL", code: -1) }
        return try await self.client.decodeUrl(with: url)
    }
    
    public func simulateTransaction(_ transaction: RawTransaction, _ sender: Account) async throws -> JSON {
        let signature = Data(repeating: 0, count: 64)
        let authenticator = Authenticator(authenticator: Ed25519Authenticator(publicKey: try sender.publicKey(), signature: Signature(signature: signature)))
        let signedTransaction = SignedTransaction(transaction: transaction, authenticator: authenticator)
        
        let header = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        guard let request = URL(string: "\(self.baseUrl)/transactions/simulate") else { throw NSError(domain: "Invalid URL", code: -1) }
        return try await self.client.decodeUrl(with: request, header, try signedTransaction.bytes())
    }
    
    public func submitBcsTransaction(_ signedTransaction: SignedTransaction) async throws -> String {
        let header = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        guard let request = URL(string: "\(self.baseUrl)/transactions") else { throw NSError(domain: "Invalid URL", code: -1) }
        let response = try await self.client.decodeUrl(with: request, header, try signedTransaction.bytes())
        return response["hash"].stringValue
    }
    
    public func submitTransaction(_ sender: Account, _ payload: [String: Any]) async throws -> String {
        var txnRequest: [String: Any] = [
            "sender": sender.address().description,
            "sequence_number": String(try await self.accountSequenceNumber(sender.address())),
            "max_gas_amount": String(self.clientConfig.maxGasAmount),
            "gas_unit_price": String(self.clientConfig.gasUnitPrice),
            "expiration_timestamp_secs": String(Int(Date().timeIntervalSince1970) + self.clientConfig.expirationTtl),
            "payload": payload
        ]
        guard let request = URL(string: "\(self.baseUrl)/transactions/encode_submission") else { throw NSError(domain: "Invalid URL", code: -1) }
        var response = try await self.client.decodeUrl(with: request, txnRequest)
        let toSign = Data(hex: response.stringValue)
        let signature = try sender.sign(toSign)
        txnRequest["signature"] = [
            "type": "ed25519_signature",
            "public_key": try sender.publicKey().description,
            "signature": signature.description
        ]
        guard let requestFinal = URL(string: "\(self.baseUrl)/transactions") else { throw NSError(domain: "Invalid URL", code: -1) }
        response = try await self.client.decodeUrl(with: requestFinal, txnRequest)
        return response["hash"].stringValue
    }
    
    public func transactionPending(_ txnHash: String) async throws -> Bool {
        guard let url = URL(string: "\(self.baseUrl)/transactions/by_hash/\(txnHash)") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        let response = try await self.client.decodeUrl(with: url)
        return response["type"].stringValue == "pending_transaction"
    }
    
    public func waitForTransaction(_ txnHash: String) async throws {
        var count = 0
        
        repeat {
            if count >= self.clientConfig.transactionWaitInSeconds {
                throw NSError(domain: "Transaction \(txnHash) timed out", code: -1)
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
            count += 1
        } while try await self.transactionPending(txnHash)
        
        guard let url = URL(string: "\(self.baseUrl)/transactions/by_hash/\(txnHash)") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        let response = try await self.client.decodeUrl(with: url)
        guard response["success"].exists(), response["success"].boolValue else {
            throw NSError(domain: "\(response["message"].stringValue) - \(txnHash)", code: -1)
        }
    }
    
    public func createMultiAgentBcsTransaction(
        _ sender: Account,
        _ secondaryAccounts: [Account],
        _ payload: TransactionPayload
    ) async throws -> SignedTransaction {
        let rawTransaction = MultiAgentRawTransaction(
            rawTransaction: try await createBcsTransaction(sender, payload),
            secondarySigners: secondaryAccounts.map { $0.address() }
        )
        let keyedTxn = try rawTransaction.keyed()
        let authenticator = Authenticator(
            authenticator: MultiAgentAuthenticator(
                sender: Authenticator(
                    authenticator: Ed25519Authenticator(
                        publicKey: try sender.publicKey(),
                        signature: try sender.sign(keyedTxn)
                    )
                ),
                secondarySigner: try secondaryAccounts.map {(
                    $0.address(), Authenticator(
                        authenticator: Ed25519Authenticator(
                            publicKey: try $0.publicKey(),
                            signature: try $0.sign(keyedTxn)
                        )
                    )
                )}
            )
        )
        return SignedTransaction(transaction: rawTransaction.inner(), authenticator: authenticator)
    }
    
    public func createBcsTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> RawTransaction {
        return try await RawTransaction(
            sender: sender.address(),
            sequenceNumber: UInt64(self.accountSequenceNumber(sender.address())),
            payload: payload,
            maxGasAmount: UInt64(self.clientConfig.maxGasAmount),
            gasUnitPrice: UInt64(self.clientConfig.gasUnitPrice),
            expirationTimestampSecs: UInt64(Date().timeIntervalSince1970 + Double(self.clientConfig.expirationTtl)),
            chainId: UInt8(self.chainId)
        )
    }
    
    public func createBcsSignedTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> SignedTransaction {
        let rawTransaction = try await self.createBcsTransaction(sender, payload)
        let signature = try sender.sign(try rawTransaction.keyed())
        let authenticator = Authenticator(
            authenticator: Ed25519Authenticator(
                publicKey: try sender.publicKey(),
                signature: signature
            )
        )
        return SignedTransaction(transaction: rawTransaction, authenticator: authenticator)
    }
    
    public func transfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String {
        let payload: [String: Any] = [
            "type": "entry_function_payload",
            "function": "0x1::aptos_account::transfer_coins",
            "type_arguments": ["0x1::aptos_coin::AptosCoin"],
            "arguments": [
                "\(recipient.description)",
                "\(amount)"
            ]
        ]
        return try await self.submitTransaction(sender, payload)
    }
    
    public func bcsTransfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String {
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: recipient, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(amount), encoder: Serializer.u64))
        ]
        
        let payload = try EntryFunction.natural(
            "0x1::aptos_account",
            "transfer_coins",
            [TypeTag(value: try StructTag.fromStr("0x1::aptos_coin::AptosCoin"))],
            transactionArguments
        )
        
        let signedTransaction = try await self.createBcsSignedTransaction(
            sender,
            TransactionPayload(payload: payload)
        )
        return try await self.submitBcsTransaction(signedTransaction)
    }
    
    public func createCollection(_ account: Account, _ name: String, _ description: String, _ uri: String) async throws -> String {
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: description, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: uri, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: MAX_U64, encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(
                value: [false, false, false],
                encoder: Serializer.sequenceSerializer(Serializer.bool)
            ))
        ]
        let payload = try EntryFunction.natural("0x3::token", "create_collection_script", [], transactionArguments)
        let signedTransaction = try await self.createBcsSignedTransaction(account, TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
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
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: collectionName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: description, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(supply), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(supply), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: uri, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: account.address(), encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(1_000_000), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(royaltyPointsPerMillion), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: [false, false, false, false, false], encoder: Serializer.sequenceSerializer(Serializer.bool))),
            AnyTransactionArgument(TransactionArgument(value: [String](), encoder: Serializer.sequenceSerializer(Serializer.str))),
            AnyTransactionArgument(TransactionArgument(value: [Data](), encoder: Serializer.sequenceSerializer(Serializer.toBytes))),
            AnyTransactionArgument(TransactionArgument(value: [String](), encoder: Serializer.sequenceSerializer(Serializer.str)))
        ]
        let payload = try EntryFunction.natural(
            "0x3::token",
            "create_token_script",
            [],
            transactionArguments
        )
        let signedTransaction = try await self.createBcsSignedTransaction(account, TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
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
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: receiver, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: creator, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: collectionName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: tokenName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(propertyVersion), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(amount), encoder: Serializer.u64)),
        ]
        let payload = try EntryFunction.natural("0x3::token_transfers", "offer_script", [], transactionArguments)
        let signedTransaction = try await self.createBcsSignedTransaction(account, TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
    }
    
    public func claimToken(
        _ account: Account,
        _ sender: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> String {
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: sender, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: creator, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: collectionName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: tokenName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(propertyVersion), encoder: Serializer.u64))
        ]
        let payload = try EntryFunction.natural("0x3::token_transfers", "claim_script", [], transactionArguments)
        let signedTransaction = try await self.createBcsSignedTransaction(account, TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
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
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: creatorAddress, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: collectionName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: tokenName, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(propertyVersion), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(amount), encoder: Serializer.u64)),
        ]
        let payload = try EntryFunction.natural("0x3::token", "direct_token_script", [], transactionArguments)
        let signedTransaction = try await self.createMultiAgentBcsTransaction(sender, [receiver], TransactionPayload(payload: payload))
        return try await self.submitBcsTransaction(signedTransaction)
    }
    
    public func getToken(
        _ owner: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> JSON {
        let resource = try await self.accountResource(owner, "0x3::token::TokenStore")
        let tokenStoreHandle = resource["data"]["tokens"]["handle"].stringValue
        let tokenId: [String: Any] = [
            "token_data_id": [
                "creator": creator.hex(),
                "collection": collectionName,
                "name": tokenName
            ],
            "property_version": "\(propertyVersion)"
        ]
        
        return try await self.getTableItem(tokenStoreHandle, "0x3::token::TokenId", "0x3::token:Token", tokenId)
    }
    
    public func getTokenBalance(
        _ owner: AccountAddress,
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> String {
        return try await self.getToken(owner, creator, collectionName, tokenName, propertyVersion)["amount"].stringValue
    }
    
    public func getTokenData(
        _ creator: AccountAddress,
        _ collectionName: String,
        _ tokenName: String,
        _ propertyVersion: Int
    ) async throws -> JSON {
        let resource = try await self.accountResource(creator, "0x3::token::Collections")
        let tokenDataHandle = resource["data"]["token_data"]["handle"].stringValue
        let tokenDataId: [String: Any] = [
            "creator": creator.hex(),
            "collection": collectionName,
            "name": tokenName
        ]
        
        return try await self.getTableItem(tokenDataHandle, "0x3::token::TokenDataId", "0x3::token:TokenData", tokenDataId)
    }
    
    public func getCollection(
        _ creator: AccountAddress,
        _ collectionName: String
    ) async throws -> JSON {
        let resource = try await self.accountResource(creator, "0x3::token::Collections")
        let tokenData = resource["data"]["collection_data"]["handle"].stringValue
        
        return try await self.getTableItem(
            tokenData,
            "0x1::string::String",
            "0x3::token::CollectionData",
            collectionName
        )
    }
}
