//
//  RegisterView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var emailCode = ""
    @State private var isSendingCode = false
    @State private var codeMessage: String?
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
                        Text("创建账号")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(BlahajTheme.textPrimary)
                        Text("加入 Blåhaj Chat")
                            .font(.footnote)
                            .foregroundStyle(BlahajTheme.textSecondary)
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
                            AuthFieldRow(icon: "number.circle.fill", placeholder: "邮箱验证码",
                                         text: $emailCode, isSecure: false,
                                         keyboardType: .numberPad,
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
                        .animation(.none, value: emailCode)
                        .animation(.none, value: password)
                        .animation(.none, value: confirmPassword)
                        .overlay(
                            RoundedRectangle(cornerRadius: BlahajTheme.radiusInput, style: .continuous)
                                .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
                        )

                        Button(action: requestCode) {
                            HStack(spacing: 7) {
                                if isSendingCode {
                                    ProgressView()
                                        .tint(BlahajTheme.primary)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(isSendingCode ? "正在发送验证码" : "发送邮箱验证码")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(BlahajTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(BlahajTheme.accentLight, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(isSendingCode || email.isEmpty)
                        .buttonStyle(.plain)
                        .opacity(isSendingCode || email.isEmpty ? 0.62 : 1)

                        if let codeMessage {
                            Text(codeMessage)
                                .font(.caption)
                                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        if let error = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(BlahajTheme.danger)
                                Text(error)
                                    .foregroundStyle(BlahajTheme.textSecondary)
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }
                    }
                }

                // CTA 注册按钮
                BlahajPrimaryButton(isLoading: isLoading, action: register) {
                    Text("注册")
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.55 : 1)

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
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 12) {
            Image("frontui")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .padding(7)
                .background(BlahajTheme.cardBg, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: BlahajTheme.shadow.opacity(0.10), radius: 14, x: 0, y: 7)

            VStack(spacing: 3) {
                Text("Blåhaj Chat")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(BlahajTheme.primary)
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
        guard !emailCode.isEmpty else {
            errorMessage = "请输入邮箱验证码"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "两次密码不一致"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "密码至少需要 6 位"
            return
        }
        isLoading = true
        Task {
            do {
                try await appState.register(
                    email: email,
                    password: password,
                    emailCode: emailCode,
                    nickname: username
                )
                dismiss()
            } catch {
                errorMessage = error.userFacingMessage
            }
            isLoading = false
        }
    }

    private func requestCode() {
        guard !email.isEmpty else { return }
        errorMessage = nil
        codeMessage = nil
        isSendingCode = true
        Task {
            do {
                try await appState.requestEmailCode(email: email)
                codeMessage = "验证码已发送，请前往邮箱查收"
            } catch {
                errorMessage = error.userFacingMessage
            }
            isSendingCode = false
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AppState())
}
