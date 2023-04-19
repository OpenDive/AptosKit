//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/19/23.
//

import XCTest
import Foundation
@testable import AptosKit

final class AccountTests: XCTestCase {
    func testThatLoadAndStoreMethodsWorkAsIntended() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)
        try "".write(to: fileURL, atomically: true, encoding: .utf8)
        
        let start = try Account.generate()
        try start.store(fileURL.relativePath)
        let load = try Account.load(fileURL.relativePath)
        
        XCTAssertEqual(start, load)
        XCTAssertEqual(start.address().hex(), try start.authKey())
    }
    
    func testThatKeysAreWorkingAsIntended() throws {
        guard let message = "test message".data(using: .utf8) else {
            XCTFail("Invalid Data")
            return
        }
        let account = try Account.generate()
        let signature = try account.sign(message)
        
        XCTAssertTrue(try account.publicKey().verify(data: message, signature: signature))
    }
    
    func testThatRotationProofChallengeWorksAsInteneded() throws {
        let originatingAccount = try Account.loadKey("005120c5882b0d492b3d2dc60a8a4510ec2051825413878453137305ba2d644b")
        let targetAccount = try Account.loadKey("19d409c191b1787d5b832d780316b83f6ee219677fafbd4c0f69fee12fdcdcee")
        
        let rotationProofChallenge = try RotatingProofChallenge(
            sequence_number: 1234,
            originator: originatingAccount.address(),
            currentAuthKey: originatingAccount.address(),
            newPublicKey: try targetAccount.publicKey().key
        )
        
        let ser = Serializer()
        try rotationProofChallenge.serialize(ser)
        let rotationProofChallengeBcs = ser.output().hexEncodedString()
        
        let expectedBytes =
            "0000000000000000000000000000000000000000000000000000000000000001076163636f756e7416526f746174696f6e50726f6f664368616c6c656e6765d20400000000000015b67a673979c7c5dfc8d9c9f94d02da35062a19dd9d218087bd9076589219c615b67a673979c7c5dfc8d9c9f94d02da35062a19dd9d218087bd9076589219c620a1f942a3c46e2a4cd9552c0f95d529f8e3b60bcd444086379ace35e4458b9f22"
        
        XCTAssertEqual(rotationProofChallengeBcs, expectedBytes)
    }
}
