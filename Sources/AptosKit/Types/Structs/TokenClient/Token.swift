//
//  Token.swift
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

import SwiftyJSON

public struct Token: ReadObjectProtocol {
    public let collection: AccountAddress
    public let index: Int
    public let description: String
    public let name: String
    public let uri: String
    
    public static let structTag: String = "0x4::token::Token"
    
    public init(
        collection: AccountAddress,
        index: Int,
        description: String,
        name: String,
        uri: String
    ) {
        self.collection = collection
        self.index = index
        self.description = description
        self.name = name
        self.uri = uri
    }
    
    public static func parse(_ resource: JSON) throws -> Token {
        return Token(
            collection: try AccountAddress.fromHex(resource["collection"].stringValue),
            index: resource["index"].intValue,
            description: resource["description"].stringValue,
            name: resource["name"].stringValue,
            uri: resource["uri"].stringValue
        )
    }
}
