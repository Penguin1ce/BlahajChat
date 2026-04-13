//
//  AvatarView.swift
//  buluaichat
//
//  通用头像视图：优先加载本地图片，无图则显示首字渐变圆

import SwiftUI
import UIKit

struct AvatarView: View {
    let imageName: String
    let displayName: String
    let size: CGFloat
    var showOnlineDot: Bool = false
    var isOnline: Bool = false
    var isGroup: Bool = false

    private var initials: String { String(displayName.prefix(1)) }

    private var gradientColors: [Color] {
        isGroup
            ? [BlahajTheme.accentLight, BlahajTheme.primaryMid]
            : [BlahajTheme.primaryMid,  BlahajTheme.primary]
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent
                .frame(width: size, height: size)
                .clipShape(Circle())

            if showOnlineDot {
                Circle()
                    .fill(isOnline ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: size * 0.27, height: size * 0.27)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 1, y: 1)
            }
        }
    }

    @ViewBuilder
    private var avatarContent: some View {
        if UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                if isGroup {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: size * 0.34, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                } else {
                    Text(initials)
                        .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        AvatarView(imageName: "default", displayName: "鲨", size: 52)
        AvatarView(imageName: "none", displayName: "小鲨鱼", size: 52, showOnlineDot: true, isOnline: true)
        AvatarView(imageName: "none", displayName: "群聊", size: 52, isGroup: true)
    }
    .padding()
    .background(BlahajTheme.pageBg)
}
