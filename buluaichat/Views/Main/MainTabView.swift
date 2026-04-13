//
//  MainTabView.swift
//  buluaichat
//
//  主界面：使用系统 TabView，让 iOS 26 自动提供底部 Liquid Glass 导航栏

import SwiftUI

enum AppTab: Hashable { case chat, contacts, profile }

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: AppTab = .chat

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("聊天", systemImage: "message.fill", value: .chat) {
                NavigationStack {
                    ConversationListView()
                }
            }

            Tab("通讯录", systemImage: "person.2.fill", value: .contacts) {
                NavigationStack {
                    ContactsView()
                }
            }

            Tab("我的", systemImage: "person.crop.circle.fill", value: .profile) {
                NavigationStack {
                    ProfileView(onDone: { selectedTab = .chat })
                }
            }
        }
        .tint(BlahajTheme.primary)
        .toolbarVisibility(appState.showTabBar ? .visible : .hidden, for: .tabBar)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: appState.showTabBar)
    }
}

#Preview {
    MainTabView().environmentObject(AppState())
}
