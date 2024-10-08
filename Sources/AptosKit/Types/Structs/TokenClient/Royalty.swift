//
//  Royalty.swift
//  AptosKit
//
//  Copyright (c) 2024 OpenDive
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

public struct Royalty: ReadObjectProtocol {
    public let numerator: Int
    public let denominator: Int
    public let payeeAddress: AccountAddress

    public static let structTag: String = "0x4::royalty::Royalty"
    public let structTag: String = "0x4::royalty::Royalty"

    public init(
        numerator: Int,
        denominator: Int,
        payeeAddress: AccountAddress
    ) {
        self.numerator = numerator
        self.denominator = denominator
        self.payeeAddress = payeeAddress
    }

    public static func parse(_ resource: JSON) throws -> Royalty {
        return Royalty(
            numerator: resource["numerator"].intValue,
            denominator: resource["denominator"].intValue,
            payeeAddress: try AccountAddress.fromStrRelaxed(resource["payee_address"].stringValue)
        )
    }
}
