//
//  KeylessClient.swift
//  
//
//  Created by Marcus Arnett on 9/4/24.
//

import Foundation
import AnyCodable
import SwiftyJSON

public struct KeylessClient {
    public var pepperApi: PepperApi
    public var proverApi: ProverApi
    public var restClient: RestClient

    public init(
        restClient: RestClient,
        pepperApi: PepperApi? = nil,
        proverApi: ProverApi? = nil
    ) {
        self.pepperApi = pepperApi ?? PepperApi(mode: .devnet)
        self.proverApi = proverApi ?? ProverApi(mode: .devnet)
        self.restClient = restClient
    }

    public func getPepper(
        jwt: String,
        ephemeralKeyPair: EphemeralKeyPair,
        uidKey: String? = nil,
        derivationPath: String? = nil
    ) async throws -> Data {
        let body: [String: AnyCodable] = [
            "jwt_b64": AnyCodable(jwt),
            "epk": AnyCodable(ephemeralKeyPair.publicKey.hex),
            "exp_date_secs": AnyCodable(ephemeralKeyPair.expiryDateSecs),
            "epk_blinder": AnyCodable(ephemeralKeyPair.blinder.hexEncodedString()),
            "uid_key": AnyCodable(uidKey),
            "derivation_path": AnyCodable(derivationPath)
        ]
        guard let request = URL(string: "\(try self.pepperApi.getUrl())/fetch") else {
            throw AptosError.invalidUrl(url: "\(try self.pepperApi.getUrl())/fetch")
        }

        return try await JSON(self.restClient.client.decodeUrl(with: request, body)).rawData()
    }
}

//public func simulateTransactionWithGasEstimate(_ transaction: RawTransaction, _ sender: Account) async throws -> JSON {
//    let authenticator = try Authenticator(
//        authenticator: Ed25519Authenticator(
//            publicKey: try sender.publicKey(),
//            signature: Signature(signature: Data(repeating: 0, count: 64))
//        )
//    )
//    let signedTransaction = SignedTransaction(transaction: transaction, authenticator: authenticator)
//    let params: [String: String] = [
//        "estimate_gas_unit_price": "true",
//        "estimate_max_gas_amount": "true"
//    ]
//    let header = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
//    guard let request = URL(string: "\(try clientConfig.nodeNetwork.getUrl())/transactions/simulate") else { throw AptosError.invalidUrl(url: "\(try clientConfig.nodeNetwork.getUrl())/transactions/simulate") }
//    return try await self.client.decodeUrl(
//        with: request,
//        header,
//        try signedTransaction.bytes(),
//        params
//    )
//}
