//
//  AptosKitProtocol.swift
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

public protocol AptosKitProtocol {
    /// Retrieve an account from the blockchain network by its account address.
    ///
    /// This function makes an asynchronous request to the blockchain network to retrieve an account that matches the
    /// provided account address, and returns an AccountResponse object containing information about the account.
    ///
    /// - Parameters:
    ///    - accountAddress: An AccountAddress object representing the account address of the account to retrieve.
    ///    - ledgerVersion: An optional Int representing the ledger version of the blockchain network to retrieve the account from.
    /// If not provided, the latest ledger version will be used.
    ///
    /// - Throws: An error of type AptosError if there's an issue with the request or the response.
    ///
    /// - Returns: An AccountResponse object containing information about the retrieved account.
    func account(_ accountAddress: AccountAddress, ledgerVersion: Int?) async throws -> AccountResponse

    /// Retrieves the balance of the account at the specified accountAddress on the ledger version provided by ledgerVersion, or on the latest ledger version if ledgerVersion is nil.
    ///
    /// - Parameters:
    ///    - accountAddress: The AccountAddress of the account for which to retrieve the balance.
    ///    - ledgerVersion: Optional. The ledger version on which to retrieve the account balance. If nil, the balance is retrieved on the latest ledger version.
    ///
    /// - Returns: An Int value representing the account balance.
    ///
    /// - Throws: An error of type Error if an issue occurs during the account balance retrieval.
    func accountBalance(_ accountAddress: AccountAddress, _ ledgerVersion: Int?) async throws -> Int

    /// Asynchronously retrieves the current sequence number of the account at the specified address, from the specified ledger version if provided.
    ///
    /// - Parameters:
    ///    - accountAddress: The address of the account to retrieve the sequence number for.
    ///    - ledgerVersion: The ledger version to retrieve the sequence number from, if desired.
    ///
    /// - Returns: An integer representing the current sequence number of the account at the specified address.
    ///
    /// - Throws: An error of type AptosClientError if there was an issue retrieving the account sequence number.
    func accountSequenceNumber(_ accountAddress: AccountAddress, _ ledgerVersion: Int?) async throws -> Int

    /// Retrieves a JSON object containing the specified resource data for an account.
    ///
    /// This function sends an asynchronous request to the Aptos Blockchain to retrieve a JSON object containing
    /// the specified resource data for the given account. The resource type is passed as a string parameter, and
    /// the ledger version is an optional integer value. If the ledger version is not provided, the function will
    /// use the latest ledger version available.
    ///
    /// - Parameters:
    ///    - accountAddress: The address of the account to retrieve the resource data for.
    ///    - resourceType: The resource type to retrieve as a string parameter.
    ///    - ledgerVersion: An optional integer value indicating the ledger version to use. If not provided, the
    /// function will use the latest ledger version available.
    ///
    /// - Returns: A JSON object containing the specified resource data for the given account.
    ///
    /// - Throws: An error if there is an issue with the request or response from the Aptos Blockchain.
    func accountResource(_ accountAddress: AccountAddress, _ resourceType: String, _ ledgerVersion: Int?) async throws -> JSON

    /// Retrieves a specific item from a table stored in the blockchain given the table's handle, key type, value type, and key.
    ///
    /// - Parameters:
    ///    - handle: A string representing the handle of the table from which to retrieve the item.
    ///    - keyType: A string representing the type of the key of the table.
    ///    - valueType: A string representing the type of the value of the table.
    ///    - key: The key of the item to retrieve.
    ///    - ledgerVersion: The version of the ledger to use for the request. If nil, uses the latest ledger version.
    ///
    /// - Throws: An error of type AptosError if the request fails or the response is invalid.
    ///
    /// - Returns: A JSON object representing the retrieved table item.
    func getTableItem(_ handle: String, _ keyType: String, _ valueType: String, _ key: any EncodingContainer, _ ledgerVersion: Int?) async throws -> JSON

