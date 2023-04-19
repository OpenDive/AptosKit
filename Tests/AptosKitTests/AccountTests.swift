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
}
