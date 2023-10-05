//
//  URLSession.swift
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
import SwiftyJSON

extension URLSession {
    /// Uses URLRequest to set up a HTTPMethod, and implement default values for the method cases.
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    /// Decode a data object using `JSONDecoder.decode()`.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - data: `Data` input object.
    ///   - keyDecodingStrategy: Default is `.useDefaultKeys`.
    ///   - dataDecodingStrategy: Default is `.deferredToData`.
    ///   - dateDecodingStrategy: Default is `.deferredToDate`.
    /// - Returns: Decoded data of `T` type.
    public func decodeData<T: Decodable>(
        _ type: T.Type = T.self,
        with data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        do {
            let decoded = try decoder.decode(type, from: data)
            return decoded
        } catch {
            let decoded = try decoder.decode(AptosRestClientError.self, from: data)
            throw decoded
        }
    }

    /// Uses Swift 5.5's new `Async` `Await` handlers to decode input data.
    /// - Parameters:
    ///   - type: The type that the data will decode to.
    ///   - url: The input url of type `URL` that will be fetched.
    ///   - keyDecodingStrategy: Default is `.useDefaultKeys`.
    ///   - dataDecodingStrategy: Default is `.deferredToData`.
    ///   - dateDecodingStrategy: Default is `.deferredToDate`.
    /// - Returns: Decoded data of `T` type.
    private func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let (data, _) = try await data(from: url)

        return try await decodeData(
            with: data,
            keyDecodingStrategy: keyDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            dateDecodingStrategy: dateDecodingStrategy
        )
    }

    /// Takes a `URL` input, along with header information, and converts it into a `URLRequest`;
    /// and fetches the data using an `Async` `Await` wrapper for the older `dataTask` handler.
    /// - Parameters:
    ///   - url: `URL` to convert to a `URLRequest`.
    ///   - method: Input can be either a `.get` or a `.post` method, with the default being `.get`.
    ///   - headers: Header data for the request that uses a `[string:string]` dictionary,
    ///   and the default is set to an empty dictionary.
    ///   - body: Body data that defaults to `nil`.
    /// - Returns: The data that was fetched typed as a `Data` object.
    public func asyncData(
        with url: URL,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil,
        params: [String: String] = [:]
    ) async throws -> Data {
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body

        headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        var queryItmes: [URLQueryItem] = []
        params.forEach { (key, value) in
            queryItmes.append(URLQueryItem(name: key, value: value))
        }
        request.url?.append(queryItems: queryItmes)

        return try await asyncData(with: request)
    }

    /// An Async Await wrapper for the older `dataTask` handler.
    /// - Parameter request: `URLRequest` to be fetched from.
    /// - Returns: A Data object fetched from the` URLRequest`.
    private func asyncData(with request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { (con: CheckedContinuation<Data, Error>) in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    con.resume(throwing: error)
                } else if let data = data {
                    con.resume(returning: data)
                } else {
                    con.resume(returning: Data())
                }
            }

            task.resume()
        }
    }

    /// Decode a `URL` to the type `T` using either `asyncData()` for the Production Server;
    /// or using `decode()` for the Mock Server.
    /// - Parameters:
    ///   - type: The type of `T` that the data will decode to.
    ///   - url: The input url of type `URL` that will be fetched.
    ///   - apiKey: The API Key for use with the Production Server.
    /// - Returns: The decoded object of type `T`.
    public func decodeUrl<T: Decodable>(
        _ type: T.Type = T.self,
        with url: URL
    ) async throws -> T {
        return try await self.decode(
            from: url,
            keyDecodingStrategy: .useDefaultKeys
        )
    }

    /// Decodes the contents of the specified URL into a JSON object using the specified HTTP method.
    ///
    /// - Parameters:
    ///    - url: The URL to decode.
    ///    - method: The HTTP method to use for the request, with a default value of .get.
    ///
    /// - Returns: The decoded JSON object.
    ///
    /// - Throws: An error if the decoding process fails.
    public func decodeUrl(with url: URL, _ method: HTTPMethod = .get) async throws -> JSON {
        let result = try await self.asyncData(with: url, method: method)
        return JSON(result)
    }

    /// Decodes the contents of the specified URL into a `JSON` object using the specified HTTP method and request body.
    ///
    /// - Parameters:
    ///   - url: The URL to decode.
    ///   - body: The request body as a dictionary of key-value pairs.
    ///
    /// - Returns: The decoded `JSON` object.
    ///
    /// - Throws: An error if the decoding process fails.
    public func decodeUrl(with url: URL, _ body: [String: Any]) async throws -> JSON {
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        let data = try await self.asyncData(
            with: url, method: .post,
            body: jsonData
        )
        return try await self.decodeData(with: data)
    }
    
    /// Decodes the contents of the specified URL into a `JSON` object using the specified HTTP method and request body.
    ///
    /// - Parameters:
    ///   - url: The URL to decode.
    ///   - body: The request body as a dictionary of key-value pairs.
    ///
    /// - Returns: The decoded `JSON` object.
    ///
    /// - Throws: An error if the decoding process fails.
    public func decodeUrl(with url: URL, _ headers: [String: String], _ body: Data, _ param: [String: String]) async throws -> JSON {
        let data = try await self.asyncData(
            with: url, method: .post,
            headers: headers, body: body, params: param
        )
        return try await self.decodeData(with: data)
    }

    /// Decodes the contents of the specified URL into a `JSON` object using the specified HTTP headers and request body.
    ///
    /// - Parameters:
    ///   - url: The URL to decode.
    ///   - headers: The HTTP headers to include in the request.
    ///   - body: The request body as `Data`.
    ///
    /// - Returns: The decoded `JSON` object.
    ///
    /// - Throws: An error if the decoding process fails.
    public func decodeUrl(with url: URL, _ headers: [String: String], _ body: Data) async throws -> JSON {
        let data = try await self.asyncData(
            with: url, method: .post,
            headers: headers, body: body
        )
        return try await self.decodeData(with: data)
    }
}
