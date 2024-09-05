//
//  PepperApi.swift
//  
//
//  Created by Marcus Arnett on 9/4/24.
//

public struct PepperApi: NetworkApiProtocol {
    public var mainnet: String? = "https://api.mainnet.aptoslabs.com/keyless/pepper/v0"

    public var testnet: String? = "https://api.testnet.aptoslabs.com/keyless/pepper/v0"

    public var devnet: String? = "https://api.devnet.aptoslabs.com/keyless/pepper/v0"

    // Use the devnet service for local environment
    public var local: String? = "https://api.devnet.aptoslabs.com/keyless/pepper/v0"

    public var custom: String?

    public var mode: NetworkMode

    public init(mode: NetworkMode, custom: String? = nil) {
        self.mode = mode
        self.custom = custom
    }

    public func getUrl() throws -> String {
        switch self.mode {
        case .mainnet:
            return self.mainnet!
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
