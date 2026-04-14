//
//  ConversationListView.swift
//  buluaichat
//
//  聊天列表：自定义标题 + 顶部搜索栏，无系统导航栏重叠

import SwiftUI

// MARK: - Conversation List

struct ConversationListView: View {
    @State private var conversations = Conversation.samples
    @State private var searchText = ""

    private var filtered: [Conversation] {
        searchText.isEmpty ? conversations :
            conversations.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                // ── 标题行 ────────────────────────────────────────────
                HStack(alignment: .center) {
                    Text("消息")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(BlahajTheme.primaryMid)
                    }
                }
                .padding(.horizontal, 4)

                // ── 搜索栏 ────────────────────────────────────────────
                searchBar

                // ── 会话列表 ──────────────────────────────────────────
                if filtered.isEmpty {
                    emptyState
                } else {
                    conversationList
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(BlahajTheme.pageBg)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Conversation.self) { conv in
            ChatDetailView(conversation: conv)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.4))

            TextField("搜索聊天", text: $searchText)
                .font(.system(size: 15))
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.38))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .animation(.spring(response: 0.22), value: searchText.isEmpty)
    }

    // MARK: - Conversation List Card
    private var conversationList: some View {
        LazyVStack(spacing: 0) {
            ForEach(filtered) { conv in
                NavigationLink(value: conv) {
                    ConversationRow(conversation: conv)
                }
                .buttonStyle(.plain)

                if conv.id != filtered.last?.id {
                    Divider()
                        .padding(.leading, 82)
                        .padding(.trailing, 16)
                }
            }
        }
        .background(BlahajTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: BlahajTheme.primary.opacity(0.07), radius: 18, x: 0, y: 4)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 42))
                .foregroundStyle(BlahajTheme.primaryMid.opacity(0.28))
            Text("没有找到相关聊天")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
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
                size: 52,
                showOnlineDot: !conversation.isGroup,
                isOnline: conversation.contact?.isOnline ?? false,
                isGroup: conversation.isGroup
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if let msg = conversation.lastMessage {
                        Text(msg.timestamp.chatListTime)
                            .font(.system(size: 12))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.48))
                    }
                }

                HStack(spacing: 4) {
                    if let msg = conversation.lastMessage {
                        if msg.isFromMe {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(BlahajTheme.primaryMid.opacity(0.5))
                        }
                        Text(msg.text)
                            .font(.system(size: 14))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.62))
                            .lineLimit(1)
                    }
                    Spacer()
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(BlahajTheme.primary, in: Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
