//
//  FriendRequestsView.swift
//  buluaichat
//
//  好友申请页面：入群申请（我是群主的群）+ 好友申请

import SwiftUI

struct FriendRequestsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var friendRequests = FriendRequest.samples
    @State private var groupRequests = GroupJoinRequest.samples

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── 入群申请 ──────────────────────────────────────────
                    if !groupRequests.isEmpty {
                        sectionCard(title: "入群申请", systemImage: "person.3.fill") {
                            ForEach(Array(groupRequests.enumerated()), id: \.element.id) { idx, req in
                                GroupJoinRequestRow(request: req) { action in
                                    handleGroup(id: req.id, action: action)
                                }
                                if idx < groupRequests.count - 1 {
                                    Divider().padding(.leading, 74).padding(.trailing, 16)
                                }
                            }
                        }
                    }

                    // ── 好友申请 ──────────────────────────────────────────
                    if !friendRequests.isEmpty {
                        sectionCard(title: "好友申请", systemImage: "person.badge.plus.fill") {
                            ForEach(Array(friendRequests.enumerated()), id: \.element.id) { idx, req in
                                FriendRequestRow(request: req) { action in
                                    handleFriend(id: req.id, action: action)
                                }
                                if idx < friendRequests.count - 1 {
                                    Divider().padding(.leading, 74).padding(.trailing, 16)
                                }
                            }
                        }
                    }

                    if friendRequests.isEmpty && groupRequests.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(BlahajTheme.pageBg)
            .navigationTitle("申请通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(BlahajTheme.primaryMid)
                }
            }
        }
    }

    // MARK: - Section Card Builder

    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BlahajTheme.primaryMid)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .padding(.bottom, 4)
        }
        .background(BlahajTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: BlahajTheme.primary.opacity(0.06), radius: 12, x: 0, y: 3)
    }

    // MARK: - Actions

    private func handleFriend(id: UUID, action: RequestAction) {
        withAnimation(.spring(response: 0.3)) {
            friendRequests.removeAll { $0.id == id }
        }
    }

    private func handleGroup(id: UUID, action: RequestAction) {
        withAnimation(.spring(response: 0.3)) {
            groupRequests.removeAll { $0.id == id }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundStyle(BlahajTheme.primaryMid.opacity(0.28))
            Text("暂无新的申请")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
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
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(request.message)
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.55))
                    .lineLimit(1)
                Text(request.date.relativeString)
                    .font(.system(size: 11))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.35))
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
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.55))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.pageBg, in: RoundedRectangle(cornerRadius: 10))
            }
            Button(action: { onAction(.accept) }) {
                Text("同意")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.primary, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

// MARK: - Group Join Request Row

struct GroupJoinRequestRow: View {
    let request: GroupJoinRequest
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
                HStack(spacing: 4) {
                    Text(request.from.name)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                    Text("申请加入")
                        .font(.system(size: 12))
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.5))
                }
                Text(request.groupName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(BlahajTheme.primaryMid)
                    .lineLimit(1)
                if !request.message.isEmpty {
                    Text(request.message)
                        .font(.system(size: 12))
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.55))
                        .lineLimit(1)
                }
                Text(request.date.relativeString)
                    .font(.system(size: 11))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.35))
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
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.55))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.pageBg, in: RoundedRectangle(cornerRadius: 10))
            }
            Button(action: { onAction(.accept) }) {
                Text("同意")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BlahajTheme.primary, in: RoundedRectangle(cornerRadius: 10))
            }
        }
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
}
