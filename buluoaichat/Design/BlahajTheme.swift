//
//  BlahajTheme.swift
//  buluaichat
//
//  "布罗艾" 统一调色板 — 清爽 Telegram 感 + Blåhaj 蓝色气质
//

import SwiftUI

enum BlahajTheme {

    // MARK: - 主色 Telegram Blue

    /// Telegram 风格主蓝，CTA / 选中态 / 发送气泡
    static let primary      = Color(hex: "#229ED9")
    /// 柔和中蓝，图标 / 辅助强调
    static let primaryMid   = Color(hex: "#5BB8E8")
    /// 浅蓝灰页面背景
    static let primaryLight = Color(hex: "#F2F7FB")

    // MARK: - 表面与文本

    /// 输入框 / 次级控件背景
    static let surface      = Color(hex: "#F7FAFC")
    /// 卡片 / 列表背景
    static let background   = Color(hex: "#FFFFFF")
    /// 细分隔线
    static let separator    = Color(hex: "#DCE8F0")
    /// 主文字
    static let ink          = Color(hex: "#17212B")
    /// 次级文字
    static let slate        = Color(hex: "#6D8494")

    // MARK: - 状态与强调

    static let accent       = primary
    static let accentLight  = Color(hex: "#E6F5FC")
    static let online       = Color(hex: "#31C48D")
    static let danger       = Color(hex: "#FF5D5D")
    static let warning      = Color(hex: "#F6A63A")
    static let shadow       = Color(hex: "#17324D")
    static let bubbleIn     = Color(hex: "#FFFFFF")
    static let bubbleOut    = Color(hex: "#35A8E6")
    static let callBgTop    = Color(hex: "#0B1624")
    static let callBgMid    = Color(hex: "#102B3E")
    static let callBgBottom = Color(hex: "#070C14")
    static let callSurface  = Color(hex: "#1B2D3F")

    // MARK: - 语义颜色（方便调用）
    static let textPrimary   = ink
    static let textSecondary = slate
    static let cta           = accent
    static let cardBg        = background
    static let pageBg        = primaryLight

    // MARK: - 圆角规范
    static let radiusCard    : CGFloat = 28
    static let radiusInput   : CGFloat = 16
    static let radiusButton  : CGFloat = 16
    static let radiusAvatar  : CGFloat = 20
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
