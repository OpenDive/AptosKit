//
//  FaucetApi.swift
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
