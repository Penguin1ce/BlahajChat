//
//  ConversationListView.swift
//  buluaichat
//
//  聊天列表：自定义标题 + 顶部搜索栏，无系统导航栏重叠

import SwiftUI

// MARK: - Conversation List

struct ConversationListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var isRefreshing = false

    private var filtered: [Conversation] {
        let conversations = appState.conversations
        return searchText.isEmpty ? conversations :
            conversations.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            BlahajScreenBackground()

            ScrollView {
                VStack(spacing: 14) {
                    BlahajPageHeader(
                        title: "消息",
                        subtitle: filtered.isEmpty ? "保持连接，轻松开始对话" : "\(filtered.count) 个会话",
                        actionIcon: "square.and.pencil",
                        action: refresh
                    )

                    BlahajSearchBar(placeholder: "搜索聊天", text: $searchText)

                    if filtered.isEmpty {
                        emptyState
                    } else {
                        conversationList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Conversation.self) { conv in
            ChatDetailView(conversation: conv)
                .environmentObject(appState)
        }
        .refreshable {
            await appState.refreshConversations()
        }
    }

    // MARK: - Conversation List Card
    private var conversationList: some View {
        BlahajListGroup {
            ForEach(filtered) { conv in
                NavigationLink(value: conv) {
                    ConversationRow(conversation: conv)
                }
                .buttonStyle(.plain)

                if conv.id != filtered.last?.id {
                    Rectangle()
                        .fill(BlahajTheme.separator.opacity(0.72))
                        .frame(height: 0.5)
                        .padding(.leading, 82)
                        .padding(.trailing, 16)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        BlahajEmptyState(
            icon: "bubble.left.and.bubble.right",
            title: searchText.isEmpty ? "暂无会话" : "没有找到相关聊天",
            message: searchText.isEmpty ? "新的聊天会出现在这里" : "试试更短的关键词"
        )
    }

    private func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        Task {
            await appState.refreshConversations()
            isRefreshing = false
        }
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                imageName: conversation.displayAvatarName,
                displayName: conversation.displayName,
                size: 54,
                showOnlineDot: !conversation.isGroup,
                isOnline: conversation.contact?.isOnline ?? false,
                isGroup: conversation.isGroup
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(BlahajTheme.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if let lastMessageAt = conversation.lastMessageAt {
                        Text(lastMessageAt.chatListTime)
                            .font(.system(size: 12))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
                    }
                }

                HStack(spacing: 6) {
                    if conversation.pinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.56))
                    }

                    if let lastMessageText = conversation.lastMessageText {
                        Text(lastMessageText)
                            .font(.system(size: 14))
                            .foregroundStyle(BlahajTheme.textSecondary)
                            .lineLimit(1)
                    } else {
                        Text(conversation.isGroup ? "群聊已创建" : "开始聊天吧")
                            .font(.system(size: 14))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.64))
                            .lineLimit(1)
                    }
                    Spacer()
                    if conversation.muted {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.48))
                    }
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(BlahajTheme.primary, in: Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Date Formatting

extension Date {
    var chatListTime: String {
        let cal = Calendar.current
        if cal.isDateInToday(self)     { return formatted(.dateTime.hour().minute()) }
        if cal.isDateInYesterday(self) { return "昨天" }
        return formatted(.dateTime.month().day())
    }
}

#Preview {
    NavigationStack { ConversationListView() }
        .environmentObject(AppState())
}
