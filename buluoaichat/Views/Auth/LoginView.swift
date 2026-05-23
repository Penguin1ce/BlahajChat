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
        ZStack(alignment: .bottom) {

            BlahajScreenBackground()

            VStack(spacing: 0) {
                heroSection.padding(.top, 30)
                Spacer()
            }

            // 底部白卡
            VStack(spacing: 18) {

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("欢迎回来")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(BlahajTheme.textPrimary)
                        Text("登录账号，继续聊天")
                            .font(.footnote)
                            .foregroundStyle(BlahajTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // 输入框 — 不用 GlassEffectContainer，避免焦点切换时触发 morphing 动画
                VStack(spacing: 0) {
                    AuthFieldRow(
                        icon: "envelope.fill",
                        placeholder: "邮箱地址",
                        text: $email,
                        isSecure: false,
                        keyboardType: .emailAddress,
                        accentColor: BlahajTheme.primaryMid
                    )
                    Divider().padding(.leading, 52)
                    AuthFieldRow(
                        icon: "lock.fill",
                        placeholder: "密码",
                        text: $password,
                        isSecure: true,
                        keyboardType: .default,
                        accentColor: BlahajTheme.primaryMid
                    )
                }
                .glassEffect(in: .rect(cornerRadius: BlahajTheme.radiusInput))
                .animation(.none, value: email)
                .animation(.none, value: password)
                .overlay(
                    RoundedRectangle(cornerRadius: BlahajTheme.radiusInput, style: .continuous)
                        .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
                )

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

                // CTA 登录按钮
                BlahajPrimaryButton(isLoading: isLoading, action: login) {
                    Text("登录")
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .opacity(isLoading || email.isEmpty || password.isEmpty ? 0.55 : 1)

                // 注册入口
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
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(alignment: .top) {
                UnevenRoundedRectangle(
                    topLeadingRadius: BlahajTheme.radiusCard,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: BlahajTheme.radiusCard,
                    style: .continuous
                )
                .fill(BlahajTheme.cardBg)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: BlahajTheme.shadow.opacity(0.08), radius: 24, x: 0, y: -8)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(appState)
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 16) {
            Image("frontui")
                .resizable()
                .scaledToFit()
                .frame(width: 104, height: 104)
                .padding(8)
                .background(BlahajTheme.cardBg, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: BlahajTheme.shadow.opacity(0.10), radius: 16, x: 0, y: 8)

            VStack(spacing: 5) {
                Text("Blåhaj Chat")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.primary)
                    .tracking(1.6)
            }

            Text("和重要的人保持联系")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.textSecondary)
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
