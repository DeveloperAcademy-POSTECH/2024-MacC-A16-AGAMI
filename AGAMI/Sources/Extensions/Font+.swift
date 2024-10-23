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

struct PretendardFontTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    Text("Pretendard Thin")
                        .font(.pretendard(weight: .thin, size: 16))

                    Text("Pretendard ExtraLight")
                        .font(.pretendard(weight: .extraLight, size: 16))

                    Text("Pretendard Light")
                        .font(.pretendard(weight: .light, size: 16))

                    Text("Pretendard Regular")
                        .font(.pretendard(weight: .regular, size: 16))

                    Text("Pretendard Medium")
                        .font(.pretendard(weight: .medium, size: 16))

                    Text("Pretendard SemiBold")
                        .font(.pretendard(weight: .semiBold, size: 16))
                        .background(Color.accentColor)

                    Text("Pretendard Bold")
                        .font(.pretendard(weight: .bold, size: 16))

                    Text("Pretendard ExtraBold")
                        .font(.pretendard(weight: .extraBold, size: 16))

                    Text("Pretendard Black")
                        .font(.pretendard(weight: .black, size: 16))
                }
            }
        }
    }
}

#Preview {
    PretendardFontTestView()
}
