//
//  AnyHashableReadObject.swift
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

struct AnyHashableReadObject: Hashable {
    private let _base: Any
    private let _hashValue: Int
    private let _equals: (Any) -> Bool

    init<T: ReadObjectProtocol>(_ base: T) where T: Hashable {
        self._base = base
        self._hashValue = base.hashValue
        self._equals = { ($0 as? T)?.hashValue == base.hashValue }
    }

    static func == (lhs: AnyHashableReadObject, rhs: AnyHashableReadObject) -> Bool {
        return lhs._equals(rhs._base)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
