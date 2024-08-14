//
//  DeriveScheme.swift
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

/// Scheme used for deriving account addresses from other data
public enum DeriveScheme: Int, AuthenticationKeyScheme {
    /// Derives an address using an AUID, used for objects
    case DeriveAuid = 251

    /// Derives an address from another object address
    case DeriveObjectAddressFromObject = 252

    /// Derives an address from a GUID, used for objects
    case DeriveObjectAddressFromGuid = 253

    /// Derives an address from seed bytes, used for named objects
    case DeriveObjectAddressFromSeed = 254

    /// Derives an address from seed bytes, used for resource accounts
    case DeriveResourceAccountAddress = 255
}
