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
        
        let renderer = UIGraphicsImageRenderer(size: squareRect.size)
        return renderer.image { _ in
            self.draw(at: CGPoint(x: -squareRect.origin.x, y: -squareRect.origin.y))
        }
    }
}
