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

    private let sharkBlue = Color(red: 0.298, green: 0.545, blue: 0.769)
    private let sharkDeep = Color(red: 0.118, green: 0.294, blue: 0.494)
    private let background = Color(red: 0.839, green: 0.914, blue: 0.961)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 50)

                    // Header
                    VStack(spacing: 8) {
                        Text("🦈")
                            .font(.system(size: 64))

                        Text("创建账号")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(sharkDeep)
                    }
                    .padding(.bottom, 36)

                    // 注册表单
                    VStack(spacing: 0) {
                        fieldRow(icon: "envelope", placeholder: "邮箱地址", text: $email,
                                 isSecure: false, keyboardType: .emailAddress)

                        Divider().padding(.horizontal, 16)

                        fieldRow(icon: "person", placeholder: "用户名", text: $username,
                                 isSecure: false, keyboardType: .default)

                        Divider().padding(.horizontal, 16)

                        fieldRow(icon: "lock", placeholder: "密码", text: $password,
                                 isSecure: true, keyboardType: .default)

                        Divider().padding(.horizontal, 16)

                        fieldRow(icon: "lock.shield", placeholder: "确认密码", text: $confirmPassword,
                                 isSecure: true, keyboardType: .default)
                    }
                    .glassEffect(in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 24)

                    // 错误提示
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.85))
                            .padding(.top, 12)
                            .padding(.horizontal, 24)
                    }

                    // 注册按钮
                    GlassEffectContainer {
                        Button(action: register) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(sharkDeep)
                                } else {
                                    Text("注册")
                                        .font(.headline)
                                        .foregroundStyle(sharkDeep)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .disabled(isLoading)
                        .glassEffect(in: .rect(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // 返回登录
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Text("已有账号？")
                                .foregroundStyle(sharkBlue.opacity(0.75))
                            Text("返回登录")
                                .foregroundStyle(sharkDeep)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 24)

                    Spacer(minLength: 50)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldRow(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        keyboardType: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(sharkBlue)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

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
        // TODO: 调用后端注册 API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    RegisterView()
}
