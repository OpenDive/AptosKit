//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/20/23.
//

import Foundation

public struct Wallet: Hashable {
    public let passphrase: [String]
    public let account: Account
    
    public init(passphrase: [String], account: Account) {
        self.passphrase = passphrase
        self.account = account
    }
    
    public init() throws {
        self.account = try Account.generate()
        self.passphrase = try Mnemonic.toMnemonic([UInt8](self.account.privateKey.key))
    }
    
    public init(account: Account) throws {
        self.account = account
        self.passphrase = try Mnemonic.toMnemonic([UInt8](self.account.privateKey.key))
    }
    
    public init(passphrase: [String]) throws {
        self.account = try Account.loadKey(Data(try Mnemonic.toEntropy(passphrase)).hexEncodedString())
        self.passphrase = passphrase
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.account.privateKey.key.hexEncodedString())
    }
}
