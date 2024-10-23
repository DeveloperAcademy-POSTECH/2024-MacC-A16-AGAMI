//
//  Font+.swift
//  AGAMI
//
//  Created by 박현수 on 10/23/24.
//
import SwiftUI

extension Font {
    static func pretendard(weight: PretendardWeight, size: CGFloat) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
}

enum PretendardWeight: String {
    case thin = "Pretendard-Thin.otf"
    case extraLight = "Pretendard-ExtraLight.otf"
    case light = "Pretendard-Light"
    case regular = "Pretendard-Regular"
    case medium = "Pretendard-Medium"
    case semiBold = "Pretendard-SemiBold"
    case bold = "Pretendard-Bold"
    case extraBold = "Pretendard-ExtraBold"
    case black = "Pretendard-Black"

    var fontName: String {
        return self.rawValue
    }
}
