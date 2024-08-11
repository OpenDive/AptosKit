//
//  AptosTokenClient.swift
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
import SwiftyJSON

/// A wrapper around reading and mutating AptosTokens also known as Token Objects
public struct AptosTokenClient {
    /// REST Client used for communicating with the Aptos Blockchain
    public let client: RestClient
    
    public init(client: RestClient) {
        self.client = client
    }

    /// Fetches and returns a `ReadObject` from the given account address.
    ///
    /// This function communicates asynchronously with a client to fetch account resources. For each fetched resource,
    /// it parses the resource data according to the resource type found in the resourceMap of the `ReadObject` class.
    /// The parsed resource is then stored in a dictionary using an `AnyHashableReadObject` as the key. Finally, a
    /// `ReadObject` is created with the constructed dictionary and returned.
    ///
    /// - Parameter address: The address of the account from which the resources are to be read.
    ///
    /// - Returns: A `ReadObject` that contains all the parsed resources of the account at the provided address.
    ///
    /// - Throws: If the function fails to fetch resources from the account, parse resource data, or initialize the
    /// `AnyHashableReadObject`, it propagates the error thrown by the underlying calls to `client.accountResources(address)`,
    /// `resourceClass.parse(resource["data"])`, or the `AnyHashableReadObject` initializer, respectively.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result
    /// that is produced at some point in the future. When you call a function that’s marked with the async keyword,
    /// you need to use the await keyword.
    public func readObject(address: AccountAddress) async throws -> ReadObject {
        var resources: [AnyHashableReadObject: Any] = [:]
        let readResources = try await client.accountResources(address)
        guard readResources["error_code"].string == nil else {
            throw NSError(domain: readResources["error_code"].stringValue, code: -1)
        }
        for resource in readResources.arrayValue {
            if
                let type = resource["type"].string,
                let resourceClass = ReadObject.resourceMap[type] 
            {
                let parsedResource = try resourceClass.parse(resource["data"])
                resources[AnyHashableReadObject(parsedResource)] = parsedResource
            }
        }
        return ReadObject(resources: resources)
    }

