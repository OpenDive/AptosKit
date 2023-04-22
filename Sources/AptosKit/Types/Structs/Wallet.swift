//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/20/23.
//

import Foundation
import ed25519swift

public class Wallet: Hashable {
    private static let derivationPath: String = "m/44'/637'/x'/0'/0'"
    
    private var _seed: Data? = nil
    private var _ed25519Bip32: Ed25519BIP32
    private var seedMode: SeedMode = .Ed25519Bip32
    private var passphrase: String = ""
    public var mnemonic: Mnemonic
    public var account: Account
    
    public init(wordCount: Int, wordList: [String], passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = Mnemonic(wordcount: wordCount, wordlist: wordList)
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)
        
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        
        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw NSError(domain: "Seed mode: \(seedMode.rawValue) cannot derive Ed25519 based BIP32 keys.", code: -1)
            }
            
            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
            
        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }
        
        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    public init(mnemonic: Mnemonic, passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = mnemonic
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)
        
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        
        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw NSError(domain: "Seed mode: \(seedMode.rawValue) cannot derive Ed25519 based BIP32 keys.", code: -1)
            }
            
            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
            
        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }
        
        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    public init(phrase: [String], passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        self.mnemonic = try Mnemonic(phrase: phrase, passphrase: passphrase)
        self.passphrase = passphrase
        self.seedMode = seedMode
        let seed = mnemonic.seed!
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)
        
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        
        if self.seedMode == .Ed25519Bip32 {
            if self.seedMode != .Ed25519Bip32 {
                throw NSError(domain: "Seed mode: \(seedMode.rawValue) cannot derive Ed25519 based BIP32 keys.", code: -1)
            }
            
            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
            
        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
        }
        
        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    public init(seed: Data, passphrase: String = "", seedMode: SeedMode = .Ed25519Bip32) throws {
        if seed.count != 64 {
            throw NSError(domain: "Invalid Seed Length", code: -1)
        }
        self.passphrase = passphrase
        self.seedMode = seedMode
        self._seed = seed
        self._ed25519Bip32 = Ed25519BIP32(seed: seed)
        self.mnemonic = try Mnemonic(entropy: [UInt8](seed), passphrase: passphrase)
        
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        
        if self.seedMode == .Ed25519Bip32 {
            let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(0))
            var account: Data = Data()
            (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
        } else {
            (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: seed[0..<32])
            
        }
        
        self.account = Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.mnemonic.passphrase)
    }
    
    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return
            lhs.mnemonic == rhs.mnemonic
    }
    
    public func getAccount(index: Int) throws -> Account {
        if self.seedMode != .Ed25519Bip32 {
            throw NSError(domain: "Seed mode: \(seedMode.rawValue) cannot derive Ed25519 based BIP32 keys.", code: -1)
        }
        
        let path: String = Wallet.derivationPath.replacingOccurrences(of: "x", with: String(index))
        var account: Data = Data()
        var privateKey: Data = Data()
        var publicKey: Data = Data()
        (key: account, chainCode: _) = try _ed25519Bip32.derivePath(path: path)
        (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: account)
        return Account(
            accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
            privateKey: PrivateKey(key: privateKey)
        )
    }
    
    public func deriveMnemonicSeed() -> Data {
        if _seed != nil {
            return _seed!
        }
        
        return mnemonic.seed!
    }
    
    private func initializeFirstAccount() throws {
        if let _seed {
            if self.seedMode == .Ed25519Bip32 {
                self._ed25519Bip32 = Ed25519BIP32(seed: _seed)
                self.account = try getAccount(index: 0)
            } else {
                var privateKey: Data = Data()
                var publicKey: Data = Data()
                (privateKey: privateKey, publicKey: publicKey) = Wallet.edKeyPairFromSeed(seed: _seed[0..<32])
                self.account = Account(
                    accountAddress: try AccountAddress.fromKey(try PublicKey(data: publicKey)),
                    privateKey: PrivateKey(key: privateKey)
                )
            }
        }
    }
    
    private static func edKeyPairFromSeed(seed: Data) -> (privateKey: Data, publicKey: Data) {
        return (privateKey: seed, publicKey: Data(Ed25519.calcPublicKey(secretKey: [UInt8](seed))))
    }
}
