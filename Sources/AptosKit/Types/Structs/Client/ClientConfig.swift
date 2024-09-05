//
//  ClientConfig.swift
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

/// Client Configuration for the REST client
public struct ClientConfig {
    public var expirationTtl: Int
    public var gasUnitPrice: Int
    public var maxGasAmount: Int
    public var transactionWaitInSeconds: Int
    public var http2: Bool
    public var apiKey: String?
    public var nodeNetwork: NodeApi

    public init(
        expirationTtl: Int = 600,
        gasUnitPrice: Int = 100,
        maxGasAmount: Int = 100_000,
        transactionWaitInSeconds: Int = 20,
        http2: Bool = false,
        apiKey: String? = nil,
        nodeNetwork: NodeApi? = nil
    ) {
        self.expirationTtl = expirationTtl
        self.gasUnitPrice = gasUnitPrice
        self.maxGasAmount = maxGasAmount
        self.transactionWaitInSeconds = transactionWaitInSeconds
        self.http2 = http2
        self.apiKey = apiKey
        self.nodeNetwork = nodeNetwork ?? NodeApi(mode: .devnet)
    }
}
