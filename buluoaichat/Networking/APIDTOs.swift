//
//  APIDTOs.swift
//  buluaichat
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
}

struct APIErrorEnvelope: Decodable {
    let error: String
}

struct APIEmptyResponse: Decodable {}

struct APIUserDTO: Decodable {
    let id: UInt64
    let email: String
    let nickname: String
    let avatarUrl: String?
    let createdAt: String?
    let updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case nickname
        case avatarUrl
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyUInt64(forKey: .id)
        email = try container.decodeString(forKey: .email)
        nickname = try container.decodeString(forKey: .nickname)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }

    var displayName: String {
        nickname.isEmpty ? email : nickname
    }

    var avatarURL: URL? {
        avatarUrl.flatMap(URL.init(string:))
    }
}

struct APITokenPairDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    private enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeRequiredString(forKey: .accessToken)
        refreshToken = try container.decodeRequiredString(forKey: .refreshToken)
        expiresIn = try container.decodeLossyInt(forKey: .expiresIn)
    }
}

struct APILoginResponseDTO: Decodable {
    let user: APIUserDTO?
    let token: APITokenPairDTO

    private enum CodingKeys: String, CodingKey {
        case user
        case token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(APIUserDTO.self, forKey: .user)

        if let nestedToken = try container.decodeIfPresent(APITokenPairDTO.self, forKey: .token) {
            token = nestedToken
        } else {
            token = try APITokenPairDTO(from: decoder)
        }
    }
}

struct APIRefreshResponseDTO: Decodable {
    let token: APITokenPairDTO

    private enum CodingKeys: String, CodingKey {
        case token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let nestedToken = try container.decodeIfPresent(APITokenPairDTO.self, forKey: .token) {
            token = nestedToken
        } else {
            token = try APITokenPairDTO(from: decoder)
        }
    }
}

struct APIMeResponseDTO: Decodable {
    let user: APIUserDTO

    private enum CodingKeys: String, CodingKey {
        case user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let nestedUser = try container.decodeIfPresent(APIUserDTO.self, forKey: .user) {
            user = nestedUser
        } else {
            user = try APIUserDTO(from: decoder)
        }
    }
}

struct APIConversationDTO: Decodable {
    let convId: String
    let type: String
    let peerKey: String
    let name: String
    let avatar: String?
    let ownerId: UInt64
    let lastMsgId: String?
    let lastMsgAt: Int64
    let lastReadMsgId: String?
    let unread: Int?
    let pinned: Bool?
    let muted: Bool?

    private enum CodingKeys: String, CodingKey {
        case convId
        case type
        case peerKey
        case name
        case avatar
        case ownerId
        case lastMsgId
        case lastMsgAt
        case lastReadMsgId
        case unread
        case pinned
        case muted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        convId = try container.decodeRequiredString(forKey: .convId)
        type = try container.decodeString(forKey: .type, default: "c2c")
        peerKey = try container.decodeString(forKey: .peerKey)
        name = try container.decodeString(forKey: .name)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        ownerId = try container.decodeLossyUInt64IfPresent(forKey: .ownerId) ?? 0
        lastMsgId = try container.decodeIfPresent(String.self, forKey: .lastMsgId)
        lastMsgAt = try container.decodeMilliseconds(forKey: .lastMsgAt)
        lastReadMsgId = try container.decodeIfPresent(String.self, forKey: .lastReadMsgId)
        unread = try container.decodeIfPresent(Int.self, forKey: .unread)
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned)
        muted = try container.decodeIfPresent(Bool.self, forKey: .muted)
    }

    var avatarURL: URL? {
        avatar.flatMap(URL.init(string:))
    }
}

struct APIMessageDTO: Decodable {
    let id: UInt64
    let msgId: String
    let convId: String
    let fromUid: UInt64
    let type: String
    let content: JSONValue
    let replyTo: String?
    let status: UInt8
    let createdAt: Int64

    var displayText: String {
        switch type {
        case "text":
            return content["text"]?.stringValue ?? ""
        case "image":
            return "[图片]"
        case "file":
            return content["name"]?.stringValue.map { "[文件] \($0)" } ?? "[文件]"
        case "audio":
            return "[语音]"
        default:
            return "[消息]"
        }
    }
}

struct APIMessagePageDTO: Decodable {
    let items: [APIMessageDTO]
    let nextBeforeId: UInt64
    let hasMore: Bool
}

