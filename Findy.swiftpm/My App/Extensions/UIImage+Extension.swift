import SwiftUI

import SwiftUI

extension UIImage {
    /// Returns a new square image with a white background,
    /// where the original image is centered and scaled to fit.
    func imageWithWhiteBackgroundSquare() -> UIImage {
        // Determine the final square side length
        let squareSide = max(size.width, size.height)
        let squareSize = CGSize(width: squareSide, height: squareSide)
        
        UIGraphicsBeginImageContextWithOptions(squareSize, true, scale)
        defer { UIGraphicsEndImageContext() }
        
        // Fill the background with white
        UIColor.white.setFill()
        let squareRect = CGRect(origin: .zero, size: squareSize)
        UIRectFill(squareRect)
        
        // Calculate the scaling factor that fits the image into the square while preserving the aspect ratio.
        let widthScale = squareSide / size.width
        let heightScale = squareSide / size.height
        let scaleFactor = min(widthScale, heightScale)
        
        // Calculate the size of the scaled image
        let scaledImageSize = CGSize(width: size.width * scaleFactor,
                                     height: size.height * scaleFactor)
        
        // Calculate the origin so that the image is centered
        let originX = (squareSide - scaledImageSize.width) / 2.0
        let originY = (squareSide - scaledImageSize.height) / 2.0
        let imageRect = CGRect(origin: CGPoint(x: originX, y: originY),
                               size: scaledImageSize)
        
        // Draw the original image into the calculated rect
        self.draw(in: imageRect)
        
        // Retrieve the new image from the current context.
        let imageWithBG = UIGraphicsGetImageFromCurrentImageContext()
        return imageWithBG ?? self
    }
}
