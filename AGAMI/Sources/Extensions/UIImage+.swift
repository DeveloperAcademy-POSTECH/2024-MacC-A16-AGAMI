//
//  UIImage+.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/29/24.
//

import UIKit

extension UIImage {
    func cropSquare() -> UIImage? {
        let shortLength = min(size.width, size.height)
        let origin = CGPoint(
            x: (size.width - shortLength) / 2,
            y: (size.height - shortLength) / 2
        )
        let squareRect = CGRect(origin: origin, size: CGSize(width: shortLength, height: shortLength))
        
        guard let squareImage = self.cgImage?.cropping(to: squareRect) else { return nil }
        return UIImage(cgImage: squareImage, scale: scale, orientation: imageOrientation)
    }
}
