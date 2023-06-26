//
//  AptosTokenClient.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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
import SwiftyJSON

public struct AptosTokenClient {
    public let client: RestClient
    
    public func readObject(address: AccountAddress) async throws -> ReadObject {
        var resources: [AnyHashableReadObject: Any] = [:]
        
        let readResources = try await client.accountResources(address)
        for resource in readResources.arrayValue {
            if let type = resource["type"].string,
               let resourceClass = ReadObject.resourceMap[type] {
                let parsedResource = try resourceClass.parse(resource["data"])
                resources[AnyHashableReadObject(parsedResource)] = parsedResource
            }
        }
        
        return ReadObject(resources: resources)
    }
    
    public func createCollectionPayload(
        _ description: String,
        _ maxSupply: Int,
        _ name: String,
        _ uri: String,
        _ mutableDescription: Bool,
        _ mutableRoyalty: Bool,
        _ mutableUri: Bool,
        _ mutableTokenDescription: Bool,
        _ mutableTokenName: Bool,
        _ mutableTokenProperties: Bool,
        _ mutableTokenUri: Bool,
        _ tokensBurnableByCreator: Bool,
        _ tokensFreezableByCreator: Bool,
        _ royaltyNumerator: Int,
        _ royaltyDenominator: Int
    ) throws -> TransactionPayload {
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: description, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: maxSupply, encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: uri, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: mutableDescription, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableRoyalty, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableUri, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableTokenDescription, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableTokenName, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableTokenProperties, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: mutableTokenUri, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: tokensBurnableByCreator, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: tokensFreezableByCreator, encoder: Serializer.bool)),
            AnyTransactionArgument(TransactionArgument(value: royaltyNumerator, encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: royaltyDenominator, encoder: Serializer.u64))
        ]
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "create_collection",
            [],
            transactionArguments
        )
        
        return try TransactionPayload(payload: payload)
    }
    
    public func createCollection(
        _ creator: Account,
        _ description: String,
        _ maxSupply: Int,
        _ name: String,
        _ uri: String,
        _ mutableDescription: Bool,
        _ mutableRoyalty: Bool,
        _ mutableUri: Bool,
        _ mutableTokenDescription: Bool,
        _ mutableTokenName: Bool,
        _ mutableTokenProperties: Bool,
        _ mutableTokenUri: Bool,
        _ tokensBurnableByCreator: Bool,
        _ tokensFreezableByCreator: Bool,
        _ royaltyNumerator: Int,
        _ royaltyDenominator: Int
    ) async throws -> String {
        let payload = try self.createCollectionPayload(
            description,
            maxSupply,
            name,
            uri,
            mutableDescription,
            mutableRoyalty,
            mutableUri,
            mutableTokenDescription,
            mutableTokenName,
            mutableTokenProperties,
            mutableTokenUri,
            tokensBurnableByCreator,
            tokensFreezableByCreator,
            royaltyNumerator,
            royaltyDenominator
        )
        
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, payload)
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func mintTokenPayload(
        _ collection: String,
        _ description: String,
        _ name: String,
        _ uri: String,
        _ properties: PropertyMap
    ) throws -> TransactionPayload {
        let propertyTuple = try properties.toTuple()
        
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: collection, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: description, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: uri, encoder: Serializer.str)),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.0,
                    encoder: Serializer.sequenceSerializer(Serializer.str)
                )
            ),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.1,
                    encoder: Serializer.sequenceSerializer(Serializer.str)
                )
            ),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.2,
                    encoder: Serializer.sequenceSerializer(Serializer.toBytes)
                )
            )
        ]
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "mint",
            [],
            transactionArguments
        )
        
        return try TransactionPayload(payload: payload)
    }
    
    public func mintToken(
        _ creator: Account,
        _ collection: String,
        _ description: String,
        _ name: String,
        _ uri: String,
        _ properties: PropertyMap
    ) async throws -> String {
        let payload = try self.mintTokenPayload(collection, description, name, uri, properties)
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, payload)
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func mintSoulBoundToken(
        _ creator: Account,
        _ collection: String,
        _ description: String,
        _ name: String,
        _ uri: String,
        _ properties: PropertyMap,
        _ soulBoundTo: AccountAddress
    ) async throws -> String {
        let propertyTuple = try properties.toTuple()
        
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: collection, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: description, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str)),
            AnyTransactionArgument(TransactionArgument(value: uri, encoder: Serializer.str)),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.0,
                    encoder: Serializer.sequenceSerializer(Serializer.str)
                )
            ),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.1,
                    encoder: Serializer.sequenceSerializer(Serializer.str)
                )
            ),
            AnyTransactionArgument(
                TransactionArgument(
                    value: propertyTuple.2,
                    encoder: Serializer.sequenceSerializer(Serializer.toBytes)
                )
            ),
            AnyTransactionArgument(TransactionArgument(value: soulBoundTo, encoder: Serializer._struct))
        ]
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "mint_soul_bound",
            [],
            transactionArguments
        )
        
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func burnToken(
        _ creator: Account,
        _ token: AccountAddress
    ) async throws -> String {
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "burn",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            [AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct))]
        )
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func freezeToken(
        _ creator: Account,
        _ token: AccountAddress
    ) async throws -> String {
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "freeze_transfer",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            [AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct))]
        )
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func unfreezeToken(
        _ creator: Account,
        _ token: AccountAddress
    ) async throws -> String {
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "unfreeze_transfer",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            [AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct))]
        )
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func addTokenProperty(
        _ creator: Account,
        _ token: AccountAddress,
        _ prop: Property
    ) async throws -> String {
        var transactionArguments = [AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct))]
        transactionArguments.append(contentsOf: try prop.toTransactionArguments())
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "add_property",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            transactionArguments
        )
        
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func removeTokenProperty(
        _ creator: Account,
        _ token: AccountAddress,
        _ name: String
    ) async throws -> String {
        let transactionArguments = [
            AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct)),
            AnyTransactionArgument(TransactionArgument(value: name, encoder: Serializer.str))
        ]
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "remove_property",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            transactionArguments
        )
        
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
    
    public func updateTokenProperty(
        _ creator: Account,
        _ token: AccountAddress,
        _ prop: Property
    ) async throws -> String {
        var transactionArguments = [AnyTransactionArgument(TransactionArgument(value: token, encoder: Serializer._struct))]
        transactionArguments.append(contentsOf: try prop.toTransactionArguments())
        
        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "update_property",
            [TypeTag(value: StructTag.fromStr("0x4::token::Token"))],
            transactionArguments
        )
        
        let signedTransaction = try await self.client.createBcsSignedTransaction(creator, TransactionPayload(payload: payload))
        return try await self.client.submitBcsTransaction(signedTransaction)
    }
}