    /// Retrieve the aggregated value of a resource of a given account, following the specified aggregator path.
    ///
    /// This function takes an account address, a resource type, and an array of strings representing the aggregator path
    /// to traverse in order to obtain the aggregated value. The function then returns the aggregated value as an integer.
    ///
    /// - Parameters:
    ///    - accountAddress: The account address of the resource to retrieve.
    ///    - resourceType: The type of resource to retrieve.
    ///    - aggregatorPath: An array of strings representing the aggregator path to traverse in order to obtain the
    /// aggregated value.
    ///
    /// - Returns: An integer value representing the aggregated value of the specified resource.
    ///
    /// - Throws: An error if the aggregator value cannot be retrieved from the given parameters.
    func aggregatorValue(_ accountAddress: AccountAddress, _ resourceType: String, _ aggregatorPath: [String]) async throws -> Int

    /// Makes an HTTP GET request to the server's /info endpoint and returns the response body as a deserialized InfoResponse object.
    ///
    /// This function is an asynchronous function that uses await to allow for non-blocking I/O. It makes an HTTP GET request
    /// to the server's /info endpoint, and if successful, returns the response body as a InfoResponse object.
    ///
    /// - Returns: An InfoResponse object containing information about the server and its current state.
    ///
    /// - Throws: An error of type Error if the request fails for any reason, such as an invalid URL or a network error.
    func info() async throws -> InfoResponse

    func simulateBcsTransaction(_ signedTransaction: SignedTransaction, estimateGasUsage: Bool) async throws -> JSON

    /// Simulate a transaction on the Aptos blockchain using the given RawTransaction object and sender account.
    ///
    /// This function sends a POST request to the blockchain's REST API /simulate endpoint with the serialized RawTransaction
    /// object and sender account's signature appended to it. The response from the API call is deserialized into a JSON object
    /// and returned.
    ///
    /// - Parameters:
    ///    - transaction: The RawTransaction object to be simulated.
    ///    - sender: The Account object that will be used to sign the transaction.
    ///
    /// - Throws: An error of type AptosError if the simulation fails or if there's an error with the request or response.
    ///
    /// - Returns: A JSON object representing the response from the /simulate endpoint of the Aptos blockchain REST API.
    func simulateTransaction(_ transaction: RawTransaction, _ sender: Account) async throws -> JSON

    /// Submits a signed transaction to the blockchain.
    ///
    /// - Parameters:
    ///    - signedTransaction: A SignedTransaction object representing the transaction to be submitted.
    ///
    /// - Throws: An error of type AptosError if the submission fails or if there's an error with the request or response.
    ///
    /// - Returns: A string representing the hash of the submitted transaction.
    func submitBcsTransaction(_ signedTransaction: SignedTransaction) async throws -> String

    /// Submit a new transaction to the blockchain network.
    ///
    /// This function creates a new transaction with the given payload and submits it to the blockchain network using
    /// the submitBcsTransaction function. It uses the provided sender account to sign the transaction.
    ///
    /// - Parameters:
    ///    - sender: The account object of the sender of the transaction.
    ///    - payload: A dictionary containing the payload to be sent with the transaction.
    ///
    /// - Returns: A string representation of the transaction hash for the submitted transaction.
    ///
    /// - Throws: An AptosError object that's a failed to serialize the provided payload or failed to submit the transaction
    /// to the blockchain network.
    func submitTransaction(_ sender: Account, _ payload: [String: Any]) async throws -> String

    /// Check whether a transaction with a given hash is still pending.
    ///
    /// This function checks the transaction status of a given transaction hash to determine whether it is still
    /// pending or has been committed. The function queries the transaction's status from the blockchain using
    /// the tx_status endpoint of the REST API.
    ///
    /// - Parameter txnHash: A transaction hash string to check its status.
    ///
    /// - Returns: A boolean value that indicates whether the transaction is still pending or not. True if it is
    /// still pending, false if it has been committed.
    ///
    /// - Throws: An error of type AptosError if an error occurs while checking the transaction status.
    func transactionPending(_ txnHash: String) async throws -> Bool

