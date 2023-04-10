//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/9/23.
//

import Foundation

public class Signature: Equatable {
    static let LENGTH: Int = 64

    var signature: Data

    init(signature: Data) {
        self.signature = signature
    }

    public static func == (lhs: Signature, rhs: Signature) -> Bool {
        return lhs.signature == rhs.signature
    }

    func data() -> Data {
        return self.signature
    }

    static func deserialize(deserializer: inout Data) -> Signature? {
        let signatureBytes = deserializer.prefix(LENGTH)
        deserializer.removeFirst(LENGTH)

        if signatureBytes.count != LENGTH {
            return nil
        }

        return Signature(signature: signatureBytes)
    }

    func serialize(serializer: inout Data) {
        serializer.append(contentsOf: self.signature)
    }
}
