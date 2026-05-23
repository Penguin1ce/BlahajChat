//
//  ContactsView.swift
//  buluaichat
//
//  通讯录：群聊分组 + 联系人字母分组，右上角好友申请

import SwiftUI

// MARK: - Contacts View

struct ContactsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var showRequests = false
    @State private var selectedConversation: Conversation?

    private var totalRequests: Int {
        appState.friendRequests.count
    }

    // 搜索过滤后的联系人
    private var filteredContacts: [Contact] {
        let contacts = appState.contacts
        return searchText.isEmpty ? contacts :
            contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // 搜索过滤后的群聊
    private var filteredGroups: [Conversation] {
        let groups = appState.conversations.filter(\.isGroup)
        return searchText.isEmpty ? groups :
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
        ZStack {
            BlahajScreenBackground()

            ScrollView {
                VStack(spacing: 14) {
                    BlahajPageHeader(
                        title: "通讯录",
                        subtitle: "\(filteredContacts.count) 位联系人 · \(filteredGroups.count) 个群聊",
                        actionIcon: "person.badge.plus",
                        badgeCount: totalRequests,
                        action: { showRequests = true }
                    )

                    BlahajSearchBar(placeholder: "搜索联系人或群聊", text: $searchText)

                    if !filteredGroups.isEmpty {
                        BlahajSectionHeader(title: "群聊", icon: "person.3.fill")

                        BlahajListGroup {
                            ForEach(Array(filteredGroups.enumerated()), id: \.element.id) { idx, group in
                                GroupContactRow(group: group) {
                                    selectedConversation = group
                                }
                                if idx < filteredGroups.count - 1 {
                                    listDivider
                                }
                            }
                        }
                    }

                    if !filteredContacts.isEmpty {
                        BlahajSectionHeader(title: "联系人", icon: "person.fill")

                        ForEach(groupedContacts, id: \.key) { section in
                            BlahajListGroup {
                                Text(section.key)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(BlahajTheme.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)
                                    .padding(.bottom, 6)

                                ForEach(Array(section.value.enumerated()), id: \.element.id) { idx, contact in
                                    ContactRow(contact: contact) {
                                        openChat(with: contact)
                                    }
                                    if idx < section.value.count - 1 {
                                        listDivider
                                    }
                                }
                            }
                        }
                    }

                    if isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showRequests) {
            FriendRequestsView()
                .environmentObject(appState)
        }
        .navigationDestination(item: $selectedConversation) { conversation in
            ChatDetailView(conversation: conversation)
                .environmentObject(appState)
        }
        .refreshable {
            await appState.refreshContacts()
            await appState.refreshFriendRequests()
        }
    }

    private var listDivider: some View {
        Rectangle()
            .fill(BlahajTheme.separator.opacity(0.72))
            .frame(height: 0.5)
            .padding(.leading, 74)
            .padding(.trailing, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        BlahajEmptyState(
            icon: "person.2.slash",
            title: searchText.isEmpty ? "暂无联系人或群聊" : "没有找到相关联系人或群聊",
            message: searchText.isEmpty ? "好友和群聊会集中展示在这里" : "试试搜索昵称或邮箱"
        )
    }

    private func openChat(with contact: Contact) {
        Task {
            selectedConversation = await appState.startConversation(with: contact)
        }
    }
}

// MARK: - Group Contact Row

struct GroupContactRow: View {
    let group: Conversation
    let onMessage: () -> Void

    private var memberCount: Int {
        0
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: BlahajTheme.radiusAvatar * 0.6, style: .continuous)
                    .fill(BlahajTheme.accentLight)
                    .frame(width: 46, height: 46)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(BlahajTheme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(group.groupName ?? "群聊")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(memberCount > 0 ? "\(memberCount) 位成员" : "群聊")
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
            }

            Spacer()

            Button(action: onMessage) {
                Image(systemName: "message.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.primary)
                    .frame(width: 34, height: 34)
                    .background(BlahajTheme.accentLight, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: Contact
    let onMessage: () -> Void

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
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(contact.subtitle.isEmpty ? contact.email : contact.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onMessage) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BlahajTheme.primary)
                        .frame(width: 34, height: 34)
                        .background(BlahajTheme.accentLight, in: Circle())
                }
                Button(action: {}) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BlahajTheme.primary)
                        .frame(width: 34, height: 34)
                        .background(BlahajTheme.surface, in: Circle())
                }
            }
            .buttonStyle(.plain)
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
