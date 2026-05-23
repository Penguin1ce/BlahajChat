//
//  FriendRequestsView.swift
//  buluaichat
//
//  好友申请页面：入群申请（我是群主的群）+ 好友申请

import SwiftUI

struct FriendRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    private var friendRequests: [FriendRequest] {
        appState.friendRequests
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BlahajScreenBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        if !friendRequests.isEmpty {
                            sectionCard(title: "好友申请", systemImage: "person.badge.plus.fill") {
                                ForEach(Array(friendRequests.enumerated()), id: \.element.id) { idx, req in
                                    FriendRequestRow(request: req) { action in
                                        handleFriend(request: req, action: action)
                                    }
                                    if idx < friendRequests.count - 1 {
                                        Rectangle()
                                            .fill(BlahajTheme.separator.opacity(0.72))
                                            .frame(height: 0.5)
                                            .padding(.leading, 74)
                                            .padding(.trailing, 16)
                                    }
                                }
                            }
                        }

                        if friendRequests.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("申请通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(BlahajTheme.primaryMid)
                }
            }
        }
        .task {
            await appState.refreshFriendRequests()
        }
    }

    // MARK: - Section Card Builder

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            BlahajSectionHeader(title: title, icon: systemImage)

            BlahajListGroup {
                content()
            }
        }
    }

    // MARK: - Actions

    private func handleFriend(request: FriendRequest, action: RequestAction) {
        Task {
            switch action {
            case .accept:
                await appState.acceptFriendRequest(request)
            case .reject:
                await appState.rejectFriendRequest(request)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        BlahajEmptyState(
            icon: "tray",
            title: "暂无新的申请",
            message: "好友申请会出现在这里"
        )
    }
}

// MARK: - Request Action

enum RequestAction { case accept, reject }

// MARK: - Friend Request Row

struct FriendRequestRow: View {
    let request: FriendRequest
    let onAction: (RequestAction) -> Void

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                imageName: request.from.avatarName,
                displayName: request.from.name,
                size: 46,
                showOnlineDot: false,
                isOnline: false
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(request.from.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(request.message)
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.74))
                    .lineLimit(1)
                Text(request.date.relativeString)
                    .font(.system(size: 11))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.55))
            }

            Spacer()

            actionButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: { onAction(.reject) }) {
                Text("拒绝")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(BlahajTheme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            Button(action: { onAction(.accept) }) {
                Text("同意")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.primary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Helper

private extension Date {
    var relativeString: String {
        let diff = Date().timeIntervalSince(self)
        if diff < 60 { return "刚刚" }
        if diff < 3600 { return "\(Int(diff / 60)) 分钟前" }
        if diff < 86400 { return "\(Int(diff / 3600)) 小时前" }
        return "\(Int(diff / 86400)) 天前"
    }
}

#Preview {
    FriendRequestsView()
        .environmentObject(AppState())
}
