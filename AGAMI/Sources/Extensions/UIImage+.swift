//
//  UIImage+.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/29/24.
//

import UIKit

extension UIImage {
    func cropToFiveByFour() -> UIImage? {
        let ratio: CGFloat = 5.0 / 4.0
        let imageRatio = size.width / size.height

        var cropWidth: CGFloat
        var cropHeight: CGFloat

        if imageRatio > ratio {
            cropHeight = size.height
            cropWidth = cropHeight * ratio
        } else {
            cropWidth = size.width
            cropHeight = cropWidth / ratio
        }

        let origin = CGPoint(
            x: (size.width - cropWidth) / 2,
            y: (size.height - cropHeight) / 2
        )
        let cropRect = CGRect(origin: origin, size: CGSize(width: cropWidth, height: cropHeight))

        let renderer = UIGraphicsImageRenderer(size: cropRect.size)
        return renderer.image { _ in
            self.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        }
    }

    func resizedAndCropped(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let originalSize = self.size
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height

        let scale = max(widthRatio, heightRatio)
        let resizedSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)

        let xOffset = (resizedSize.width - targetSize.width) / 2
        let yOffset = (resizedSize.height - targetSize.height) / 2
        let cropRect = CGRect(x: -xOffset, y: -yOffset, width: resizedSize.width, height: resizedSize.height)

        return renderer.image { _ in
            self.draw(in: cropRect)
        }
    }

    func applyBlur(radius: CGFloat = 20.0) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
