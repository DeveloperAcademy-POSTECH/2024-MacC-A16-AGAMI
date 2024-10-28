//
//  UIImage+.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/29/24.
//

import UIKit

extension UIImage {
    func resizeToSquare() -> UIImage? {
        let originalSize = min(size.width, size.height)
        let xOffset = (size.width - originalSize) / 2
        let yOffset = (size.height - originalSize) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: originalSize, height: originalSize)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
