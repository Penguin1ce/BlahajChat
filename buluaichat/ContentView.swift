//
//  ContentView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
                .environmentObject(appState)
        } else {
            LoginView(onLoginSuccess: {
                withAnimation(.spring(response: 0.48, dampingFraction: 0.85)) {
                    isLoggedIn = true
                }
            })
        }
    }
}

#Preview {
    ContentView()
}
