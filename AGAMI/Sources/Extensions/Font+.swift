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
    case dream1 = "S-CoreDream-1Thin"
    case dream2 = "S-CoreDream-2ExtraLight"
    case dream3 = "S-CoreDream-3Light"
    case dream4 = "S-CoreDream-4Regular"
    case dream5 = "S-CoreDream-5Medium"
    case dream6 = "S-CoreDream-6Bold"
    case dream7 = "S-CoreDream-7ExtraBold"
    case dream8 = "S-CoreDream-8Heavy"
    case dream9 = "S-CoreDream-9Black"
    
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
