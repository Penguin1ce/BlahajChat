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
    private let bgTop     = Color(red: 0.839, green: 0.914, blue: 0.961)

    var body: some View {
        ZStack(alignment: .bottom) {

            bgTop.ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 24)
                Spacer()
            }

            // 卡片内容
            VStack(spacing: 20) {

                // 标题
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("创建账号")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(sharkDeep)
                        Text("加入布罗艾的海洋朋友圈")
                            .font(.footnote)
                            .foregroundStyle(sharkBlue.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)

                // 输入框（可滚动防键盘遮挡）
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        GlassEffectContainer {
                            VStack(spacing: 0) {
                                AuthFieldRow(icon: "envelope.fill", placeholder: "邮箱地址",
                                             text: $email, isSecure: false,
                                             keyboardType: .emailAddress, accentColor: sharkBlue)
                                Divider().padding(.leading, 52)
                                AuthFieldRow(icon: "person.fill", placeholder: "用户名",
                                             text: $username, isSecure: false,
                                             keyboardType: .default, accentColor: sharkBlue)
                                Divider().padding(.leading, 52)
                                AuthFieldRow(icon: "lock.fill", placeholder: "密码",
                                             text: $password, isSecure: true,
                                             keyboardType: .default, accentColor: sharkBlue)
                                Divider().padding(.leading, 52)
                                AuthFieldRow(icon: "lock.shield.fill", placeholder: "确认密码",
                                             text: $confirmPassword, isSecure: true,
                                             keyboardType: .default, accentColor: sharkBlue)
                            }
                            .glassEffect(in: .rect(cornerRadius: 18))
                        }

                        if let error = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                                Text(error)
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        }
                    }
                }

                // 注册按钮
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
                    .background(sharkDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(isLoading)

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
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .safeAreaPadding(.bottom)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(alignment: .top) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 42,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 42,
                    style: .continuous
                )
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: sharkDeep.opacity(0.1), radius: 20, x: 0, y: -4)
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
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: sharkDeep.opacity(0.15), radius: 10, x: 0, y: 5)

            VStack(spacing: 3) {
                Text("布罗艾")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(sharkDeep)
                Text("Blåhaj Ocean Friends")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(sharkBlue)
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
