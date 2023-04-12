//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation

public struct ClientConfig {
    public var expirationTtl: Int = 600
    public var gasUnitPrice: Int = 100
    public var maxGasAmount: Int = 100_000
    public var transactionWaitInSeconds: Int = 20
}