    /// Waits for a given transaction to be committed on the blockchain.
    ///
    /// This function polls the blockchain at regular intervals until the transaction with the given hash is committed on the blockchain.
    /// If the transaction is not committed within a certain timeout period, an error is thrown. If the transaction is committed, the function returns.
    ///
    /// - Parameter txnHash: The hash of the transaction to wait for.
    ///
    /// - Throws: An error if the transaction is not committed within the timeout period.
    func waitForTransaction(_ txnHash: String) async throws

    /// Creates a multi-agent BCS-encoded transaction that can be used to execute transactions between multiple accounts.
    ///
    /// This function takes a sender account, a list of secondaryAccounts that should also sign the transaction,
    /// and a payload object representing the transaction payload. The payload object should conform to the TransactionPayload protocol.
    /// The function returns a SignedTransaction object that can be submitted to the blockchain for execution.
    ///
    /// - Parameters:
    ///    - sender: An Account object representing the sender of the transaction.
    ///    - secondaryAccounts: An array of Account objects representing the secondary accounts that will also sign the transaction.
    ///    - payload: An object conforming to the TransactionPayload protocol representing the transaction payload.
    ///
    /// - Returns: A SignedTransaction object representing the signed and encoded transaction ready to be submitted to the blockchain.
    func createMultiAgentBcsTransaction(_ sender: Account, _ secondaryAccounts: [Account], _ payload: TransactionPayload) async throws -> SignedTransaction

    /// Creates a new RawTransaction from a sender's account and transaction payload.
    ///
    /// This function takes a sender's account and a transaction payload and attempts to create a new RawTransaction
    /// instance representing the transaction. The function creates the transaction by setting the transaction
    /// expiration time, sender's account sequence number, the maximum gas price and maximum gas amount. It then sets
    /// the transaction script with the transaction payload.
    ///
    /// - Parameters:
    ///    - sender: An instance of an Account object representing the sender's account.
    ///    - payload: An instance of a TransactionPayload object representing the transaction payload.
    ///
    /// - Throws: An error of type AptosError if any of the transaction fields could not be set or if the signature on
    /// the transaction could not be created.
    ///
    /// - Returns: An instance of a RawTransaction object that represents the transaction.
    func createBcsTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> RawTransaction

    /// Creates a signed transaction using the provided sender account and payload data.
    ///
    /// This function takes an Account object for the sender and a TransactionPayload object
    /// for the payload data. It then creates a raw transaction and signs it with the sender's
    /// private key. The resulting signed transaction is returned.
    ///
    /// - Parameters:
    ///    - sender: An Account object for the sender of the transaction.
    ///    - payload: A TransactionPayload object containing the transaction data.
    ///
    /// - Returns: A SignedTransaction object representing the signed transaction.
    ///
    /// - Throws: An AptosError object if there is an error creating or signing the transaction.
    func createBcsSignedTransaction(_ sender: Account, _ payload: TransactionPayload) async throws -> SignedTransaction

    /// Sends a specified amount of a token from the sender's account to the recipient account address.
    ///
    /// - Parameters:
    ///    - sender: The sender's account.
    ///    - recipient: The recipient's account address.
    ///    - amount: The amount of the token to transfer.
    ///
    /// - Returns: The transaction hash of the submitted transaction.
    ///
    /// - Throws: An error if the transfer fails for any reason.
    func transfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String

