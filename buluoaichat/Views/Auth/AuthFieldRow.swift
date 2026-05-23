//
//  AuthFieldRow.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI
import UIKit

struct AuthCard<Content: View>: View {
    var topPadding: CGFloat = 22
    var bottomPadding: CGFloat = 22
    var horizontalPadding: CGFloat = 22
    var spacing: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: spacing) {
            content()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity)
        .background(BlahajTheme.cardBg, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.5), lineWidth: 0.5)
        )
        .shadow(color: BlahajTheme.shadow.opacity(0.08), radius: 24, x: 0, y: 12)
    }
}

struct AuthBlahajLoginHero: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                BlahajTheme.cardBg.opacity(0.92),
                                BlahajTheme.accentLight.opacity(0.9),
                                BlahajTheme.pageBg.opacity(0.98)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(BlahajTheme.separator.opacity(0.48), lineWidth: 0.5)
                    )

                ForEach(0..<12, id: \.self) { index in
                    let phase = time * (0.36 + Double(index % 3) * 0.06) + Double(index) * 0.62
                    Circle()
                        .fill(BlahajTheme.primary.opacity(0.06 + 0.025 * sin(phase)))
                        .frame(width: CGFloat(5 + index % 4 * 3), height: CGFloat(5 + index % 4 * 3))
                        .offset(
                            x: CGFloat(cos(phase) * 122) + CGFloat((index % 3) - 1) * 32,
                            y: CGFloat(sin(phase * 1.24) * 78) + CGFloat(index / 3) * 24 - 42
                        )
                }

                AuthOceanWave(phase: time * 0.7, amplitude: 9, frequency: 2.8)
                    .stroke(BlahajTheme.primary.opacity(0.14), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                    .frame(height: 78)
                    .offset(y: 110)

                AuthOceanWave(phase: time * 0.92 + 1.3, amplitude: 6, frequency: 2.2)
                    .stroke(BlahajTheme.primaryMid.opacity(0.11), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                    .frame(height: 62)
                    .offset(y: 128)

                AuthBlahajShark(time: time)
                    .offset(x: 12, y: 48)

                AuthHeroMessageBubble(text: "布罗艾在线", icon: "checkmark.seal.fill")
                    .offset(x: 92, y: -16)

                AuthHeroMessageBubble(text: "今天聊点什么？", icon: "message.fill")
                    .offset(x: -78, y: 84)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Blåhaj Chat")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(BlahajTheme.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)

                            Text("布罗艾把海面清好了")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(BlahajTheme.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.86)
                        }

                        Spacer(minLength: 12)

                        Text("Ocean Friends")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(BlahajTheme.primary)
                            .tracking(0.8)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(BlahajTheme.cardBg.opacity(0.66), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(BlahajTheme.primary.opacity(0.14), lineWidth: 0.5)
                            )
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(BlahajTheme.online)
                            .frame(width: 8, height: 8)
                        Text("柔软收件箱已准备好")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(BlahajTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(BlahajTheme.cardBg.opacity(0.72), in: Capsule())
                }
                .padding(22)
            }
            .frame(height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .shadow(color: BlahajTheme.shadow.opacity(0.07), radius: 22, x: 0, y: 12)
        }
    }
}

private struct AuthBlahajShark: View {
    let time: TimeInterval

    var body: some View {
        let lift = CGFloat(sin(time * 0.82) * 6)

        ZStack {
            AuthSharkTailShape()
                .fill(BlahajTheme.primaryMid.opacity(0.92))
                .frame(width: 72, height: 82)
                .rotationEffect(.degrees(-7))
                .offset(x: 116, y: 8)

            AuthSharkFinShape()
                .fill(BlahajTheme.primary.opacity(0.88))
                .frame(width: 58, height: 44)
                .rotationEffect(.degrees(-9))
                .offset(x: -10, y: -45)

            AuthSharkFinShape()
                .fill(BlahajTheme.primaryMid.opacity(0.78))
                .frame(width: 44, height: 34)
                .rotationEffect(.degrees(168))
                .offset(x: 8, y: 44)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#67C3ED"),
                            Color(hex: "#379ED8"),
                            Color(hex: "#197FBC")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 222, height: 88)
                .rotationEffect(.degrees(-7))

            Capsule()
                .fill(Color.white)
                .frame(width: 156, height: 38)
                .rotationEffect(.degrees(-7))
                .offset(x: -18, y: 25)

            Capsule()
                .fill(Color(hex: "#FF9FBC"))
                .frame(width: 34, height: 12)
                .rotationEffect(.degrees(-9))
                .offset(x: -79, y: 8)

            Capsule()
                .fill(Color(hex: "#FF7FA8").opacity(0.72))
                .frame(width: 18, height: 4)
                .rotationEffect(.degrees(-9))
                .offset(x: -80, y: 10)

            Circle()
                .fill(BlahajTheme.textPrimary)
                .frame(width: 7, height: 7)
                .offset(x: -72, y: -18)

            Circle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 2.4, height: 2.4)
                .offset(x: -73, y: -19)

            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: 14, height: 2)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: 12, height: 2)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .frame(width: 10, height: 2)
            }
            .foregroundStyle(Color.white.opacity(0.46))
            .rotationEffect(.degrees(-13))
            .offset(x: -35, y: 0)

            Capsule()
                .fill(BlahajTheme.primary.opacity(0.16))
                .frame(width: 92, height: 12)
                .blur(radius: 8)
                .offset(y: 68)
        }
        .frame(width: 278, height: 156)
        .offset(y: lift)
    }
}

private struct AuthSharkTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.12)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.12, y: rect.midY),
            control: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.midY - rect.height * 0.08)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.midY + rect.height * 0.08)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.12)
        )
        return path
    }
}

