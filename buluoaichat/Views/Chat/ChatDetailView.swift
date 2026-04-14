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

    @State private var messages: [Message]
    @State private var inputText = ""
    @State private var showVideoCall = false
    @FocusState private var inputFocused: Bool

    init(conversation: Conversation) {
        self.conversation = conversation
        _messages = State(initialValue: conversation.messages)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            BlahajTheme.pageBg.ignoresSafeArea()

            // ── 消息列表 ─────────────────────────────────────────────
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(messages) { msg in
                            MessageBubbleView(
                                message: msg,
                                contactName: conversation.displayName,
                                contactAvatarName: conversation.displayAvatarName,
                                isGroup: conversation.isGroup
                            )
                            .id(msg.id)
                        }
                        Color.clear.frame(height: 84).id("bottom")
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear { proxy.scrollTo("bottom", anchor: .bottom) }
                .onChange(of: messages.count) {
                    withAnimation(.spring(response: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }

            // ── 消息输入栏 ───────────────────────────────────────────
            MessageInputBar(text: $inputText, inputFocused: $inputFocused, onSend: sendMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                chatNavTitle
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    // 视频通话按钮
                    Button(action: { showVideoCall = true }) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(BlahajTheme.primaryMid)
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17))
                            .foregroundStyle(BlahajTheme.primaryMid)
                    }
                }
            }
        }
        .onAppear  { appState.showTabBar = false }
        .onDisappear { appState.showTabBar = true }
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
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.5))
                } else {
                    Text(conversation.contact?.isOnline == true ? "在线" : "离线")
                        .font(.system(size: 11))
                        .foregroundStyle(
                            conversation.contact?.isOnline == true
                                ? Color.green : BlahajTheme.textSecondary.opacity(0.42)
                        )
                }
            }
        }
    }

    // MARK: - Send
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            messages.append(Message(text: text, isFromMe: true, timestamp: Date()))
        }
        inputText = ""
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
                    LinearGradient(
                        colors: [BlahajTheme.primaryMid, BlahajTheme.primary],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    in: UnevenRoundedRectangle(
                        topLeadingRadius: 18, bottomLeadingRadius: 18,
                        bottomTrailingRadius: 4, topTrailingRadius: 18,
                        style: .continuous
                    )
                )
                .shadow(color: BlahajTheme.primary.opacity(0.26), radius: 8, x: 0, y: 3)

            HStack(spacing: 3) {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .semibold))
                Text(message.timestamp.messageTime)
                    .font(.system(size: 10))
            }
            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.42))
            .padding(.trailing, 4)
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
                    .background(BlahajTheme.cardBg)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18, bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18, topTrailingRadius: 18,
                            style: .continuous
                        )
                    )
                    .shadow(color: BlahajTheme.primary.opacity(0.07), radius: 6, x: 0, y: 2)

                Text(message.timestamp.messageTime)
                    .font(.system(size: 10))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.42))
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
                    .font(.system(size: 28))
                    .foregroundStyle(BlahajTheme.primaryMid)
            }
            .frame(width: 36, height: 36)

            TextField("发送消息…", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .font(.system(size: 15))
                .focused(inputFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    BlahajTheme.pageBg,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .safeAreaPadding(.bottom)
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
