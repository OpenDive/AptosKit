//
//  FaucetApi.swift
//  
//
//  Created by Marcus Arnett on 9/4/24.
//

public struct FaucetApi: NetworkApiProtocol {
    public var mainnet: String? = nil

    public var testnet: String? = "https://faucet.testnet.aptoslabs.com"

    public var devnet: String? = "https://faucet.devnet.aptoslabs.com"

    public var local: String? = "http://127.0.0.1:8081"

    public var custom: String?

    public var mode: NetworkMode

    public init(mode: NetworkMode, custom: String? = nil) {
        self.mode = mode
        self.custom = custom
    }

    public func getUrl() throws -> String {
        switch self.mode {
        case .mainnet:
            throw AptosError.invalidEndpoint
        case .testnet:
            return self.testnet!
        case .devnet:
            return self.devnet!
        case .local:
            return self.local!
        case .custom:
            guard let custom else {
                throw AptosError.invalidEndpoint
            }
            return custom
        }
    }
}
