//
//  BlahajUI.swift
//  buluaichat
//
//  共享视觉组件：轻量 Telegram 风格页面、标题、搜索、列表组与按钮。
//

import SwiftUI

struct BlahajScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                BlahajTheme.pageBg,
                BlahajTheme.accentLight.opacity(0.52),
                BlahajTheme.pageBg
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BlahajPageHeader: View {
    let title: String
    var subtitle: String?
    var actionIcon: String?
    var badgeCount: Int = 0
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(BlahajTheme.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(BlahajTheme.textSecondary)
                }
            }

            Spacer()

            if let actionIcon, let action {
                Button(action: action) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: actionIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(BlahajTheme.primary)
                            .frame(width: 42, height: 42)
                            .background(BlahajTheme.cardBg, in: Circle())
                            .shadow(color: BlahajTheme.shadow.opacity(0.08), radius: 12, x: 0, y: 5)

                        if badgeCount > 0 {
                            Text("\(min(badgeCount, 99))")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(BlahajTheme.danger, in: Capsule())
                                .offset(x: 4, y: -3)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(title))
            }
        }
        .padding(.horizontal, 2)
    }
}

struct BlahajSearchBar: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(BlahajTheme.textSecondary.opacity(0.64))

            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(BlahajTheme.textPrimary)
                .submitLabel(.search)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.46))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(BlahajTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.8), lineWidth: 0.5)
        )
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: text.isEmpty)
    }
}

struct BlahajListGroup<Content: View>: View {
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(BlahajTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
        )
        .shadow(color: BlahajTheme.shadow.opacity(0.045), radius: 14, x: 0, y: 7)
    }
}

struct BlahajSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(BlahajTheme.primary)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BlahajTheme.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

struct BlahajPrimaryButton<Content: View>: View {
    var isLoading = false
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    content()
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [BlahajTheme.primaryMid, BlahajTheme.primary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: BlahajTheme.radiusButton, style: .continuous)
            )
            .shadow(color: BlahajTheme.primary.opacity(0.23), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

struct BlahajEmptyState: View {
    let icon: String
    let title: String
    var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(BlahajTheme.primary.opacity(0.34))

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary.opacity(0.72))

                if let message {
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundStyle(BlahajTheme.textSecondary.opacity(0.72))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 58)
    }
}
