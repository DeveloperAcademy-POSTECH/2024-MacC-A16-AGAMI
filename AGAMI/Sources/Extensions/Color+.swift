//
//  Color+.swift
//  AGAMI
//
//  Created by 박현수 on 10/23/24.
//

import SwiftUI

extension Color {
    // 6자리
    init(rgbHex: String) {
        let hex = rgbHex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue: UInt64
        (red, green, blue) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1.0
        )
    }

    // 8자리 (투명도 포함)
    init(rgbaHex: String) {
        let hex = rgbaHex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: UInt64
        (red, green, blue, alpha) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

extension Color {
    static let pWhite = Color("pWhite")
    static let pLightGray = Color("pLightGray")
    static let pGray1 = Color("pGray1")
    static let pGray2 = Color("pGray2")
    static let pBlack = Color("pBlack")
    static let pPrimary = Color("pPrimary")
    static let pSecondary = Color("pSecondary")
}
