//
//  File.swift
//  
//
//  Created by Marcus Arnett on 3/19/24.
//

import Foundation

public struct FeePayerAuthenticator: AuthenticatorProtocol {
    let sender: Authenticator
    let secondarySigners: [(AccountAddress, Authenticator)]
    let feePayer: (AccountAddress, Authenticator)

    public init(
        sender: Authenticator,
        secondarySigners: [(AccountAddress, Authenticator)],
        feePayer: (AccountAddress, Authenticator)
    ) {
        self.sender = sender
        self.secondarySigners = secondarySigners
        self.feePayer = feePayer
    }

    public func feePayerAddress() -> AccountAddress {
        return self.feePayer.0
    }

    public func secondaryAddresses() -> [AccountAddress] {
        return self.secondarySigners.map { $0.0 }
    }

    public func verify(_ data: Data) throws -> Bool {
        if !(try self.sender.verify(data)) {
            return false
        }

        if !(try self.feePayer.1.verify(data)) {
            return false
        }

        return try self.secondarySigners.allSatisfy { try $0.1.verify(data) }
    }

    public static func deserialize(from deserializer: Deserializer) throws -> FeePayerAuthenticator {
        let sender: Authenticator = try Deserializer._struct(deserializer)
        let secondaryAddresses: [AccountAddress] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        let secondaryAuthenticators: [Authenticator] = try deserializer.sequence(valueDecoder: Deserializer._struct)
        let feePayerAddress: AccountAddress = try Deserializer._struct(deserializer)
        let feePayerAuthenticator: Authenticator = try Deserializer._struct(deserializer)

        return FeePayerAuthenticator(
            sender: sender,
            secondarySigners: zip(secondaryAddresses, secondaryAuthenticators).map { $0 },
            feePayer: (feePayerAddress, feePayerAuthenticator)
        )
    }

    public func serialize(_ serializer: Serializer) throws {
        try Serializer._struct(serializer, value: self.sender)
        try serializer.sequence(self.secondarySigners.map { $0.0 }, Serializer._struct)
        try serializer.sequence(self.secondarySigners.map { $0.1 }, Serializer._struct)
        try Serializer._struct(serializer, value: self.feePayer.0)
        try Serializer._struct(serializer, value: self.feePayer.1)
    }

    public func isEqualTo(_ rhs: any AuthenticatorProtocol) -> Bool {
        if rhs is FeePayerAuthenticator {
            let rhsFeePayer = rhs as! FeePayerAuthenticator
            for (lhs, rhsSecondarySigner) in zip(self.secondarySigners, rhsFeePayer.secondarySigners) {
                if lhs != rhsSecondarySigner {
                    return false
                }
            }
            return
                self.sender == rhsFeePayer.sender &&
                self.feePayer == rhsFeePayer.feePayer
        }
        return false
    }
}
