//
//  ReadObject.swift
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

import Foundation

public struct ReadObject {
    public static var resourceMap: [String: any ReadObjectProtocol.Type] = [
        Collection.structTag: Collection.self,
        Object.structTag: Object.self,
        PropertyMap.structTag: PropertyMap.self,
        Royalty.structTag: Royalty.self,
        Token.structTag: Token.self,
    ]

    public var resources: [AnyHashableReadObject: Any]

    public init(resources: [AnyHashableReadObject: Any]) {
        self.resources = resources
    }

    public func GetReadObject(_ type: any ReadObjectProtocol.Type) throws -> any ReadObjectProtocol {
        let returnedObjects = self.resources.filter { (key, value) in
            if (key._base as! any ReadObjectProtocol).structTag == type.structTag {
                return true
            }
            return false
        }
        guard !returnedObjects.isEmpty else { throw AptosError.notImplemented }
        let returnedObject = returnedObjects[returnedObjects.keys.first!]!
        return returnedObject as! any ReadObjectProtocol
    }
}
