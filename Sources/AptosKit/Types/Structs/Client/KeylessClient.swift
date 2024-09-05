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

    public func getProof(
        jwt: String,
        ephemeralKeyPair: EphemeralKeyPair,
        pepperIn: Data? = nil,
        uidKeyIn: String? = nil
    ) async throws -> ZeroKnowledgeSignature {
        let uidKey = uidKeyIn ?? "sub"
        var pepper: Data = Data()
        
        if pepperIn == nil {
            pepper = try await self.getPepper(jwt: jwt, ephemeralKeyPair: ephemeralKeyPair, uidKey: uidKey)
        } else {
            pepper = pepperIn!
        }

        guard pepper.count == KeylessAccount.PEPPER_LENGTH else {
            throw AptosError.notImplemented
        }

        let keyConfig = try await self.getKeylessConfig()

        guard keyConfig.maxExpHorizonSecs >= ephemeralKeyPair.expiryDateSecs else {
            throw AptosError.expiredEpheremalKeyPair
        }

        let body: [String: AnyCodable] = [
            "jwt_b64": AnyCodable(jwt),
            "epk": AnyCodable(ephemeralKeyPair.publicKey.hex),
            "epk_blinder": AnyCodable(ephemeralKeyPair.blinder.hexEncodedString()),
            "exp_date_secs": AnyCodable(ephemeralKeyPair.expiryDateSecs),
            "exp_horizon_secs": AnyCodable(keyConfig.maxExpHorizonSecs),
            "pepper": AnyCodable(pepper.hexEncodedString()),
            "uid_key": AnyCodable(uidKey),
        ]
        guard let request = URL(string: "\(try self.proverApi.getUrl())/prove") else {
            throw AptosError.invalidUrl(url: "\(try self.proverApi.getUrl())/prove")
        }

//        export type ProverResponse = {
//          proof: { a: string; b: string; c: string };
//          public_inputs_hash: string;
//          training_wheels_signature: string;
//        };
        let res = try await JSON(self.restClient.client.decodeUrl(with: request, body))

        let proofPoints = res["proof"]
        let groth16Zkp = try Groth16Zkp(
            a: proofPoints["a"].rawData(),
            b: proofPoints["b"].rawData(),
            c: proofPoints["c"].rawData()
        )

        let signedProof = try ZeroKnowledgeSignature(
            proof: ZkProof(
                proof: groth16Zkp,
                variant: .Groth16
            ), 
            expHorizonSecs: keyConfig.maxExpHorizonSecs,
            trainingWheelsSignature: EphemeralSignature(
                hexSignature: res["training_wheels_signature"].stringValue
            )
        )

        return signedProof
    }

    public func getKeylessConfig(
        ledgerVersion: Int? = nil
    ) async throws -> KeylessConfiguration {
        let config = try await self.getKeylessConfigurationResource(ledgerVersion: ledgerVersion)
        let vk = try await self.getGroth16VerificationKeyResource(ledgerVersion: ledgerVersion)

        return try KeylessConfiguration.create(
            verificationKey: vk,
            maxExpHorizonSecs: config["max_exp_horizon_secs"].intValue
        )
    }

//    export type Groth16VerificationKeyResponse = {
//      alpha_g1: string;
//      beta_g2: string;
//      delta_g2: string;
//      gamma_abc_g1: [string, string];
//      gamma_g2: string;
//    };
    public func getGroth16VerificationKeyResource(
        ledgerVersion: Int? = nil
    ) async throws -> JSON {
        let resourceType = "0x1::keyless_account::Groth16VerificationKey"
        return try await self.restClient.accountResource(AccountAddress.fromStr("0x1"), resourceType, ledgerVersion)
    }

//    export type KeylessConfigurationResponse = {
//      max_commited_epk_bytes: number;
//      max_exp_horizon_secs: string;
//      max_extra_field_bytes: number;
//      max_iss_val_bytes: number;
//      max_jwt_header_b64_bytes: number;
//      max_signatures_per_txn: number;
//      override_aud_vals: string[];
//      training_wheels_pubkey: { vec: string[] };
//    };
    public func getKeylessConfigurationResource(
        ledgerVersion: Int? = nil
    ) async throws -> JSON {
        let resourceType = "0x1::keyless_account::Configuration"
        return try await self.restClient.accountResource(AccountAddress.fromStr("0x1"), resourceType, ledgerVersion)
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
