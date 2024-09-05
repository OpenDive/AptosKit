//  swift-tools-version: 5.9
//
//  Package.swift
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

import PackageDescription

let package = Package(
    name: "AptosKit",
    platforms: [.iOS(.v16), .macOS(.v13), .watchOS(.v6), .tvOS(.v13), .visionOS(.v1)],
    products: [
        .library(
            name: "AptosKit",
            targets: ["AptosKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hyugit/UInt256.git", from: "0.2.2"),
        .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.7"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.2"),
        .package(url: "https://github.com/tesseract-one/Bip39%2eswift.git", from: "0.1.1"),
        .package(url: "https://github.com/tesseract-one/Blake2%2eswift.git", from: "0.2.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
        .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "secp256k1"
        ),
        .target(
            name: "AptosKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "UInt256", package: "UInt256"),
                .product(name: "ed25519swift", package: "ed25519swift"),
                .product(name: "SwiftyJSON", package: "swiftyjson"),
                .product(name: "CryptoSwift", package: "cryptoswift"),
                .product(name: "Bip39", package: "Bip39%2eswift"),
                .product(name: "AnyCodable", package: "AnyCodable"),
                .product(name: "Blake2", package: "Blake2%2eswift"),
                .product(name: "JWTDecode", package: "JWTDecode.swift"),
                "secp256k1"
            ]
        ),
        .testTarget(
            name: "AptosKitTests",
            dependencies: ["AptosKit"],
            path: "Tests",
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
