//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation

public struct ClientConfig {
    public init(
        expirationTtl: Int = 600,
        gasUnitPrice: Int = 100,
        maxGasAmount: Int = 100_000,
        transactionWaitInSeconds: Int = 20
    ) {
        self.expirationTtl = expirationTtl
        self.gasUnitPrice = gasUnitPrice
        self.maxGasAmount = maxGasAmount
        self.transactionWaitInSeconds = transactionWaitInSeconds
    }
    
    public var expirationTtl: Int
    public var gasUnitPrice: Int
    public var maxGasAmount: Int
    public var transactionWaitInSeconds: Int
}
