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
    case thin100 = "Pretendard-Thin"
    case extraLight200 = "Pretendard-ExtraLight"
    case light300 = "Pretendard-Light"
    case regular400 = "Pretendard-Regular"
    case medium500 = "Pretendard-Medium"
    case semiBold600 = "Pretendard-SemiBold"
    case bold700 = "Pretendard-Bold"
    case extraBold800 = "Pretendard-ExtraBold"
    case black900 = "Pretendard-Black"
    
    var fontName: String {
        return self.rawValue
    }
}
