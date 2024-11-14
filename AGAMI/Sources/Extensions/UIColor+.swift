//
//  UIColor+.swift
//  AGAMI
//
//  Created by 박현수 on 11/14/24.

import UIKit

extension UIColor {
    func toHexString() -> String {
        var redFloat: CGFloat = 0
        var greenFloat: CGFloat = 0
        var blueFloat: CGFloat = 0
        var alphaFloat: CGFloat = 0

        self.getRed(&redFloat, green: &greenFloat, blue: &blueFloat, alpha: &alphaFloat)

        let red = Int(redFloat * 255)
        let green = Int(greenFloat * 255)
        let blue = Int(blueFloat * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
