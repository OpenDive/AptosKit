//
//  File.swift
//  
//
//  Created by Marcus Arnett on 4/12/23.
//

import Foundation
import SwiftyJSON

// Extensions used to help better streamline the main Holodex class.
// Most are private to help with having better Access Control.
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

        let decoded = try decoder.decode(type, from: data)
        return decoded
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
        body: Data? = nil
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
    
    public func decodeUrl(with url: URL, _ method: HTTPMethod = .get) async throws -> JSON {
        let result = try await self.asyncData(with: url, method: method)
        return JSON(result)
    }
    
    public func decodeUrl(with url: URL, _ body: [String: Any]) async throws -> JSON {
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        let data = try await self.asyncData(
            with: url, method: .post,
            body: jsonData
        )
        return try await self.decodeData(with: data)
    }
    
    public func decodeUrl(with url: URL, _ headers: [String: String], _ body: Data) async throws -> JSON {
        let data = try await self.asyncData(
            with: url, method: .post,
            headers: headers, body: body
        )
        return try await self.decodeData(with: data)
    }
}