    /// Transfers a given amount of Aptos Coins from the sender account to the recipient account using the BCS protocol.
    ///
    /// - Parameters:
    ///    - sender: The Account initiating the transfer.
    ///    - recipient: The AccountAddress receiving the transfer.
    ///    - amount: The amount of Aptos Coins to transfer.
    ///
    /// - Returns: A String representing the transaction hash for the submitted transfer transaction.
    ///
    /// - Throws: An error of type Error if an error occurs while creating or submitting the transaction.
    func bcsTransfer(_ sender: Account, _ recipient: AccountAddress, _ amount: Int) async throws -> String

    /// Creates a new collection under the given account with the specified name, description and URI.
    ///
    /// - Parameters:
    ///    - account: An Account object representing the account under which to create the collection.
    ///    - name: A String representing the name of the collection to be created.
    ///    - description: A String representing the description of the collection to be created.
    ///    - uri: A String representing the URI of the collection to be created.
    ///
    /// - Returns: A String representing the transaction hash of the transaction that created the collection.
    ///
    /// - Throws: An Error if the operation fails for any reason.
    func createCollection(_ account: Account, _ name: String, _ description: String, _ uri: String) async throws -> String

    /// Creates a new token within a specified collection and returns the transaction hash.
    ///
    /// - Parameters:
    ///   - account: An Account object for the transaction sender.
    ///   - collectionName: A string representing the name of the collection.
    ///   - name: A string representing the name of the new token.
    ///   - description: A string describing the new token.
    ///   - supply: An integer representing the total supply of the new token.
    ///   - uri: A string representing the URI of the new token.
    ///   - royaltyPointsPerMillion: An integer representing the royalty points per million for the new token.
    ///
    /// - Returns: A string representing the transaction hash.
    ///
    /// - Throws: An AptosError of type `Error`.
    func createToken(_ account: Account, _ collectionName: String, _ name: String, _ description: String, _ supply: Int, _ uri: String, _ royaltyPointsPerMillion: Int) async throws -> String

    /// Offer a token to another account on the blockchain.
    ///
    /// This function creates an `OfferTokenScript` instance with the specified parameters, and submits
    /// it as a transaction on the blockchain using the `submitScript` function. This transaction
    /// represents the offer being made from the `account` address to the `receiver` address. The
    /// `creator` address, `collectionName`, and `tokenName` parameters identify the specific token
    /// being offered. The `propertyVersion` parameter specifies the version of the token being offered.
    /// The `amount` parameter is the quantity of the token being offered.
    ///
    /// - Parameters:
    ///   - account: The account making the offer.
    ///   - receiver: The address of the account receiving the offer.
    ///   - creator: The address of the creator of the token being offered.
    ///   - collectionName: The name of the collection the token being offered belongs to.
    ///   - tokenName: The name of the token being offered.
    ///   - propertyVersion: The version of the token being offered.
    ///   - amount: The quantity of the token being offered.
    ///
    /// - Returns: A `String` representing the transaction hash of the submitted transaction.
    ///
    /// - Throws: An error of type `Error` if there is a problem submitting the transaction.
    func offerToken(_ account: Account, _ receiver: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int, _ amount: Int) async throws -> String