struct APIFriendListDTO: Decodable {
    let items: [APIFriendDTO]
}

struct APIFriendDTO: Decodable {
    let uid: UInt64
    let email: String
    let nickname: String
    let avatarUrl: String?

    private enum CodingKeys: String, CodingKey {
        case uid
        case email
        case nickname
        case avatarUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decodeLossyUInt64(forKey: .uid)
        email = try container.decodeString(forKey: .email)
        nickname = try container.decodeString(forKey: .nickname)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
    }

    var displayName: String {
        nickname.isEmpty ? email : nickname
    }

    var avatarURL: URL? {
        avatarUrl.flatMap(URL.init(string:))
    }
}

struct APIFriendApplyListDTO: Decodable {
    let items: [APIFriendApplyDTO]
}

struct APIFriendApplyDTO: Decodable {
    let id: UInt64
    let fromUid: UInt64
    let toUid: UInt64
    let status: String
    let reason: String
    let createdAt: Int64

    private enum CodingKeys: String, CodingKey {
        case id
        case fromUid
        case toUid
        case status
        case reason
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyUInt64(forKey: .id)
        fromUid = try container.decodeLossyUInt64(forKey: .fromUid)
        toUid = try container.decodeLossyUInt64(forKey: .toUid)
        status = try container.decodeString(forKey: .status, default: "pending")
        reason = try container.decodeString(forKey: .reason)
        createdAt = try container.decodeMilliseconds(forKey: .createdAt)
    }
}

struct APIFriendApplyCreateDTO: Decodable {
    let id: UInt64
    let fromUid: UInt64
    let toUid: UInt64
    let status: String
    let reason: String
    let createdAt: String?
    let updatedAt: String?
}

struct APIOKDTO: Decodable {
    let ok: Bool
}

struct EmailRequest: Encodable {
    let email: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let emailCode: String
    let nickname: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

struct LogoutRequest: Encodable {
    let refreshToken: String?
}

struct C2CConversationRequest: Encodable {
    let peerUid: UInt64
}

struct FriendApplyRequest: Encodable {
    let toUid: UInt64
    let reason: String
}

private extension KeyedDecodingContainer {
    func decodeString(forKey key: Key, default defaultValue: String = "") throws -> String {
        (try? decodeIfPresent(String.self, forKey: key)) ?? defaultValue
    }

    func decodeRequiredString(forKey key: Key) throws -> String {
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return value
        }
        throw DecodingError.keyNotFound(
            key,
            DecodingError.Context(codingPath: codingPath, debugDescription: "Missing required String value")
        )
    }

    func decodeLossyInt(forKey key: Key, default defaultValue: Int = 0) throws -> Int {
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(value)
        }
        if let string = try? decodeIfPresent(String.self, forKey: key), let value = Int(string) {
            return value
        }
        return defaultValue
    }

    func decodeLossyUInt64(forKey key: Key) throws -> UInt64 {
        if let value = try decodeLossyUInt64IfPresent(forKey: key) {
            return value
        }
        throw DecodingError.keyNotFound(
            key,
            DecodingError.Context(codingPath: codingPath, debugDescription: "Missing required UInt64 value")
        )
    }

    func decodeLossyUInt64IfPresent(forKey key: Key) throws -> UInt64? {
        if let value = try? decodeIfPresent(UInt64.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Int64.self, forKey: key), value >= 0 {
            return UInt64(value)
        }
        if let string = try? decodeIfPresent(String.self, forKey: key), let value = UInt64(string) {
            return value
        }
        return nil
    }

    func decodeMilliseconds(forKey key: Key, default defaultValue: Int64 = 0) throws -> Int64 {
        if let value = try? decodeIfPresent(Int64.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(Double.self, forKey: key) {
            return Int64(value)
        }
        if let string = try? decodeIfPresent(String.self, forKey: key) {
            if let value = Int64(string) {
                return value
            }
            if let value = APIDateParser.milliseconds(from: string) {
                return value
            }
        }
        return defaultValue
    }
}

private enum APIDateParser {
    private static let iso8601 = ISO8601DateFormatter()
    private static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static func milliseconds(from string: String) -> Int64? {
        guard let date = iso8601WithFractionalSeconds.date(from: string) ?? iso8601.date(from: string) else {
            return nil
        }
        return Int64(date.timeIntervalSince1970 * 1000)
    }
}
