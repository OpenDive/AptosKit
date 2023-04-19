//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public struct RotatingProofChallenge {
    let typeInfoAccountAddress: AccountAddress
    let typeInfoModuleName: String = "account"
    let typeInfoStructName: String = "RotationProofChallenge"
    let sequence_number: Int
    let originator: AccountAddress
    let currentAuthKey: AccountAddress
    let newPublicKey: Data
    
    init(
        sequence_number: Int,
        originator: AccountAddress,
        currentAuthKey: AccountAddress,
        newPublicKey: Data
    ) throws {
        self.sequence_number = sequence_number
        self.originator = originator
        self.currentAuthKey = currentAuthKey
        self.newPublicKey = newPublicKey
        
        self.typeInfoAccountAddress = try AccountAddress.fromHex("0x1")
    }
    
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
