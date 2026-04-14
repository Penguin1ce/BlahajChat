//
//  ContactsView.swift
//  buluaichat
//
//  通讯录：群聊分组 + 联系人字母分组，右上角好友申请

import SwiftUI

// MARK: - Contacts View

struct ContactsView: View {
    @State private var contacts = Contact.samples
    @State private var groups = Conversation.samples.filter { $0.isGroup }
    @State private var searchText = ""
    @State private var showRequests = false

    private var totalRequests: Int {
        FriendRequest.samples.count + GroupJoinRequest.samples.count
    }

    // 搜索过滤后的联系人
    private var filteredContacts: [Contact] {
        searchText.isEmpty ? contacts :
            contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // 搜索过滤后的群聊
    private var filteredGroups: [Conversation] {
        searchText.isEmpty ? groups :
            groups.filter { ($0.groupName ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    // 联系人按首字母分组
    private var groupedContacts: [(key: String, value: [Contact])] {
        let sorted = filteredContacts.sorted { $0.name < $1.name }
        var dict: [String: [Contact]] = [:]
        for c in sorted {
            let key = String(c.name.prefix(1)).uppercased()
            dict[key, default: []].append(c)
        }
        return dict.sorted { $0.key < $1.key }
    }

    private var isEmpty: Bool {
        filteredContacts.isEmpty && filteredGroups.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                // ── 标题行 ─────────────────────────────────────────────
                HStack(alignment: .center) {
                    Text("通讯录")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                    Spacer()
                    Button(action: { showRequests = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 24))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(BlahajTheme.primaryMid)
                            if totalRequests > 0 {
                                Text("\(min(totalRequests, 99))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1.5)
                                    .background(Color.red, in: Capsule())
                                    .offset(x: 8, y: -4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)

                // ── 搜索栏 ─────────────────────────────────────────────
                searchBar

                // ── 群聊分组 ───────────────────────────────────────────
                if !filteredGroups.isEmpty {
                    sectionHeader(title: "群聊", icon: "person.3.fill")

                    VStack(spacing: 0) {
                        ForEach(Array(filteredGroups.enumerated()), id: \.element.id) { idx, group in
                            GroupContactRow(group: group)
                            if idx < filteredGroups.count - 1 {
                                Divider()
                                    .padding(.leading, 74)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .background(BlahajTheme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: BlahajTheme.primary.opacity(0.06), radius: 12, x: 0, y: 3)
                }

                // ── 联系人字母分组 ─────────────────────────────────────
                if !filteredContacts.isEmpty {
                    sectionHeader(title: "联系人", icon: "person.fill")

                    ForEach(groupedContacts, id: \.key) { section in
                        VStack(alignment: .leading, spacing: 0) {
                            // 字母标题
                            Text(section.key)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 6)

                            VStack(spacing: 0) {
                                ForEach(Array(section.value.enumerated()), id: \.element.id) { idx, contact in
                                    ContactRow(contact: contact)
                                    if idx < section.value.count - 1 {
                                        Divider()
                                            .padding(.leading, 74)
                                            .padding(.trailing, 16)
                                    }
                                }
                            }
                        }
                        .background(BlahajTheme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: BlahajTheme.primary.opacity(0.06), radius: 12, x: 0, y: 3)
                    }
                }

                if isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(BlahajTheme.pageBg)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showRequests) {
            FriendRequestsView()
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(BlahajTheme.primaryMid)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.7))
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.4))

            TextField("搜索联系人或群聊", text: $searchText)
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 42))
                .foregroundStyle(BlahajTheme.primaryMid.opacity(0.28))
            Text("没有找到相关联系人或群聊")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
    }
}

// MARK: - Group Contact Row

struct GroupContactRow: View {
    let group: Conversation

    private var memberCount: Int {
        // 示例：取消息发送者数量作为成员数参考
        3
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: BlahajTheme.radiusAvatar * 0.6, style: .continuous)
                    .fill(BlahajTheme.primaryMid.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(BlahajTheme.primaryMid)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(group.groupName ?? "群聊")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text("\(memberCount) 位成员")
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.52))
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "message.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(BlahajTheme.primaryMid)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(
                imageName: contact.avatarName,
                displayName: contact.name,
                size: 46,
                showOnlineDot: true,
                isOnline: contact.isOnline
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(contact.phone)
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.52))
            }

            Spacer()

            HStack(spacing: 18) {
                Button(action: {}) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(BlahajTheme.primaryMid)
                }
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(BlahajTheme.primaryMid)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { ContactsView() }
        .environmentObject(AppState())
}