    /// Claims an unclaimed token from a given collection, on behalf of the specified account.
    ///
    /// This function creates a transaction that invokes the "0x3::token::TokenHolder" module's "claim_token" function. It requires the sender's (i.e., the one who wants to claim the token) account to be the receiver account.
    ///
    /// - Parameters:
    ///   - account: The account object that represents the receiver's account.
    ///   - sender: The address of the account that wants to claim the token.
    ///   - creator: The address of the account that created the token.
    ///   - collectionName: The name of the collection that the token belongs to.
    ///   - tokenName: The name of the token that will be claimed.
    ///   - propertyVersion: The version of the token's properties.
    ///
    /// - Returns: A string representation of the transaction hash.
    /// - Throws: An error of type `AptosError` if the transaction fails to execute or if the token is not found.
    func claimToken(_ account: Account, _ sender: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> String

    /// Transfers a specified amount of a specific token from the sender's account to the receiver's account.
    ///
    /// - Parameters:
    ///   - sender: The account that is sending the tokens.
    ///   - receiver: The account that is receiving the tokens.
    ///   - creatorAddress: The account address of the token creator.
    ///   - collectionName: The name of the token collection.
    ///   - tokenName: The name of the token.
    ///   - propertyVersion: The version of the token's properties.
    ///   - amount: The amount of the token to be transferred.
    ///
    /// - Returns: A string representing the transaction hash of the transfer.
    ///
    /// - Throws: An error of type `AptosError` if there was an issue creating the transaction or submitting it.
    func directTransferToken(_ sender: Account, _ receiver: Account, _ creatorAddress: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int, _ amount: Int) async throws -> String

    /// Retrieves the token information, including the balance of the specified token for the specified owner.
    ///
    /// - Parameters:
    ///    - owner: The AccountAddress of the owner.
    ///    - creator: The AccountAddress of the token creator.
    ///    - collectionName: The name of the token collection.
    ///    - tokenName: The name of the token.
    ///    - propertyVersion: The version of the token property.
    ///
    /// - Returns: A JSON object containing the token balance for the specified owner. The balance is returned as a string value.
    func getToken(_ owner: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> JSON

    /// Get the token balance for the specified owner and token name.
    ///
    /// This function queries the blockchain to retrieve the token balance for the specified owner and token name.
    /// The owner is identified by their account address, while the token is identified by the creator's address,
    /// the collection name, and the token name.
    ///
    /// - Parameters:
    ///    - owner: The account address of the token owner.
    ///    - creator: The account address of the token creator.
    ///    - collectionName: The name of the token collection.
    ///    - tokenName: The name of the token.
    ///    - propertyVersion: The version of the token property.
    ///
    /// - Returns: A string representing the token balance of the specified owner and token name.
    func getTokenBalance(_ owner: AccountAddress, _ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> String

    /// Retrieves the data associated with a specific token in a named collection.
    ///
    /// This function sends a request to the blockchain to retrieve the data associated with the token
    /// having the specified tokenName in the named collection with the specified collectionName created by the
    /// account with the given creator address. The returned data includes information about the token's properties,
    /// as well as any metadata that was associated with the token when it was created.
    ///
    /// - Parameters:
    ///    - creator: The address of the account that created the named collection.
    ///    - collectionName: The name of the named collection containing the token.
    ///    - tokenName: The name of the token whose data is being retrieved.
    ///    - propertyVersion: The version of the schema that defines the token's properties.
    ///
    /// - Returns: A JSON object containing the data associated with the specified token in the named collection.
    /// If there is no token with the specified name in the named collection, the function throws an error.
    ///
    /// - Throws: An error of type AptosError, if the request to retrieve the token data fails, or if the
    /// returned data is not in the expected format.
    func getTokenData(_ creator: AccountAddress, _ collectionName: String, _ tokenName: String, _ propertyVersion: Int) async throws -> JSON

    /// Retrieves the data for a specific named collection for a given creator account.
    ///
    /// - Parameters:
    ///    - creator: The account address of the creator of the collection.
    ///    - collectionName: The name of the collection to retrieve.
    ///
    /// - Returns: A JSON object representing the data associated with the named collection.
    ///
    /// - Throws: An error of type AptosError if the request fails or the response is malformed.
    func getCollection(_ creator: AccountAddress, _ collectionName: String) async throws -> JSON

    /// Publishes a package to the blockchain. A package is a bundle of Move modules and associated metadata that can be published together.
    ///
    /// - Parameters:
    ///    - sender: The Account object that will be used to publish the package.
    ///    - packageMetadata: The metadata associated with the package as Data.
    ///    - modules: An array of Move modules as Data.
    ///
    /// - Returns: A String representing the transaction hash of the package publishing transaction.
    func publishPackage(_ sender: Account, _ packageMetadata: Data, _ modules: [Data]) async throws -> String
}
