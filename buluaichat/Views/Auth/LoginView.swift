//
//  LoginView.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isLoading = false

    // Blåhaj 主题色
    private let sharkBlue = Color(red: 0.298, green: 0.545, blue: 0.769)
    private let sharkDeep = Color(red: 0.118, green: 0.294, blue: 0.494)
    private let background = Color(red: 0.839, green: 0.914, blue: 0.961)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 70)

                    // Hero

                    VStack(spacing: 12) {
                        Image("frontui")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                        VStack(spacing: 2) {
                            Text("布罗艾聊天室")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(sharkDeep)

                            Text("Blåhaj Ocean Friends")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(sharkBlue.opacity(0.8))
                                .tracking(1.5)
                        }

                        Text("布罗艾的海洋朋友")
                            .font(.subheadline)
                            .foregroundStyle(sharkBlue.opacity(0.7))
                    }
                    .padding(.bottom, 0)

                    Spacer(minLength: 80)

                    // 登录表单
                    VStack(spacing: 0) {
                        fieldRow(
                            icon: "envelope",
                            placeholder: "邮箱地址",
                            text: $email,
                            isSecure: false,
                            keyboardType: .emailAddress
                        )

                        Divider()
                            .padding(.horizontal, 16)

                        fieldRow(
                            icon: "lock",
                            placeholder: "密码",
                            text: $password,
                            isSecure: true,
                            keyboardType: .default
                        )
                    }
                    .glassEffect(in: .rect(cornerRadius: 18))
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20)

                    // 登录按钮
                    GlassEffectContainer {
                        Button(action: login) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .tint(sharkDeep)
                                } else {
                                    Text("登录")
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

                    // 注册入口
                    Button(action: { showRegister = true }) {
                        HStack(spacing: 4) {
                            Text("还没有账号？")
                                .foregroundStyle(sharkBlue.opacity(0.75))
                            Text("立即注册")
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
        .sheet(isPresented: $showRegister) {
            RegisterView()
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

    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        // TODO: 调用后端登录 API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}
