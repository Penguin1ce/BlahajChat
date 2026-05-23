//
//  AuthFieldRow.swift
//  buluaichat
//
//  Created by Zakary on 2026/4/8.
//

import SwiftUI
import UIKit

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
                .frame(width: 30, height: 30)
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
        .padding(.vertical, 13)
    }
}
