//
//  BlahajTheme.swift
//  buluaichat
//
//  "布罗艾" 统一调色板 — 以 IKEA Blåhaj 鲨鱼为灵感
//

import SwiftUI

enum BlahajTheme {

    // MARK: - 主色 Shark Blue（鲨鱼背部深蓝）
    // 用于：标题、主要文字、图标

    /// 深蓝，标题 / 重要文字
    static let primary      = Color(hex: "#2B5F9E")
    /// 中蓝，副标题 / 次级图标
    static let primaryMid   = Color(hex: "#4D8BC4")
    /// 浅蓝，页面背景
    static let primaryLight = Color(hex: "#D6EAF5")

    // MARK: - 辅助色 Shark White（鲨鱼肚子奶白）
    // 用于：卡片背景、输入框底色

    /// 奶白，卡片 / 输入框背景
    static let surface      = Color(hex: "#F0E8D8")
    /// 纯白，最浅层背景（如底部卡片）
    static let background   = Color(hex: "#FFFFFF")

    // MARK: - 点缀色 Shark Pink（鲨鱼嘴肉粉）
    // 用于：CTA 主按钮、徽标、关键提醒

    /// 深粉，CTA 按钮 / 重要动作
    static let accent       = Color(hex: "#ffdada")
    /// 浅粉，提示 Badge / 柔和标记
    static let accentLight  = Color(hex: "#F2BFCA")

    // MARK: - 语义颜色（方便调用）
    static let textPrimary   = primary       // 主文字
    static let textSecondary = primaryMid    // 次级文字 / 占位
    static let cta           = accent        // 所有 CTA 按钮统一用粉色
    static let cardBg        = background    // 底部卡片
    static let pageBg        = primaryLight  // 页面蓝色背景

    // MARK: - 圆角规范
    static let radiusCard    : CGFloat = 42   // 卡片顶部大圆角
    static let radiusInput   : CGFloat = 18   // 输入框圆角
    static let radiusButton  : CGFloat = 18   // 按钮圆角
    static let radiusAvatar  : CGFloat = 28   // 头像 / 图片圆角
}

// MARK: - Color Hex 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
