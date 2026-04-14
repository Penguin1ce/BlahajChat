//
//  ChatModels.swift
//  buluaichat
//
//  数据模型 & 示例数据

import Foundation
import SwiftUI
import Combine

// MARK: - App State

class AppState: ObservableObject {
    @Published var showTabBar: Bool = true
    @Published var currentUser = AppUser(name: "Blåhaj", email: "blahaj@ocean.com")
}

struct AppUser {
    var id: UUID = UUID()
    var name: String
    var email: String
    var avatarName: String = "default"
}

// MARK: - Contact

struct Contact: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var avatarName: String = "default"
    var isOnline: Bool = false
    var phone: String = ""
}

// MARK: - Request Status

enum RequestStatus {
    case pending, accepted, rejected
}

// MARK: - Friend Request

struct FriendRequest: Identifiable {
    var id: UUID = UUID()
    var from: Contact
    var message: String
    var date: Date
    var status: RequestStatus = .pending
}

// MARK: - Group Join Request

struct GroupJoinRequest: Identifiable {
    var id: UUID = UUID()
    var from: Contact
    var groupName: String
    var message: String
    var date: Date
    var status: RequestStatus = .pending
}

// MARK: - Message

struct Message: Identifiable {
    var id: UUID = UUID()
    var text: String
    var isFromMe: Bool
    var timestamp: Date
}

// MARK: - Conversation

struct Conversation: Identifiable, Hashable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var id: UUID = UUID()
    var contact: Contact? = nil
    var groupName: String? = nil
    var isGroup: Bool
    var messages: [Message]
    var unreadCount: Int = 0

    var displayName: String {
        isGroup ? (groupName ?? "群聊") : (contact?.name ?? "未知")
    }
    var displayAvatarName: String { contact?.avatarName ?? "default" }
    var lastMessage: Message? { messages.last }
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
            contact: Contact(name: "小鲨鱼", isOnline: true),
            isGroup: false,
            messages: [
                Message(text: "你好！今天天气真好 ☀️", isFromMe: false, timestamp: .hoursAgo(1)),
                Message(text: "是啊，很适合出去游泳！🏊", isFromMe: true,  timestamp: .minutesAgo(58)),
                Message(text: "哈哈，我们去海洋公园吧！", isFromMe: false, timestamp: .minutesAgo(5)),
            ],
            unreadCount: 1
        ),
        Conversation(
            groupName: "鲨鱼海洋小队 🐋",
            isGroup: true,
            messages: [
                Message(text: "下午3点集合！",             isFromMe: false, timestamp: .hoursAgo(2)),
                Message(text: "好的，我到时候带零食来！",  isFromMe: true,  timestamp: .minutesAgo(118)),
                Message(text: "我带饮料！大家准时哦 🐳",  isFromMe: false, timestamp: .minutesAgo(10)),
            ],
            unreadCount: 3
        ),
        Conversation(
            contact: Contact(name: "海豚朋友 🐬", isOnline: false),
            isGroup: false,
            messages: [
                Message(text: "好久不见，最近怎么样？",    isFromMe: true,  timestamp: .daysAgo(1)),
                Message(text: "还好哦，一直在深海游泳~",  isFromMe: false, timestamp: .hoursAgo(22)),
            ],
            unreadCount: 0
        ),
        Conversation(
            contact: Contact(name: "章鱼老师 🐙", isOnline: true),
            isGroup: false,
            messages: [
                Message(text: "作业提交了吗？",              isFromMe: false, timestamp: .daysAgo(2)),
                Message(text: "已经提交啦！认真写的 📚",    isFromMe: true,  timestamp: .daysAgo(2)),
            ],
            unreadCount: 0
        ),
        Conversation(
            groupName: "深海探索队 🪸",
            isGroup: true,
            messages: [
                Message(text: "发现了新的珊瑚礁！快来看！", isFromMe: false, timestamp: .daysAgo(3)),
            ],
            unreadCount: 0
        ),
    ]
}

extension Contact {
    static let samples: [Contact] = [
        Contact(name: "白鲸 Beluga",  isOnline: true,  phone: "+86 138 0001 0001"),
        Contact(name: "海豚朋友 🐬",  isOnline: false, phone: "+86 138 0002 0002"),
        Contact(name: "海龟先生 🐢",  isOnline: true,  phone: "+86 138 0003 0003"),
        Contact(name: "江豚小弟",     isOnline: false, phone: "+86 138 0004 0004"),
        Contact(name: "抹香鲸",       isOnline: true,  phone: "+86 138 0005 0005"),
        Contact(name: "小鲨鱼",       isOnline: true,  phone: "+86 138 0006 0006"),
        Contact(name: "章鱼老师 🐙",  isOnline: true,  phone: "+86 138 0007 0007"),
        Contact(name: "座头鲸",       isOnline: false, phone: "+86 138 0008 0008"),
    ]
}

extension FriendRequest {
    static let samples: [FriendRequest] = [
        FriendRequest(
            from: Contact(name: "珊瑚小姐", isOnline: true, phone: "+86 139 0011 0011"),
            message: "Hi，我们在深海探索营认识的，加个好友吧！",
            date: .minutesAgo(30)
        ),
        FriendRequest(
            from: Contact(name: "灯笼鱼 🎣", isOnline: false, phone: "+86 139 0022 0022"),
            message: "你好，我是深海摄影师，希望和你交流！",
            date: .hoursAgo(3)
        ),
        FriendRequest(
            from: Contact(name: "飞鱼快递", isOnline: true, phone: "+86 139 0033 0033"),
            message: "朋友推荐我加你的～",
            date: .daysAgo(1)
        ),
    ]
}

extension GroupJoinRequest {
    static let samples: [GroupJoinRequest] = [
        GroupJoinRequest(
            from: Contact(name: "乌贼同学", isOnline: true, phone: "+86 150 0001 0001"),
            groupName: "鲨鱼海洋小队 🐋",
            message: "我想加入你们的小队，一起探索海洋！",
            date: .minutesAgo(15)
        ),
        GroupJoinRequest(
            from: Contact(name: "螃蟹先生 🦀", isOnline: false, phone: "+86 150 0002 0002"),
            groupName: "深海探索队 🪸",
            message: "听说这里经常发现新奇的东西，申请加入～",
            date: .hoursAgo(5)
        ),
        GroupJoinRequest(
            from: Contact(name: "河豚气球", isOnline: true, phone: "+86 150 0003 0003"),
            groupName: "鲨鱼海洋小队 🐋",
            message: "大家好，我想参与你们的活动！",
            date: .daysAgo(2)
        ),
    ]
}
