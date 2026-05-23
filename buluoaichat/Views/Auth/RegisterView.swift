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
        ZStack {
            BlahajScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    AuthBlahajRegisterHero()

                    AuthCard(topPadding: 20, bottomPadding: 18, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("创建账号")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(BlahajTheme.textPrimary)
                                Text("验证邮箱，领取你的海域名牌")
                                    .font(.footnote)
                                    .foregroundStyle(BlahajTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        AuthFormGroup {
                            AuthFieldRow(icon: "envelope.fill", placeholder: "邮箱地址",
                                         text: $email, isSecure: false,
                                         keyboardType: .emailAddress,
                                         accentColor: BlahajTheme.primaryMid)
                            AuthDivider()
                            AuthFieldRow(icon: "person.fill", placeholder: "用户名",
                                         text: $username, isSecure: false,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                            AuthDivider()
                            AuthCodeFieldRow(
                                code: $emailCode,
                                isSendingCode: isSendingCode,
                                canRequestCode: !email.isEmpty,
                                requestCode: requestCode
                            )
                            AuthDivider()
                            AuthFieldRow(icon: "lock.fill", placeholder: "密码",
                                         text: $password, isSecure: true,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                            AuthDivider()
                            AuthFieldRow(icon: "lock.shield.fill", placeholder: "确认密码",
                                         text: $confirmPassword, isSecure: true,
                                         keyboardType: .default,
                                         accentColor: BlahajTheme.primaryMid)
                        }
                        .animation(.none, value: email)
                        .animation(.none, value: username)
                        .animation(.none, value: emailCode)
                        .animation(.none, value: password)
                        .animation(.none, value: confirmPassword)

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

                        BlahajPrimaryButton(isLoading: isLoading, action: register) {
                            Text("注册")
                        }
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.55 : 1)

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
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 36)
            }
            .scrollDismissesKeyboard(.interactively)
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

private struct AuthCodeFieldRow: View {
    @Binding var code: String
    let isSendingCode: Bool
    let canRequestCode: Bool
    let requestCode: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "number.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BlahajTheme.primaryMid)
                .frame(width: 32, height: 32)
                .background(BlahajTheme.accentLight.opacity(0.75), in: Circle())

            TextField("邮箱验证码", text: $code)
                .font(.system(size: 15))
                .foregroundStyle(BlahajTheme.textPrimary)
                .keyboardType(.numberPad)

            Button(action: requestCode) {
                HStack(spacing: 5) {
                    if isSendingCode {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(BlahajTheme.primary)
                    }
                    Text(isSendingCode ? "发送中" : "获取")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BlahajTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(BlahajTheme.accentLight, in: Capsule())
            }
            .disabled(isSendingCode || !canRequestCode)
            .buttonStyle(.plain)
            .opacity(isSendingCode || !canRequestCode ? 0.58 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AppState())
}
