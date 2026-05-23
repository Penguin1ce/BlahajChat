//
//  HTTPClient.swift
//  buluaichat
//

import Foundation

final class HTTPClient {
    private let environment: APIEnvironment
    private weak var sessionStore: SessionStore?
    private let urlSession: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        environment: APIEnvironment = .current,
        sessionStore: SessionStore,
        urlSession: URLSession = .shared
    ) {
        self.environment = environment
        self.sessionStore = sessionStore
        self.urlSession = urlSession
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = [], authorized: Bool = true) async throws -> T {
        var request = try makeRequest(path: path, method: "GET", queryItems: queryItems, authorized: authorized)
        request.httpBody = nil
        return try await send(request)
    }

    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body, authorized: Bool = true) async throws -> T {
        var request = try makeRequest(path: path, method: "POST", authorized: authorized)
        request.httpBody = try encoder.encode(body)
        return try await send(request)
    }

    func post<T: Decodable>(_ path: String, authorized: Bool = true) async throws -> T {
        let body = APIEmptyBody()
        return try await post(path, body: body, authorized: authorized)
    }

    private func makeRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        authorized: Bool
    ) throws -> URLRequest {
        var components = URLComponents(url: environment.httpBaseURL.appending(path: path), resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if authorized {
            guard let token = sessionStore?.accessToken else { throw APIError.missingToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.transport("服务器响应无效")
        }

        if httpResponse.statusCode == 401,
           let envelope = try? decoder.decode(APIErrorEnvelope.self, from: data) {
            throw APIError.unauthorized(envelope.error)
        }

        if let response = try? decoder.decode(APIResponse<T>.self, from: data) {
            guard (200..<300).contains(httpResponse.statusCode), response.code == 200 else {
                throw APIError.server(code: response.code, message: response.message)
            }
            guard let data = response.data else {
                throw APIError.emptyData
            }
            return data
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "请求失败"
            throw APIError.server(code: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}

private struct APIEmptyBody: Encodable {}
