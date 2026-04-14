//
//  LoginView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct LoginView: View {
    var onLoginSuccess: (() -> Void)? = nil

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isLoading = false

    private let typewriterFull = "Ciallo (∠·ω )⌒★"
    @State private var typewriterText = ""

    var body: some View {
        ZStack(alignment: .bottom) {

            BlahajTheme.pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection.padding(.top, 24)
                Spacer()
            }

            // 底部白卡
            VStack(spacing: 20) {

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("欢迎回来")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(BlahajTheme.textPrimary)
                        Text("登录账号，继续你的海洋之旅")
                            .font(.footnote)
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.8))
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

                // CTA 登录按钮 — Shark Pink
                Button(action: login) {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("登 录")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(BlahajTheme.cta)
                    .clipShape(RoundedRectangle(cornerRadius: BlahajTheme.radiusButton, style: .continuous))
                }
                .disabled(isLoading)

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
                .shadow(color: BlahajTheme.primary.opacity(0.1), radius: 20, x: 0, y: -4)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 16) {
            Image("frontui")
                .resizable()
                .scaledToFit()
                .frame(width: 118, height: 118)
                .clipShape(RoundedRectangle(cornerRadius: BlahajTheme.radiusAvatar, style: .continuous))
                .shadow(color: BlahajTheme.primary.opacity(0.2), radius: 14, x: 0, y: 7)

            Text(typewriterText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(BlahajTheme.textPrimary)
                .onAppear { startTypewriter() }

            VStack(spacing: 5) {
                Text("Blåhaj Chat")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.primaryMid)
                    .tracking(1.6)
            }

            Text("布罗艾的海洋朋友")
                .font(.subheadline)
                .foregroundStyle(BlahajTheme.primaryMid.opacity(0.72))
        }
    }

    // MARK: - Typewriter
    private func startTypewriter() {
        typewriterText = ""
        let characters = Array(typewriterFull)
        for (i, char) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                typewriterText.append(char)
            }
        }
    }

    // MARK: - Action
    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onLoginSuccess?()
        }
    }
}

#Preview {
    LoginView()
}
