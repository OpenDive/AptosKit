//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/10/23.
//

import Foundation

public protocol TypeProtcol: KeyProtocol {
    /// Returns the type variant the class represents
    /// - Returns: An Integer value that represents the class's type tag
    func variant() -> Int
}
