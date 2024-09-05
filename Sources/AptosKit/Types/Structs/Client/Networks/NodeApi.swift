//
//  NodeApi.swift
//  
//
//  Created by Marcus Arnett on 9/4/24.
//

public struct NodeApi: NetworkApiProtocol {
    public var mainnet: String? = "https://api.mainnet.aptoslabs.com/v1"

    public var testnet: String? = "https://api.testnet.aptoslabs.com/v1"

    public var devnet: String? = "https://api.devnet.aptoslabs.com/v1"

    public var local: String? = "http://127.0.0.1:8080/v1"

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
