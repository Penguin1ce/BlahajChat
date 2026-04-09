//
//  RegisterView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                        Text("创建账号")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(BlahajTheme.textPrimary)
                        Text("加入布罗艾的海洋朋友圈")
                            .font(.footnote)
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // 输入框
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        VStack(spacing: 0) {
                            AuthFieldRow(icon: "envelope.fill", placeholder: "邮箱地址",
                                         text: $email, isSecure: false,
                                         keyboardType: .emailAddress,
                                         accentColor: BlahajTheme.primaryMid)
                            Divider().padding(.leading, 52)
                            AuthFieldRow(icon: "person.fill", placeholder: "用户名",
                                         text: $username, isSecure: false,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                            Divider().padding(.leading, 52)
                            AuthFieldRow(icon: "lock.fill", placeholder: "密码",
                                         text: $password, isSecure: true,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                            Divider().padding(.leading, 52)
                            AuthFieldRow(icon: "lock.shield.fill", placeholder: "确认密码",
                                         text: $confirmPassword, isSecure: true,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                        }
                        .glassEffect(in: .rect(cornerRadius: BlahajTheme.radiusInput))
                        .animation(.none, value: email)
                        .animation(.none, value: username)
                        .animation(.none, value: password)
                        .animation(.none, value: confirmPassword)

                        if let error = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(BlahajTheme.accent.opacity(0.85))
                                Text(error)
                                    .foregroundStyle(BlahajTheme.accent.opacity(0.85))
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }
                    }
                }

                // CTA 注册按钮 — Shark Pink
                Button(action: register) {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("注 册")
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

                // 返回登录
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Text("已有账号？")
                            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.75))
                        Text("返回登录")
                            .foregroundStyle(BlahajTheme.cta)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .safeAreaPadding(.bottom)
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
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 12) {
            Image("frontui")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: BlahajTheme.radiusAvatar, style: .continuous))
                .shadow(color: BlahajTheme.primary.opacity(0.15), radius: 10, x: 0, y: 5)

            VStack(spacing: 3) {
                Text("布罗艾")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.primaryMid)
                    .tracking(1.4)
            }
        }
    }

    // MARK: - Action
    private func register() {
        errorMessage = nil
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "请填写所有字段"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "两次密码不一致"
            return
        }
        guard password.count >= 8 else {
            errorMessage = "密码至少需要 8 位"
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    RegisterView()
}
