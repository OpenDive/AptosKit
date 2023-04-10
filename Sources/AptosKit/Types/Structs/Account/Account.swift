//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct Account: Equatable {
    public let accountAddress: AccountAddress
    public let privateKey: PrivateKey
    
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return
            lhs.accountAddress == rhs.accountAddress &&
            lhs.privateKey == rhs.privateKey
    }
    
    public static func generate() throws -> Account {
        let privateKey = try PrivateKey.random()
        let accountAddress = try AccountAddress.fromKey(privateKey.publicKey())
        return Account(accountAddress: accountAddress, privateKey: privateKey)
    }
    
    public static func loadKey(_ key: String) throws -> Account {
        let privateKey = PrivateKey.fromHex(key)
        let accountAddress = try AccountAddress.fromKey(privateKey.publicKey())
        return Account(accountAddress: accountAddress, privateKey: privateKey)
    }
    
    public static func load(_ path: String) throws -> Account {
        let fileURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: fileURL)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "Invalid JSON data", code: 0, userInfo: nil)
        }
            
        guard let accountAddressHex = json["account_address"] as? String else {
            throw NSError(domain: "Missing account_address key", code: 0, userInfo: nil)
        }
        guard let privateKeyHex = json["private_key"] as? String else {
            throw NSError(domain: "Missing private_key key", code: 0, userInfo: nil)
        }
            
        let accountAddress = try AccountAddress.fromHex(accountAddressHex)
        let privateKey = PrivateKey.fromHex(privateKeyHex)
            
        return Account(accountAddress: accountAddress, privateKey: privateKey)
    }
    
    public func store(_ path: String) throws {
        let data: [String: String] = [
            "account_address": self.accountAddress.hex(),
            "private_key": self.privateKey.hex()
        ]

        let fileURL = URL(fileURLWithPath: path)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        try jsonData.write(to: fileURL)
    }
    
    public func address() -> AccountAddress {
        return self.accountAddress
    }
    
    public func authKey() throws -> String {
        return try AccountAddress.fromKey(self.privateKey.publicKey()).hex()
    }
    
    public func sign(_ data: Data) throws -> Signature {
        return try self.privateKey.sign(data: data)
    }
    
    public func publicKey() throws -> PublicKey {
        return try self.privateKey.publicKey()
    }
}