    /// Constructs a `TransactionPayload` for creating a new token collection.
    ///
    /// The function accepts several parameters defining the properties of the new token collection, such as its name,
    /// description, maximum supply, and various mutability flags. These parameters are then encoded into `TransactionArguments`
    /// using appropriate Serializers based on their types.
    ///
    /// An `EntryFunction` object is then created with the given token module address, the function name to be invoked ("create_collection"),
    /// and the constructed transaction arguments. Finally, a `TransactionPayload` is created with this entry function and returned.
    ///
    /// - Parameters:
    ///     - description: The description of the new token collection.
    ///     - maxSupply: The maximum supply of tokens in the collection.
    ///     - name: The name of the new token collection.
    ///     - uri: The URI for the token collection.
    ///     - mutableDescription: A boolean flag indicating whether the description of the token collection can be changed after creation.
    ///     - mutableRoyalty: A boolean flag indicating whether the royalty of the token collection can be changed after creation.
    ///     - mutableUri: A boolean flag indicating whether the URI of the token collection can be changed after creation.
    ///     - mutableTokenDescription: A boolean flag indicating whether the description of a token in the collection can be changed after creation.
    ///     - mutableTokenName: A boolean flag indicating whether the name of a token in the collection can be changed after creation.
    ///     - mutableTokenProperties: A boolean flag indicating whether the properties of a token in the collection can be changed after creation.
    ///     - mutableTokenUri: A boolean flag indicating whether the URI of a token in the collection can be changed after creation.
    ///     - tokensBurnableByCreator: A boolean flag indicating whether tokens in the collection can be burned by the creator.
    ///     - tokensFreezableByCreator: A boolean flag indicating whether tokens in the collection can be frozen by the creator.
    ///     - royaltyNumerator: The numerator of the royalty fraction.
    ///     - royaltyDenominator: The denominator of the royalty fraction.
    ///
    /// - Returns: A `TransactionPayload` object that represents the payload for the transaction to create a new token collection.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction` or `TransactionPayload` fails.
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
            AnyTransactionArgument(TransactionArgument(value: UInt64(maxSupply), encoder: Serializer.u64)),
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
            AnyTransactionArgument(TransactionArgument(value: UInt64(royaltyNumerator), encoder: Serializer.u64)),
            AnyTransactionArgument(TransactionArgument(value: UInt64(royaltyDenominator), encoder: Serializer.u64))
        ]

        let payload = try EntryFunction.natural(
            "0x4::aptos_token",
            "create_collection",
            [],
            transactionArguments
        )

        return try TransactionPayload(payload: payload)
    }

    /// Creates a new token collection using the given parameters.
    ///
    /// The function generates a transaction payload using the createCollectionPayload method with the provided parameters.
    /// It then submits this payload to a client to create a new token collection. The function operates asynchronously and returns
    /// the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account to be used to create the collection.
    ///     - description: The description of the new token collection.
    ///     - maxSupply: The maximum supply of tokens in the collection.
    ///     - name: The name of the new token collection.
    ///     - uri: The URI for the token collection.
    ///     - mutableDescription: A boolean flag indicating whether the description of the token collection can be changed after creation.
    ///     - mutableRoyalty: A boolean flag indicating whether the royalty of the token collection can be changed after creation.
    ///     - mutableUri: A boolean flag indicating whether the URI of the token collection can be changed after creation.
    ///     - mutableTokenDescription: A boolean flag indicating whether the description of a token in the collection can be changed after creation.
    ///     - mutableTokenName: A boolean flag indicating whether the name of a token in the collection can be changed after creation.
    ///     - mutableTokenProperties: A boolean flag indicating whether the properties of a token in the collection can be changed after creation.
    ///     - mutableTokenUri: A boolean flag indicating whether the URI of a token in the collection can be changed after creation.
    ///     - tokensBurnableByCreator: A boolean flag indicating whether tokens in the collection can be burned by the creator.
    ///     - tokensFreezableByCreator: A boolean flag indicating whether tokens in the collection can be frozen by the creator.
    ///     - royaltyNumerator: The numerator of the royalty fraction.
    ///     - royaltyDenominator: The denominator of the royalty fraction.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to create a new token collection.
    ///
    /// - Throws: This function throws an error if creating the payload, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Constructs a TransactionPayload for minting a new token within a specified collection.
    ///
    /// The function accepts several parameters defining the properties of the new token, such as its name, description, URI,
    /// and additional properties, which are then encoded into TransactionArguments using appropriate Serializers based on their types.
    ///
    /// An EntryFunction object is then created with the given token module address, the function name to be invoked ("mint"),
    /// and the constructed transaction arguments. Finally, a TransactionPayload is created with this entry function and returned.
    ///
    /// - Parameters:
    ///     - collection: The collection in which the new token will be minted.
    ///     - description: The description of the new token.
    ///     - name: The name of the new token.
    ///     - uri: The URI for the new token.
    ///     - properties: A PropertyMap object representing the additional properties of the new token.
    ///
    /// - Returns: A `TransactionPayload` object that represents the payload for the transaction to mint a new token.
    ///
    /// - Throws: This function throws an error if converting the properties to a tuple, creating the EntryFunction,
    /// or TransactionPayload fails.
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

    /// Mints a new token within a specified collection using the given parameters.
    ///
    /// The function generates a transaction payload using the `mintTokenPayload` method with the provided parameters.
    /// It then submits this payload to a client to mint a new token. The function operates asynchronously and returns
    /// the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account to be used to mint the token.
    ///     - collection: The collection in which the new token will be minted.
    ///     - description: The description of the new token.
    ///     - name: The name of the new token.
    ///     - uri: The URI for the new token.
    ///     - properties: A `PropertyMap` object representing the additional properties of the new token.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to mint a new token.
    ///
    /// - Throws: This function throws an error if creating the payload, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Mints a new soul-bound token within a specified collection using the given parameters.
    ///
    /// A soul-bound token is a token that is irrevocably tied to a specific account (soul-bound to an account).
    ///
    /// The function constructs a transaction payload with several parameters defining the properties of the new soul-bound token,
    /// which are then encoded into TransactionArguments using appropriate Serializers based on their types. An additional
    /// TransactionArgument is created for the account to which the token will be soul-bound.
    ///
    /// An `EntryFunction` object is then created with the given token module address, the function name to be invoked ("mint_soul_bound"),
    /// and the constructed transaction arguments. This entry function is used to create a `TransactionPayload `which is then signed
    /// and submitted to the client.
    ///
    /// - Parameters:
    ///     - creator: The account to be used to mint the soul-bound token.
    ///     - collection: The collection in which the new token will be minted.
    ///     - description: The description of the new soul-bound token.
    ///     - name: The name of the new soul-bound token.
    ///     - uri: The URI for the new soul-bound token.
    ///     - properties: A PropertyMap object representing the additional properties of the new soul-bound token.
    ///     - soulBoundTo: The address of the account to which the token will be soul-bound.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to mint a new soul-bound token.
    ///
    /// - Throws: This function throws an error if converting the properties to a tuple, creating the `EntryFunction`,
    /// signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    
    /// Burns a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "burn", a `TypeTag` for the type of the token,
    /// and a `TransactionArgument` for the token to be burnt.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account from which the token will be burnt.
    ///     - token: The address of the token to be burnt.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to burn a token.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Freezes the transfer of a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "freeze_transfer", a `TypeTag` for the type of the token,
    /// and a `TransactionArgument` for the token to be frozen.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account from which the token's transfer will be frozen.
    ///     - token: The address of the token to be frozen.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to freeze a token's transfer.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Unfreezes the transfer of a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "unfreeze_transfer", a `TypeTag` for the type of the token,
    /// and a `TransactionArgument` for the token to be unfrozen.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account from which the token's transfer will be unfrozen.
    ///     - token: The address of the token to be unfrozen.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to unfreeze a token's transfer.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Adds a property to a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "add_property", a `TypeTag` for the type of the token,
    /// and `TransactionArguments` for the token to which the property will be added and the property itself.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account which owns the token and will add the property to it.
    ///     - token: The address of the token to which the property will be added.
    ///     - prop: The property that will be added to the token.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to add a property to a token.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, converting the property to transaction arguments,
    /// signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Removes a property from a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "remove_property", a `TypeTag` for the type of the token,
    /// and `TransactionArguments` for the token from which the property will be removed and the name of the property.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account which owns the token and will remove the property from it.
    ///     - token: The address of the token from which the property will be removed.
    ///     - name: The name of the property that will be removed from the token.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to remove a property from a token.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    /// Updates a property of a token from the given creator's account.
    ///
    /// The function constructs a transaction payload with the `EntryFunction` named "update_property", a `TypeTag` for the type of the token,
    /// and `TransactionArguments` for the token on which the property will be updated and the property itself.
    ///
    /// The constructed payload is then signed and submitted for execution on the client. The function operates asynchronously
    /// and returns the result of the transaction submission.
    ///
    /// - Parameters:
    ///     - creator: The account which owns the token and will update the property.
    ///     - token: The address of the token which will have its property updated.
    ///     - prop: The property that will be updated on the token.
    ///
    /// - Returns: A `String` that represents the response from the transaction submission to update a property on a token.
    ///
    /// - Throws: This function throws an error if creating the `EntryFunction`, signing the transaction, or submitting the transaction fails.
    ///
    /// Note: This function is marked with the async keyword, which means it returns a future that represents a result that is produced
    /// at some point in the future. When you call a function that’s marked with the async keyword, you need to use the await keyword.
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

    public func tokensMintedFromTransaction(_ txnHash: String) async throws -> [AccountAddress] {
        let output = try await self.client.transactionByHash(txnHash)
        var mints: [AccountAddress] = []

        for event in output["events"].arrayValue {
            if
                event["type"] != "0x4::collection::MintEvent" ||
                event["type"] != "0x4::collection::Mint"
            { continue }
            mints.append(try AccountAddress.fromStrRelaxed(event["data"]["token"].stringValue))
        }

        return mints
    }
}
