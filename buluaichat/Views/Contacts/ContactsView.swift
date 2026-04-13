//
//  ContactsView.swift
//  buluaichat
//
//  通讯录列表：自定义标题 + 顶部搜索 + 字母分组卡片

import SwiftUI

// MARK: - Contacts View

struct ContactsView: View {
    @State private var contacts = Contact.samples
    @State private var searchText = ""

    private var filtered: [Contact] {
        searchText.isEmpty ? contacts :
            contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var grouped: [(key: String, value: [Contact])] {
        let sorted = filtered.sorted { $0.name < $1.name }
        var dict: [String: [Contact]] = [:]
        for c in sorted {
            let key = String(c.name.prefix(1)).uppercased()
            dict[key, default: []].append(c)
        }
        return dict.sorted { $0.key < $1.key }
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
                    Button(action: {}) {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(BlahajTheme.primaryMid)
                    }
                }
                .padding(.horizontal, 4)

                // ── 搜索栏 ─────────────────────────────────────────────
                searchBar

                // ── 分组列表 ───────────────────────────────────────────
                ForEach(grouped, id: \.key) { section in
                    VStack(alignment: .leading, spacing: 0) {

                        // 分组标题
                        Text(section.key)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 6)

                        // 联系人卡片
                        VStack(spacing: 0) {
                            ForEach(section.value) { contact in
                                ContactRow(contact: contact)
                                if contact.id != section.value.last?.id {
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
                }

                if filtered.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(BlahajTheme.pageBg)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.4))

            TextField("搜索联系人", text: $searchText)
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
            Text("没有找到相关联系人")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
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
