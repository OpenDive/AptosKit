//
//  NetworkApiProtocol.swift
//  
//
//  Created by Marcus Arnett on 9/4/24.
//

public protocol NetworkApiProtocol {
    var mainnet: String? { get }
    var testnet: String? { get }
    var devnet: String? { get }
    var local: String? { get }
    var custom: String? { get set }
}
