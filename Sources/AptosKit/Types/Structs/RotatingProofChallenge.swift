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
    let typeInfoStructName: String = "RotatingProofChallenge"
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
        try self.typeInfoAccountAddress.serialize(serializer: serializer)
        serializer.str(self.typeInfoModuleName)
        serializer.str(self.typeInfoStructName)
        serializer.u64(UInt64(self.sequence_number))
        try self.originator.serialize(serializer: serializer)
        try self.currentAuthKey.serialize(serializer: serializer)
        serializer.toBytes(self.newPublicKey)
    }
}
