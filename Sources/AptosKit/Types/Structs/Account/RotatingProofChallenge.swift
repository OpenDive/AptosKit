//
//  RotatingProofChallenge.swift
//  AptosKit
//
//  Copyright (c) 2023 OpenDive
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

/// Used for the rotating proof challenge for the Aptos Blockchain
public struct RotatingProofChallenge {
    /// The account used for the challenge (i.e., 0x1)
    let typeInfoAccountAddress: AccountAddress

    /// The name of the module for the challenge
    let typeInfoModuleName: String = "account"

    /// The struct's name
    let typeInfoStructName: String = "RotationProofChallenge"

    /// The current sequence number of the account
    let sequence_number: Int

    /// The account  currently wanting to be changed over
    let originator: AccountAddress

    /// The account  currently wanting to be changed over
    let currentAuthKey: AccountAddress

    /// The public key of the new account
    let newPublicKey: Data

    public init(
        sequence_number: Int,
        originator: AccountAddress,
        currentAuthKey: AccountAddress,
        newPublicKey: Data
    ) throws {
        self.sequence_number = sequence_number
        self.originator = originator
        self.currentAuthKey = currentAuthKey
        self.newPublicKey = newPublicKey
        
        self.typeInfoAccountAddress = try AccountAddress.fromStrRelaxed("0x1")
    }

    /// Serialize the account object using a provided Serializer object.
    ///
    /// This function takes a Serializer object and serializes the account object's properties, which includes the
    /// typeInfoAccountAddress, typeInfoModuleName, typeInfoStructName, sequence_number, originator, currentAuthKey and newPublicKey
    /// The Serializer object serializes values in the order specified, which is the order of the calls in this function.
    ///
    /// - Parameter serializer: The Serializer object to serialize the account object with.
    ///
    /// - Throws: Any error encountered while serializing the account object's properties.
    public func serialize(_ serializer: Serializer) throws {
        try self.typeInfoAccountAddress.serialize(serializer)
        try Serializer.str(serializer, self.typeInfoModuleName)
        try Serializer.str(serializer, self.typeInfoStructName)
        try Serializer.u64(serializer, UInt64(self.sequence_number))
        try self.originator.serialize(serializer)
        try self.currentAuthKey.serialize(serializer)
        try Serializer.toBytes(serializer, self.newPublicKey)
    }
}
