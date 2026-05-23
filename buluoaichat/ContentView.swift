//
//  ContentView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            switch appState.authPhase {
            case .launching:
                LaunchingView()
            case .signedIn:
                MainTabView()
            case .signedOut:
                LoginView()
            }
        }
        .environmentObject(appState)
        .animation(.spring(response: 0.48, dampingFraction: 0.85), value: appState.authPhase)
        .alert(
            "提示",
            isPresented: Binding(
                get: { appState.bannerMessage != nil },
                set: { if !$0 { appState.bannerMessage = nil } }
            )
        ) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(appState.bannerMessage ?? "")
        }
        .task {
            await appState.bootstrap()
        }
    }
}

private struct LaunchingView: View {
    var body: some View {
        ZStack {
            BlahajScreenBackground()
            VStack(spacing: 18) {
                Image("frontui")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(7)
                    .background(BlahajTheme.cardBg, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: BlahajTheme.shadow.opacity(0.10), radius: 14, x: 0, y: 6)

                ProgressView()
                    .tint(BlahajTheme.primary)

                Text("正在连接 Blåhaj Chat")
                    .font(.subheadline)
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
            }
        }
    }
}

#Preview {
    ContentView()
}
