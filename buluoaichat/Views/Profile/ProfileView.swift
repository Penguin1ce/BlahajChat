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

    var body: some View {
        ZStack {
            BlahajTheme.pageBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    avatarSection.padding(.top, 4)
                    infoSection
                    passwordSection
                    saveButton
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
                .shadow(color: BlahajTheme.primary.opacity(0.22), radius: 14, x: 0, y: 6)

                Button(action: {}) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(BlahajTheme.primary, in: Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                }
                .offset(x: 2, y: 2)
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
        .shadow(color: BlahajTheme.primary.opacity(0.07), radius: 14, x: 0, y: 5)
    }

    // MARK: - 基本信息 ────────────────────────────────────────────────
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "基本信息", icon: "person.fill")

            VStack(spacing: 0) {
                ProfileFieldRow(icon: "person.fill",    label: "昵称", text: $name,  placeholder: "输入你的昵称")
                Divider().padding(.leading, 52)
                ProfileFieldRow(icon: "envelope.fill",  label: "邮箱", text: $email, placeholder: "输入你的邮箱",
                                keyboardType: .emailAddress)
            }
            .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                        .foregroundStyle(BlahajTheme.primaryMid)
                }
            }

            if showPasswordSection {
                VStack(spacing: 0) {
                    ProfileFieldRow(icon: "lock.fill",             label: "当前密码", text: $oldPassword,     placeholder: "输入当前密码",     isSecure: true)
                    Divider().padding(.leading, 52)
                    ProfileFieldRow(icon: "lock.rotation",         label: "新密码",   text: $newPassword,     placeholder: "至少 8 位新密码",  isSecure: true)
                    Divider().padding(.leading, 52)
                    ProfileFieldRow(icon: "checkmark.shield.fill", label: "确认密码", text: $confirmPassword, placeholder: "再次输入新密码",   isSecure: true)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.none, value: oldPassword)
                .animation(.none, value: newPassword)
                .animation(.none, value: confirmPassword)
            }
        }
    }

    // MARK: - 保存按钮 ────────────────────────────────────────────────
    private var saveButton: some View {
        Button(action: saveProfile) {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("保存修改")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(colors: [BlahajTheme.primaryMid, BlahajTheme.primary],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .disabled(isSaving)
        .shadow(color: BlahajTheme.primary.opacity(0.3), radius: 10, x: 0, y: 4)
        .padding(.top, 4)
    }

    // MARK: - Save ───────────────────────────────────────────────────
    private func saveProfile() {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else { return }
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            appState.currentUser.name  = n
            appState.currentUser.email = e
            isSaving = false
            withAnimation { saveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { saveSuccess = false }
                onDone?()
            }
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
                .foregroundStyle(BlahajTheme.primaryMid)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(BlahajTheme.textSecondary.opacity(0.58))
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environmentObject(AppState())
}
