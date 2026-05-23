//
//  BlahajAPIClient.swift
//  buluaichat
//

import Foundation

final class BlahajAPIClient {
    private let http: HTTPClient
    private let session: SessionStore

    init(session: SessionStore, environment: APIEnvironment = .current) {
        self.session = session
        self.http = HTTPClient(environment: environment, sessionStore: session)
    }

    @discardableResult
    func requestEmailCode(email: String) async throws -> String {
        try await http.post("/auth/getcode", body: EmailRequest(email: email), authorized: false)
    }

    @discardableResult
    func register(email: String, password: String, emailCode: String, nickname: String) async throws -> APIUserDTO {
        try await http.post(
            "/auth/register",
            body: RegisterRequest(email: email, password: password, emailCode: emailCode, nickname: nickname),
            authorized: false
        )
    }

    @discardableResult
    func login(email: String, password: String) async throws -> APILoginResponseDTO {
        let response: APILoginResponseDTO = try await http.post(
            "/auth/login",
            body: LoginRequest(email: email, password: password),
            authorized: false
        )
        save(response.token)
        return response
    }

    func refreshToken() async throws {
        guard let refreshToken = session.refreshToken else {
            throw APIError.missingToken
        }
        let response: APIRefreshResponseDTO = try await http.post(
            "/auth/refresh",
            body: RefreshRequest(refreshToken: refreshToken),
            authorized: false
        )
        save(response.token)
    }

    func logout() async throws {
        let _: APIOKDTO = try await authorized {
            try await http.post(
                "/auth/logout",
                body: LogoutRequest(refreshToken: session.refreshToken),
                authorized: true
            )
        }
    }

    func me() async throws -> APIMeResponseDTO {
        try await authorized {
            try await http.get("/api/me")
        }
    }

    func listConversations() async throws -> [APIConversationDTO] {
        try await authorized {
            try await http.get("/api/conversations")
        }
    }

    func createC2CConversation(peerUID: UInt64) async throws -> APIConversationDTO {
        try await authorized {
            try await http.post("/api/conversations/c2c", body: C2CConversationRequest(peerUid: peerUID))
        }
    }

    func listMessages(conversationID: String, beforeID: UInt64, limit: Int) async throws -> APIMessagePageDTO {
        try await authorized {
            try await http.get(
                "/api/conversations/\(conversationID)/messages",
                queryItems: [
                    URLQueryItem(name: "before_id", value: "\(beforeID)"),
                    URLQueryItem(name: "limit", value: "\(limit)")
                ]
            )
        }
    }

    func listFriends() async throws -> APIFriendListDTO {
        try await authorized {
            try await http.get("/api/friends")
        }
    }

    @discardableResult
    func applyFriend(toUID: UInt64, reason: String) async throws -> APIFriendApplyCreateDTO {
        try await authorized {
            try await http.post("/api/friends/apply", body: FriendApplyRequest(toUid: toUID, reason: reason))
        }
    }

    func listFriendApplies() async throws -> APIFriendApplyListDTO {
        try await authorized {
            try await http.get("/api/friends/applies")
        }
    }

    func acceptFriendApply(id: UInt64) async throws -> APIConversationDTO {
        try await authorized {
            try await http.post("/api/friends/applies/\(id)/accept")
        }
    }

    func rejectFriendApply(id: UInt64) async throws {
        let _: APIOKDTO = try await authorized {
            try await http.post("/api/friends/applies/\(id)/reject")
        }
    }

    private func save(_ token: APITokenPairDTO) {
        session.accessToken = token.accessToken
        session.refreshToken = token.refreshToken
    }

    private func authorized<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch APIError.unauthorized {
            try await refreshToken()
            return try await operation()
        }
    }
}
