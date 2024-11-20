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
    
    static func sCoreDream(weight: SCoreDreamWeight, size: CGFloat) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
    
    static func notoSansKR(weight: NotoSansKRWeight, size: CGFloat) -> Font {
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

enum SCoreDreamWeight: String {
    case dream1 = "SCoreDream1"
    case dream2 = "SCoreDream2"
    case dream3 = "SCoreDream3"
    case dream4 = "SCoreDream4"
    case dream5 = "SCoreDream5"
    case dream6 = "SCoreDream6"
    case dream7 = "SCoreDream7"
    case dream8 = "SCoreDream8"
    case dream9 = "SCoreDream9"
    
    var fontName: String {
        return self.rawValue
    }
}

enum NotoSansKRWeight: String {
    case thin100 = "NotoSansKR-Thin"
    case extraLight200 = "NotoSansKR-ExtraLight"
    case light300 = "NotoSansKR-Light"
    case regular400 = "NotoSansKR-Regular"
    case medium500 = "NotoSansKR-Medium"
    case semiBold600 = "NotoSansKR-SemiBold"
    case bold700 = "NotoSansKR-Bold"
    case extraBold800 = "NotoSansKR-ExtraBold"
    case black900 = "NotoSansKR-Black"
    
    var fontName: String {
        return self.rawValue
    }
}
