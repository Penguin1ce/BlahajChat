//
//  APIEnvironment.swift
//  buluaichat
//

import Foundation

struct APIEnvironment {
    let httpBaseURL: URL
    let webSocketBaseURL: URL

    static var current: APIEnvironment {
        let info = Bundle.main.infoDictionary ?? [:]
        let http = info["BLAHAJ_HTTP_BASE_URL"] as? String
        let ws = info["BLAHAJ_WS_BASE_URL"] as? String
        return APIEnvironment(
            httpBaseURL: URL(string: http ?? "http://127.0.0.1:8080")!,
            webSocketBaseURL: URL(string: ws ?? "ws://127.0.0.1:8080")!
        )
    }

    func webSocketLoginURL(accessToken: String) -> URL? {
        var components = URLComponents(url: webSocketBaseURL.appending(path: "/ws/wslogin"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "token", value: accessToken)]
        return components?.url
    }
}
