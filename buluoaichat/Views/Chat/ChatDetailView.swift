//
//  ChatDetailView.swift
//  buluaichat
//
//  聊天气泡界面 — Telegram iOS 26 风格 + 视频通话入口

import SwiftUI

// MARK: - Chat Detail View

struct ChatDetailView: View {
    @EnvironmentObject private var appState: AppState
    let conversation: Conversation

    @State private var inputText = ""
    @State private var showVideoCall = false
    @State private var isLoadingHistory = true
    @FocusState private var inputFocused: Bool

    private var messages: [Message] {
        appState.messages(for: conversation.serverID)
    }

    var body: some View {
        // ── 消息列表 ─────────────────────────────────────────────
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    if isLoadingHistory {
                        ProgressView()
                            .tint(BlahajTheme.primary)
                            .padding(.vertical, 20)
                    }

                    ForEach(messages) { msg in
                        MessageBubbleView(
                            message: msg,
                            contactName: conversation.displayName,
                            contactAvatarName: conversation.displayAvatarName,
                            isGroup: conversation.isGroup
                        )
                        .id(msg.id)
                    }
                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                // ── 消息输入栏 ───────────────────────────────────────────
                MessageInputBar(text: $inputText, inputFocused: $inputFocused, onSend: sendMessage)
            }
            .task(id: conversation.serverID) {
                isLoadingHistory = true
                await appState.loadMessages(for: conversation)
                isLoadingHistory = false
                proxy.scrollTo("bottom", anchor: .bottom)
            }
            .onChange(of: messages.count) {
                withAnimation(.spring(response: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
        .background(BlahajScreenBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                chatNavTitle
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button(action: { showVideoCall = true }) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BlahajTheme.primary)
                            .frame(width: 32, height: 32)
                            .background(BlahajTheme.accentLight, in: Circle())
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(BlahajTheme.primary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            appState.showTabBar = false
            appState.openConversation(conversation)
        }
        .onDisappear {
            appState.showTabBar = true
            appState.closeConversation(conversation)
        }
        .fullScreenCover(isPresented: $showVideoCall) {
            VideoCallView(conversation: conversation)
                .environmentObject(appState)
        }
    }

    // MARK: - Nav Title
    private var chatNavTitle: some View {
        HStack(spacing: 10) {
            AvatarView(
                imageName: conversation.displayAvatarName,
                displayName: conversation.displayName,
                size: 34,
                showOnlineDot: !conversation.isGroup,
                isOnline: conversation.contact?.isOnline ?? false,
                isGroup: conversation.isGroup
            )
            VStack(alignment: .leading, spacing: 1) {
                Text(conversation.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary)
                    .lineLimit(1)
                if conversation.isGroup {
                    Text("群聊")
                        .font(.system(size: 11))
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
                } else {
                    Text(conversation.contact?.isOnline == true ? "在线" : "离线")
                        .font(.system(size: 11))
                        .foregroundStyle(
                            conversation.contact?.isOnline == true
                                ? BlahajTheme.online : BlahajTheme.textSecondary.opacity(0.62)
                        )
                }
            }
        }
    }

    // MARK: - Send
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        appState.sendMessage(text, in: conversation)
    }
}

// MARK: - Message Bubble

struct MessageBubbleView: View {
    let message: Message
    let contactName: String
    let contactAvatarName: String
    let isGroup: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isFromMe {
                Spacer(minLength: 64)
                sentBubble
            } else {
                receivedBubble
                Spacer(minLength: 64)
            }
        }
        .padding(.vertical, 1)
    }

    // ── 发送气泡（右侧，蓝色渐变 + 右下角缺角）──────────────────────
    private var sentBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.text)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    BlahajTheme.bubbleOut,
                    in: UnevenRoundedRectangle(
                        topLeadingRadius: 18, bottomLeadingRadius: 18,
                        bottomTrailingRadius: 4, topTrailingRadius: 18,
                        style: .continuous
                    )
                )
                .shadow(color: BlahajTheme.primary.opacity(0.14), radius: 8, x: 0, y: 4)

            HStack(spacing: 3) {
                Image(systemName: deliveryIcon)
                    .font(.system(size: 9, weight: .semibold))
                Text(message.timestamp.messageTime)
                    .font(.system(size: 10))
            }
            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.64))
            .padding(.trailing, 4)
        }
    }

    private var deliveryIcon: String {
        switch message.deliveryState {
        case .sending:
            return "clock"
        case .sent:
            return "checkmark"
        case .failed:
            return "exclamationmark.circle"
        }
    }

    // ── 接收气泡（左侧，白卡 + 左下角缺角 + 头像）───────────────────
    private var receivedBubble: some View {
        HStack(alignment: .bottom, spacing: 8) {
            AvatarView(
                imageName: contactAvatarName,
                displayName: contactName,
                size: 32,
                isGroup: isGroup
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundStyle(BlahajTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        BlahajTheme.bubbleIn,
                        in: UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18,
                            style: .continuous
                        )
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18,
                            style: .continuous
                        )
                        .stroke(BlahajTheme.separator.opacity(0.65), lineWidth: 0.5)
                    )
                    .shadow(color: BlahajTheme.shadow.opacity(0.04), radius: 7, x: 0, y: 3)

                Text(message.timestamp.messageTime)
                    .font(.system(size: 10))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.64))
                    .padding(.leading, 4)
            }
        }
    }
}

// MARK: - Message Input Bar

struct MessageInputBar: View {
    @Binding var text: String
    var inputFocused: FocusState<Bool>.Binding
    let onSend: () -> Void

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(BlahajTheme.primary)
            }
            .frame(width: 36, height: 36)
            .buttonStyle(.plain)

            TextField("发送消息…", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .font(.system(size: 15))
                .focused(inputFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    BlahajTheme.surface,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(BlahajTheme.separator.opacity(0.72), lineWidth: 0.5)
                )

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        canSend ? BlahajTheme.primary : BlahajTheme.primaryMid.opacity(0.22)
                    )
                    .scaleEffect(canSend ? 1.0 : 0.92)
                    .animation(.spring(response: 0.22, dampingFraction: 0.65), value: canSend)
            }
            .disabled(!canSend)
            .frame(width: 36, height: 36)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }
}

// MARK: - Date

extension Date {
    var messageTime: String { formatted(.dateTime.hour().minute()) }
}

#Preview {
    NavigationStack {
        ChatDetailView(conversation: Conversation.samples[0])
            .environmentObject(AppState())
    }
}