private struct AuthSharkFinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX + rect.width * 0.24, y: rect.minY + rect.height * 0.26)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.52)
        )
        path.closeSubpath()
        return path
    }
}

private struct AuthHeroMessageBubble: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(BlahajTheme.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(BlahajTheme.cardBg.opacity(0.78), in: Capsule())
        .overlay(
            Capsule()
                .stroke(BlahajTheme.primary.opacity(0.13), lineWidth: 0.5)
        )
    }
}

struct AuthLoginTideStrip: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "water.waves")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BlahajTheme.primary)
                .frame(width: 34, height: 34)
                .background(BlahajTheme.cardBg.opacity(0.72), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("布罗艾守着你的蓝色收件箱")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BlahajTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
                Text("登录后继续回到聊天海域")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(BlahajTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(BlahajTheme.accentLight.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.42), lineWidth: 0.5)
        )
    }
}

struct AuthBlahajRegisterHero: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let float = CGFloat(sin(time * 0.86) * 5)

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                BlahajTheme.cardBg.opacity(0.94),
                                BlahajTheme.accentLight.opacity(0.9),
                                Color(hex: "#EDF9FF")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(BlahajTheme.separator.opacity(0.48), lineWidth: 0.5)
                    )

                AuthOceanWave(phase: time * 0.68, amplitude: 7, frequency: 2.7)
                    .stroke(BlahajTheme.primary.opacity(0.15), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                    .frame(height: 58)
                    .offset(y: 98)

                AuthOceanWave(phase: time * 0.96 + 1.1, amplitude: 5, frequency: 2.2)
                    .stroke(BlahajTheme.primaryMid.opacity(0.12), style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                    .frame(height: 48)
                    .offset(y: 116)

                ForEach(0..<10, id: \.self) { index in
                    let phase = time * (0.4 + Double(index % 3) * 0.06) + Double(index) * 0.77

                    Circle()
                        .fill(BlahajTheme.primary.opacity(0.055 + 0.025 * sin(phase)))
                        .frame(width: CGFloat(5 + (index % 4) * 2), height: CGFloat(5 + (index % 4) * 2))
                        .offset(
                            x: CGFloat(cos(phase) * 110) + CGFloat((index % 3) - 1) * 26,
                            y: CGFloat(sin(phase * 1.2) * 68) + CGFloat(index / 3) * 18 - 38
                        )
                }

                AuthBlahajShark(time: time)
                    .scaleEffect(0.58)
                    .offset(x: -92, y: 82 + float)

                AuthRegisterPassCard()
                    .rotationEffect(.degrees(-4))
                    .offset(x: 72, y: 38 + float * 0.45)

                AuthRegisterStepPill(title: "邮箱验证", icon: "envelope.badge.fill", tint: BlahajTheme.primary)
                    .offset(x: -88, y: 2 + float)

                AuthRegisterStepPill(title: "昵称名牌", icon: "person.crop.circle.badge.plus", tint: BlahajTheme.online)
                    .offset(x: 96, y: -30 - float * 0.5)

                VStack(alignment: .leading, spacing: 7) {
                    Text("创建海域身份")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("领取布罗艾好友名牌")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(BlahajTheme.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.84)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .shadow(color: BlahajTheme.shadow.opacity(0.06), radius: 20, x: 0, y: 10)
        }
    }
}

private struct AuthRegisterPassCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(BlahajTheme.primary)
                    .frame(width: 32, height: 32)
                    .background(BlahajTheme.accentLight.opacity(0.9), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("新成员通行证")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(BlahajTheme.textPrimary)
                    Text("Blåhaj Ocean")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(BlahajTheme.primary)
                        .tracking(0.7)
                }
            }

            VStack(spacing: 7) {
                AuthRegisterPassLine(title: "邮箱", value: "待验证")
                AuthRegisterPassLine(title: "昵称", value: "待领取")
                AuthRegisterPassLine(title: "密码", value: "待加密")
            }
        }
        .padding(14)
        .frame(width: 164)
        .background(BlahajTheme.cardBg.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.48), lineWidth: 0.5)
        )
    }
}

private struct AuthRegisterPassLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(BlahajTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(BlahajTheme.textPrimary.opacity(0.78))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(BlahajTheme.accentLight.opacity(0.55), in: Capsule())
    }
}

private struct AuthRegisterStepPill: View {
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(BlahajTheme.cardBg.opacity(0.78), in: Capsule())
        .overlay(
            Capsule()
                .stroke(tint.opacity(0.14), lineWidth: 0.5)
        )
    }
}

private struct AuthOceanWave: Shape {
    var phase: Double
    var amplitude: CGFloat
    var frequency: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = max(rect.width, 1)
        let midY = rect.midY
        var x: CGFloat = 0

        path.move(to: CGPoint(x: 0, y: midY))
        while x <= rect.width {
            let progress = Double(x / width)
            let y = midY + CGFloat(sin(progress * Double.pi * frequency + phase)) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += 8
        }

        return path
    }
}

struct AuthFormGroup<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BlahajTheme.radiusInput, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BlahajTheme.radiusInput, style: .continuous)
                .stroke(BlahajTheme.separator.opacity(0.55), lineWidth: 0.5)
        )
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

struct AuthDivider: View {
    var body: some View {
        Rectangle()
            .fill(BlahajTheme.separator.opacity(0.72))
            .frame(height: 0.5)
            .padding(.leading, 62)
    }
}

/// 登录 / 注册界面通用输入行
struct AuthFieldRow: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let accentColor: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(accentColor)
                .frame(width: 32, height: 32)
                .background(BlahajTheme.accentLight.opacity(0.75), in: Circle())

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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
