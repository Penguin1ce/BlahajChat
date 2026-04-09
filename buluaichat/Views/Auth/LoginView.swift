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

    private let sharkBlue = Color(red: 0.298, green: 0.545, blue: 0.769)
    private let sharkDeep = Color(red: 0.118, green: 0.294, blue: 0.494)
    private let bgTop     = Color(red: 0.839, green: 0.914, blue: 0.961)

    var body: some View {
        ZStack(alignment: .bottom) {

            // 背景色延伸到全屏（包括安全区）
            bgTop.ignoresSafeArea()

            // Hero — 不忽略安全区，自然从 Dynamic Island 下方开始
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 24)
                Spacer()
            }

            // 底部卡片内容
            VStack(spacing: 20) {

                // 标题
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("欢迎回来")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(sharkDeep)
                        Text("登录账号，继续你的海洋之旅")
                            .font(.footnote)
                            .foregroundStyle(sharkBlue.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // 输入框
                GlassEffectContainer {
                    VStack(spacing: 0) {
                        AuthFieldRow(
                            icon: "envelope.fill",
                            placeholder: "邮箱地址",
                            text: $email,
                            isSecure: false,
                            keyboardType: .emailAddress,
                            accentColor: sharkBlue
                        )
                        Divider().padding(.leading, 52)
                        AuthFieldRow(
                            icon: "lock.fill",
                            placeholder: "密码",
                            text: $password,
                            isSecure: true,
                            keyboardType: .default,
                            accentColor: sharkBlue
                        )
                    }
                    .glassEffect(in: .rect(cornerRadius: 18))
                }

                // 登录按钮
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
                    .background(sharkDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(isLoading)

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
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            // 内容在 Home 条上方留出空间
            .safeAreaPadding(.bottom)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            // 背景形状单独延伸到屏幕物理底边
            .background(alignment: .top) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 42,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 42,
                    style: .continuous
                )
                .fill(.regularMaterial)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: sharkDeep.opacity(0.1), radius: 20, x: 0, y: -4)
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
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: sharkDeep.opacity(0.2), radius: 14, x: 0, y: 7)

            VStack(spacing: 5) {
                Text("布罗艾")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(sharkDeep)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(sharkBlue)
                    .tracking(1.6)
            }

            Text("布罗艾的海洋朋友")
                .font(.subheadline)
                .foregroundStyle(sharkBlue.opacity(0.72))
        }
    }

    // MARK: - Action
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
