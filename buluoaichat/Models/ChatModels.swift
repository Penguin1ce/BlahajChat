//
//  ChatModels.swift
//  buluaichat
//
//  领域模型与本地 UI 状态

import Foundation
import SwiftUI
import Combine

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    enum AuthPhase: Equatable {
        case launching
        case signedOut
        case signedIn
    }

    @Published var showTabBar: Bool = true
    @Published var authPhase: AuthPhase = .launching
    @Published var currentUser = AppUser(name: "Blåhaj", email: "blahaj@ocean.com")
    @Published var conversations: [Conversation] = []
    @Published var contacts: [Contact] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var bannerMessage: String?
    @Published var isBootstrapping = false

    let session: SessionStore
    let api: BlahajAPIClient
    let socket: ChatWebSocketClient

    private var cancellables: Set<AnyCancellable> = []
    private var messageCache: [String: [Message]] = [:]
    private var activeConversationID: String?
    private var localReadMessageIDs: [String: String] = [:]

    init(
        session: SessionStore? = nil,
        api: BlahajAPIClient? = nil,
        socket: ChatWebSocketClient? = nil
    ) {
        let session = session ?? KeychainSessionStore()
        self.session = session
        self.api = api ?? BlahajAPIClient(session: session)
        self.socket = socket ?? ChatWebSocketClient(environment: APIEnvironment.current)
        bindSocket()
    }

    func bootstrap() async {
        isBootstrapping = true
        defer { isBootstrapping = false }

        guard session.refreshToken != nil else {
            authPhase = .signedOut
            return
        }

        do {
            try await api.refreshToken()
            connectSocket()
            authPhase = .signedIn
            await loadInitialDataOrNotify()
        } catch {
            session.clear()
            authPhase = .signedOut
        }
    }

    func login(email: String, password: String) async throws {
        let response = try await api.login(email: email, password: password)
        if let user = response.user {
            currentUser = AppUser(dto: user)
        }
        connectSocket()
        authPhase = .signedIn
        await loadInitialDataOrNotify()
    }

    func register(email: String, password: String, emailCode: String, nickname: String) async throws {
        _ = try await api.register(
            email: email,
            password: password,
            emailCode: emailCode,
            nickname: nickname
        )
        try await login(email: email, password: password)
    }

    func requestEmailCode(email: String) async throws {
        _ = try await api.requestEmailCode(email: email)
    }

    func logout() async {
        do {
            try await api.logout()
        } catch {
            bannerMessage = error.userFacingMessage
        }
        socket.disconnect()
        messageCache.removeAll()
        conversations.removeAll()
        contacts.removeAll()
        friendRequests.removeAll()
        session.clear()
        authPhase = .signedOut
    }

    func refreshAll() async {
        do {
            try await loadInitialData()
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func refreshConversations() async {
        do {
            var loaded = try await api.listConversations().map { Conversation(dto: $0) }
            applyLocalReadOverrides(to: &loaded)
            conversations = loaded
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func refreshContacts() async {
        do {
            contacts = try await api.listFriends().items.map { Contact(dto: $0) }
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func refreshFriendRequests() async {
        do {
            friendRequests = try await api.listFriendApplies().items.map { FriendRequest(dto: $0) }
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func messages(for conversationID: String) -> [Message] {
        messageCache[conversationID] ?? []
    }

    func openConversation(_ conversation: Conversation) {
        activeConversationID = conversation.serverID
    }

    func closeConversation(_ conversation: Conversation) {
        if activeConversationID == conversation.serverID {
            activeConversationID = nil
        }
    }

    func loadMessages(for conversation: Conversation) async {
        do {
            let response = try await api.listMessages(conversationID: conversation.serverID, beforeID: 0, limit: 30)
            let loaded = response.items.map { Message(dto: $0, currentUserID: currentUser.uid) }
            messageCache[conversation.serverID] = loaded
            if let last = loaded.last {
                markRead(conversationID: conversation.serverID, msgID: last.serverID)
            }
            objectWillChange.send()
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func sendMessage(_ text: String, in conversation: Conversation) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let clientMessageID = UUID().uuidString
        let pending = Message(
            serverID: nil,
            clientMessageID: clientMessageID,
            text: trimmed,
            isFromMe: true,
            timestamp: Date(),
            deliveryState: .sending
        )
        messageCache[conversation.serverID, default: []].append(pending)
        _ = updateConversationPreview(
            conversationID: conversation.serverID,
            messageID: nil,
            text: trimmed,
            date: pending.timestamp
        )
        objectWillChange.send()

        socket.sendText(trimmed, conversationID: conversation.serverID, clientMessageID: clientMessageID)
    }

    func startConversation(with contact: Contact) async -> Conversation? {
        guard let uid = contact.uid else { return nil }
        do {
            let dto = try await api.createC2CConversation(peerUID: uid)
            let conversation = Conversation(dto: dto, fallbackContact: contact)
            upsertConversation(conversation)
            return conversation
        } catch {
            bannerMessage = error.userFacingMessage
            return nil
        }
    }

    func acceptFriendRequest(_ request: FriendRequest) async {
        guard let requestID = request.requestID else { return }
        do {
            let dto = try await api.acceptFriendApply(id: requestID)
            upsertConversation(Conversation(dto: dto))
            friendRequests.removeAll { $0.id == request.id }
            await refreshContacts()
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func rejectFriendRequest(_ request: FriendRequest) async {
        guard let requestID = request.requestID else { return }
        do {
            try await api.rejectFriendApply(id: requestID)
            friendRequests.removeAll { $0.id == request.id }
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    func applyFriend(toUID: UInt64, reason: String) async {
        do {
            _ = try await api.applyFriend(toUID: toUID, reason: reason)
            bannerMessage = "好友申请已发送"
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    private func loadInitialData() async throws {
        let me = try await api.me()
        currentUser = AppUser(dto: me.user)

        async let friendResp = api.listFriends()
        async let conversationResp = api.listConversations()
        async let requestResp = api.listFriendApplies()

        contacts = try await friendResp.items.map { Contact(dto: $0) }
        var loadedConversations = try await conversationResp.map { Conversation(dto: $0) }
        applyLocalReadOverrides(to: &loadedConversations)
        conversations = loadedConversations
        friendRequests = try await requestResp.items.map { FriendRequest(dto: $0) }
    }

    private func loadInitialDataOrNotify() async {
        do {
            try await loadInitialData()
        } catch {
            bannerMessage = error.userFacingMessage
        }
    }

    private func connectSocket() {
        guard let accessToken = session.accessToken else { return }
        socket.connect(accessToken: accessToken)
    }

    private func bindSocket() {
        socket.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                Task { @MainActor in
                    self.handleSocketEvent(event)
                }
            }
            .store(in: &cancellables)
    }

    private func handleSocketEvent(_ event: ChatSocketEvent) {
        switch event {
        case .message(let incoming):
            let message = Message(ws: incoming, currentUserID: currentUser.uid)
            let inserted = upsertMessage(message, conversationID: incoming.convId)
            let updatedExistingConversation = updateConversationPreview(
                conversationID: incoming.convId,
                messageID: incoming.msgId,
                text: message.text,
                date: message.timestamp
            )
            if activeConversationID == incoming.convId {
                markRead(conversationID: incoming.convId, msgID: incoming.msgId)
            } else if inserted && incoming.fromUid != currentUser.uid {
                localReadMessageIDs[incoming.convId] = nil
                incrementUnreadCount(conversationID: incoming.convId)
                if !updatedExistingConversation {
                    Task { await refreshConversations() }
                }
            }
        case .ack(let ack):
            applyAck(ack)
        case .error(let error):
            bannerMessage = error.message
            if error.code == "send_failed" {
                markLatestSendingMessageFailed()
            } else if error.code == "read_failed" {
                Task { await refreshConversations() }
            }
        case .connected, .pong:
            break
        case .disconnected(let reason):
            if authPhase == .signedIn {
                bannerMessage = reason ?? "实时连接已断开"
            }
        }
    }

    private func upsertMessage(_ message: Message, conversationID: String) -> Bool {
        var messages = messageCache[conversationID] ?? []
        if let serverID = message.serverID, messages.contains(where: { $0.serverID == serverID }) {
            return false
        }
        messages.append(message)
        messageCache[conversationID] = messages
        objectWillChange.send()
        return true
    }

    private func applyAck(_ ack: WSAckOKData) {
        for key in messageCache.keys {
            guard var messages = messageCache[key],
                  let index = messages.firstIndex(where: { $0.clientMessageID == ack.clientMsgId }) else {
                continue
            }
            messages[index].serverID = ack.msgId
            messages[index].timestamp = Date(millisecondsSince1970: ack.ts)
            messages[index].deliveryState = .sent
            messageCache[key] = messages
            objectWillChange.send()
            return
        }
    }

    private func markLatestSendingMessageFailed() {
        for key in messageCache.keys {
            guard var messages = messageCache[key],
                  let index = messages.lastIndex(where: { $0.deliveryState == .sending }) else {
                continue
            }
            messages[index].deliveryState = .failed
            messageCache[key] = messages
            objectWillChange.send()
            return
        }
    }

    private func markRead(conversationID: String, msgID: String?) {
        guard let msgID else { return }
        socket.markRead(conversationID: conversationID, msgID: msgID)
        localReadMessageIDs[conversationID] = msgID
        clearUnreadCount(conversationID: conversationID)
    }

    private func upsertConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.serverID == conversation.serverID }) {
            conversations[index] = conversation
        } else {
            conversations.insert(conversation, at: 0)
        }
    }

    private func updateConversationPreview(conversationID: String, messageID: String?, text: String, date: Date) -> Bool {
        guard let index = conversations.firstIndex(where: { $0.serverID == conversationID }) else { return false }
        if let messageID {
            conversations[index].lastMessageID = messageID
        }
        conversations[index].lastMessageText = text
        conversations[index].lastMessageAt = date
        conversations.sort {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            return ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast)
        }
        conversations = conversations
        return true
    }

    private func clearUnreadCount(conversationID: String) {
        guard let index = conversations.firstIndex(where: { $0.serverID == conversationID }),
              conversations[index].unreadCount != 0 else {
            return
        }
        conversations[index].unreadCount = 0
        conversations = conversations
    }

    private func incrementUnreadCount(conversationID: String) {
        guard let index = conversations.firstIndex(where: { $0.serverID == conversationID }) else { return }
        conversations[index].unreadCount += 1
        conversations = conversations
    }

    private func applyLocalReadOverrides(to loadedConversations: inout [Conversation]) {
        for index in loadedConversations.indices {
            let conversation = loadedConversations[index]
            guard let localReadMessageID = localReadMessageIDs[conversation.serverID] else { continue }

            if conversation.unreadCount == 0 {
                localReadMessageIDs[conversation.serverID] = nil
            } else if conversation.lastMessageID == localReadMessageID {
                loadedConversations[index].unreadCount = 0
            } else {
                localReadMessageIDs[conversation.serverID] = nil
            }
        }
    }
}

struct AppUser {
    var id: UUID = UUID()
    var uid: UInt64?
    var name: String
    var email: String
    var avatarURL: URL?
    var avatarName: String = "default"

    init(uid: UInt64? = nil, name: String, email: String, avatarURL: URL? = nil) {
        self.uid = uid
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }

    init(dto: APIUserDTO) {
        self.uid = dto.id
        self.name = dto.displayName
        self.email = dto.email
        self.avatarURL = dto.avatarURL
    }
}

// MARK: - Contact

struct Contact: Identifiable, Hashable {
    var id: UUID = UUID()
    var uid: UInt64?
    var name: String
    var email: String = ""
    var avatarURL: URL?
    var avatarName: String = "default"
    var isOnline: Bool = false
    var subtitle: String = ""

    init(
        id: UUID = UUID(),
        uid: UInt64? = nil,
        name: String,
        email: String = "",
        avatarURL: URL? = nil,
        avatarName: String = "default",
        isOnline: Bool = false,
        subtitle: String = ""
    ) {
        self.id = id
        self.uid = uid
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.avatarName = avatarName
        self.isOnline = isOnline
        self.subtitle = subtitle
    }

    init(dto: APIFriendDTO) {
        self.uid = dto.uid
        self.name = dto.displayName
        self.email = dto.email
        self.avatarURL = dto.avatarURL
        self.subtitle = dto.email
    }
}

// MARK: - Request Status

enum RequestStatus {
    case pending, accepted, rejected
}

// MARK: - Friend Request

struct FriendRequest: Identifiable {
    var id: UUID = UUID()
    var requestID: UInt64?
    var fromUID: UInt64?
    var from: Contact
    var message: String
    var date: Date
    var status: RequestStatus = .pending

    init(
        id: UUID = UUID(),
        requestID: UInt64? = nil,
        fromUID: UInt64? = nil,
        from: Contact,
        message: String,
        date: Date,
        status: RequestStatus = .pending
    ) {
        self.id = id
        self.requestID = requestID
        self.fromUID = fromUID
        self.from = from
        self.message = message
        self.date = date
        self.status = status
    }

    init(dto: APIFriendApplyDTO) {
        self.requestID = dto.id
        self.fromUID = dto.fromUid
        self.from = Contact(
            uid: dto.fromUid,
            name: "用户 \(dto.fromUid)",
            subtitle: "UID \(dto.fromUid)"
        )
        self.message = dto.reason.isEmpty ? "请求添加你为好友" : dto.reason
        self.date = Date(millisecondsSince1970: dto.createdAt)
        self.status = .pending
    }
}

// MARK: - Message

enum MessageDeliveryState: Equatable {
    case sending
    case sent
    case failed
}

struct Message: Identifiable, Equatable {
    var id: String
    var serverID: String?
    var clientMessageID: String?
    var text: String
    var isFromMe: Bool
    var timestamp: Date
    var deliveryState: MessageDeliveryState

    init(
        id: String = UUID().uuidString,
        serverID: String? = nil,
        clientMessageID: String? = nil,
        text: String,
        isFromMe: Bool,
        timestamp: Date,
        deliveryState: MessageDeliveryState = .sent
    ) {
        self.id = serverID ?? clientMessageID ?? id
        self.serverID = serverID
        self.clientMessageID = clientMessageID
        self.text = text
        self.isFromMe = isFromMe
        self.timestamp = timestamp
        self.deliveryState = deliveryState
    }

    init(dto: APIMessageDTO, currentUserID: UInt64?) {
        self.init(
            id: dto.msgId,
            serverID: dto.msgId,
            text: dto.displayText,
            isFromMe: dto.fromUid == currentUserID,
            timestamp: Date(millisecondsSince1970: dto.createdAt),
            deliveryState: .sent
        )
    }

    init(ws: WSMessageData, currentUserID: UInt64?) {
        self.init(
            id: ws.msgId,
            serverID: ws.msgId,
            text: ws.displayText,
            isFromMe: ws.fromUid == currentUserID,
            timestamp: Date(millisecondsSince1970: ws.createdAt),
            deliveryState: .sent
        )
    }
}

// MARK: - Conversation

enum ConversationKind: String {
    case c2c
    case group
}

struct Conversation: Identifiable, Hashable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool { lhs.serverID == rhs.serverID }
    func hash(into hasher: inout Hasher) { hasher.combine(serverID) }

    var id: String { serverID }
    var serverID: String
    var contact: Contact? = nil
    var groupName: String? = nil
    var kind: ConversationKind
    var avatarURL: URL?
    var lastMessageID: String?
    var lastMessageText: String?
    var lastMessageAt: Date?
    var unreadCount: Int = 0
    var pinned: Bool = false
    var muted: Bool = false

    var isGroup: Bool { kind == .group }

    var displayName: String {
        isGroup ? (groupName?.nilIfEmpty ?? "群聊") : (contact?.name ?? groupName?.nilIfEmpty ?? "单聊")
    }

    var displayAvatarName: String { contact?.avatarName ?? "default" }

    init(
        serverID: String = UUID().uuidString,
        contact: Contact? = nil,
        groupName: String? = nil,
        kind: ConversationKind,
        avatarURL: URL? = nil,
        lastMessageID: String? = nil,
        lastMessageText: String? = nil,
        lastMessageAt: Date? = nil,
        unreadCount: Int = 0,
        pinned: Bool = false,
        muted: Bool = false
    ) {
        self.serverID = serverID
        self.contact = contact
        self.groupName = groupName
        self.kind = kind
        self.avatarURL = avatarURL
        self.lastMessageID = lastMessageID
        self.lastMessageText = lastMessageText
        self.lastMessageAt = lastMessageAt
        self.unreadCount = unreadCount
        self.pinned = pinned
        self.muted = muted
    }

    init(dto: APIConversationDTO, fallbackContact: Contact? = nil) {
        let kind = ConversationKind(rawValue: dto.type) ?? .c2c
        self.serverID = dto.convId
        self.kind = kind
        self.groupName = dto.name.nilIfEmpty
        self.avatarURL = dto.avatarURL
        self.lastMessageID = dto.lastMsgId?.nilIfEmpty
        self.unreadCount = dto.unread ?? 0
        self.pinned = dto.pinned ?? false
        self.muted = dto.muted ?? false
        self.lastMessageAt = dto.lastMsgAt > 0 ? Date(millisecondsSince1970: dto.lastMsgAt) : nil
        self.lastMessageText = nil

        if kind == .c2c {
            self.contact = fallbackContact ?? Contact(
                name: dto.name.nilIfEmpty ?? dto.peerKey.nilIfEmpty ?? "单聊",
                avatarURL: dto.avatarURL,
                subtitle: dto.peerKey
            )
        }
    }
}

// MARK: - Sample Data

private extension Date {
    static func minutesAgo(_ m: Double) -> Date { Date().addingTimeInterval(-m * 60) }
    static func hoursAgo(_ h: Double) -> Date   { Date().addingTimeInterval(-h * 3600) }
    static func daysAgo(_ d: Double) -> Date    { Date().addingTimeInterval(-d * 86400) }
}

extension Conversation {
    static let samples: [Conversation] = [
        Conversation(
            contact: Contact(name: "小鲨鱼", isOnline: true, subtitle: "在线"),
            kind: .c2c,
            lastMessageText: "哈哈，我们去海洋公园吧！",
            lastMessageAt: .minutesAgo(5),
            unreadCount: 1
        ),
        Conversation(
            groupName: "鲨鱼海洋小队",
            kind: .group,
            lastMessageText: "我带饮料！大家准时哦",
            lastMessageAt: .minutesAgo(10),
            unreadCount: 3
        ),
        Conversation(
            contact: Contact(name: "海豚朋友", subtitle: "离线"),
            kind: .c2c,
            lastMessageText: "还好哦，一直在深海游泳~",
            lastMessageAt: .hoursAgo(22)
        )
    ]
}

extension Message {
    static let samples: [Message] = [
        Message(text: "你好！今天天气真好", isFromMe: false, timestamp: .hoursAgo(1)),
        Message(text: "是啊，很适合出去游泳！", isFromMe: true, timestamp: .minutesAgo(58)),
        Message(text: "哈哈，我们去海洋公园吧！", isFromMe: false, timestamp: .minutesAgo(5))
    ]
}

extension Contact {
    static let samples: [Contact] = [
        Contact(uid: 2, name: "白鲸 Beluga", email: "beluga@example.com", isOnline: true, subtitle: "beluga@example.com"),
        Contact(uid: 3, name: "海豚朋友", email: "dolphin@example.com", subtitle: "dolphin@example.com"),
        Contact(uid: 4, name: "江豚小弟", email: "finless@example.com", isOnline: true, subtitle: "finless@example.com")
    ]
}

extension FriendRequest {
    static let samples: [FriendRequest] = [
        FriendRequest(
            requestID: 1,
            fromUID: 8,
            from: Contact(uid: 8, name: "珊瑚小姐", isOnline: true, subtitle: "UID 8"),
            message: "Hi，我们在深海探索营认识的，加个好友吧！",
            date: .minutesAgo(30)
        )
    ]
}

extension Date {
    init(millisecondsSince1970 milliseconds: Int64) {
        self.init(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    var millisecondsSince1970: Int64 {
        Int64(timeIntervalSince1970 * 1000)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
