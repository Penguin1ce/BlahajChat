//
//  ProfileView.swift
//  buluaichat
//
//  个人资料页：直接以 Tab 页面呈现，无弹出框

import SwiftUI
import UIKit

struct ProfileView: View {
    /// 保存完成后由 MainTabView 注入，用于切回聊天 Tab
    var onDone: (() -> Void)? = nil

    @EnvironmentObject private var appState: AppState

    @State private var name = ""
    @State private var email = ""
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPasswordSection = false
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            BlahajScreenBackground()

            ScrollView {
                VStack(spacing: 18) {
                    avatarSection.padding(.top, 8)
                    infoSection
                    passwordSection
                    if let errorMessage {
                        HStack(spacing: 7) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(BlahajTheme.warning)
                            Text(errorMessage)
                                .foregroundStyle(BlahajTheme.textSecondary)
                                .lineLimit(2)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    saveButton
                    logoutButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("个人资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if saveSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            name  = appState.currentUser.name
            email = appState.currentUser.email
        }
    }

    // MARK: - 头像区 ─────────────────────────────────────────────────
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    imageName: appState.currentUser.avatarName,
                    displayName: appState.currentUser.name,
                    size: 92
                )
                .shadow(color: BlahajTheme.shadow.opacity(0.12), radius: 14, x: 0, y: 6)

                Button(action: {}) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(BlahajTheme.primary, in: Circle())
                        .overlay(Circle().stroke(BlahajTheme.cardBg, lineWidth: 2.5))
                }
                .offset(x: 2, y: 2)
                .buttonStyle(.plain)
            }

            VStack(spacing: 4) {
                Text(appState.currentUser.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)
                Text(appState.currentUser.email)
                    .font(.subheadline)
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(BlahajTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
        )
        .shadow(color: BlahajTheme.shadow.opacity(0.045), radius: 14, x: 0, y: 7)
    }

    // MARK: - 基本信息 ────────────────────────────────────────────────
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlahajSectionHeader(title: "基本信息", icon: "person.fill")

            BlahajListGroup {
                ProfileFieldRow(icon: "person.fill",    label: "昵称", text: $name,  placeholder: "输入你的昵称")
                Rectangle()
                    .fill(BlahajTheme.separator.opacity(0.72))
                    .frame(height: 0.5)
                    .padding(.leading, 64)
                ProfileFieldRow(icon: "envelope.fill",  label: "邮箱", text: $email, placeholder: "输入你的邮箱",
                                keyboardType: .emailAddress)
            }
            .animation(.none, value: name)
            .animation(.none, value: email)
        }
    }

    // MARK: - 修改密码 ────────────────────────────────────────────────
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ProfileSectionHeader(title: "修改密码", icon: "lock.fill")
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        showPasswordSection.toggle()
                    }
                }) {
                    Image(systemName: showPasswordSection ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(BlahajTheme.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)

            if showPasswordSection {
                BlahajListGroup {
                    ProfileFieldRow(icon: "lock.fill",             label: "当前密码", text: $oldPassword,     placeholder: "输入当前密码",     isSecure: true)
                    Rectangle()
                        .fill(BlahajTheme.separator.opacity(0.72))
                        .frame(height: 0.5)
                        .padding(.leading, 64)
                    ProfileFieldRow(icon: "lock.rotation",         label: "新密码",   text: $newPassword,     placeholder: "至少 8 位新密码",  isSecure: true)
                    Rectangle()
                        .fill(BlahajTheme.separator.opacity(0.72))
                        .frame(height: 0.5)
                        .padding(.leading, 64)
                    ProfileFieldRow(icon: "checkmark.shield.fill", label: "确认密码", text: $confirmPassword, placeholder: "再次输入新密码",   isSecure: true)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.none, value: oldPassword)
                .animation(.none, value: newPassword)
                .animation(.none, value: confirmPassword)
            }
        }
    }

    // MARK: - 保存按钮 ────────────────────────────────────────────────
    private var saveButton: some View {
        BlahajPrimaryButton(isLoading: isSaving, action: saveProfile) {
            Text("保存修改")
        }
        .disabled(isSaving)
        .padding(.top, 4)
    }

    private var logoutButton: some View {
        Button(action: {
            Task { await appState.logout() }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("退出登录")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(BlahajTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(BlahajTheme.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save ───────────────────────────────────────────────────
    private func saveProfile() {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else {
            errorMessage = "昵称和邮箱不能为空"
            return
        }
        errorMessage = "当前后端还没有开放资料修改接口"
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            isSaving = false
        }
    }
}

// MARK: - Sub-components

struct ProfileSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
    }
}

struct ProfileFieldRow: View {
    let icon: String
    let label: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BlahajTheme.primary)
                .frame(width: 30, height: 30)
                .background(BlahajTheme.accentLight.opacity(0.75), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.68))
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundStyle(BlahajTheme.textPrimary)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundStyle(BlahajTheme.textPrimary)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environmentObject(AppState())
}
