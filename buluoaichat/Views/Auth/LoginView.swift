//
//  LoginView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            BlahajScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    AuthBlahajLoginHero()

                    AuthCard(topPadding: 20, bottomPadding: 16, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("欢迎回来")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(BlahajTheme.textPrimary)
                                Text("布罗艾陪你回到聊天海域")
                                    .font(.footnote)
                                    .foregroundStyle(BlahajTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        // 输入框不使用 glassEffect，避免键盘类型切换时触发表单重排。
                        AuthFormGroup {
                            AuthFieldRow(
                                icon: "envelope.fill",
                                placeholder: "邮箱地址",
                                text: $email,
                                isSecure: false,
                                keyboardType: .emailAddress,
                                accentColor: BlahajTheme.primaryMid
                            )
                            AuthDivider()
                            AuthFieldRow(
                                icon: "lock.fill",
                                placeholder: "密码",
                                text: $password,
                                isSecure: true,
                                keyboardType: .default,
                                accentColor: BlahajTheme.primaryMid
                            )
                        }
                        .animation(.none, value: email)
                        .animation(.none, value: password)

                        if let errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(BlahajTheme.danger)
                                Text(errorMessage)
                                    .foregroundStyle(BlahajTheme.textSecondary)
                                    .lineLimit(2)
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }

                        BlahajPrimaryButton(isLoading: isLoading, action: login) {
                            Text("登录")
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.55 : 1)

                        Button(action: { showRegister = true }) {
                            HStack(spacing: 4) {
                                Text("还没有账号？")
                                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.75))
                                Text("立即注册")
                                    .foregroundStyle(BlahajTheme.cta)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                    }

                    AuthLoginTideStrip()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(appState)
        }
    }

    // MARK: - Action
    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await appState.login(email: email, password: password)
            } catch {
                errorMessage = error.userFacingMessage
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
