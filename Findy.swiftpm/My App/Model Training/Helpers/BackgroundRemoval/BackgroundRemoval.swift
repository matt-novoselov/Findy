import Vision
import UIKit
import CoreImage.CIFilterBuiltins

func removeBackground(from image: UIImage) async throws -> UIImage {
    try await Task.detached(priority: .userInitiated) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            throw BackgroundRemovalError.ciImageConversionFailed
        }
        
        // Generate foreground mask using Vision
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try handler.perform([request])
        
        guard let result = request.results?.first else {
            throw BackgroundRemovalError.maskGenerationFailed
        }
        
        // Create scaled mask
        let maskPixelBuffer = try result.generateScaledMaskForImage(
            forInstances: result.allInstances,
            from: handler
        )
        
        let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // Create stroke effect
        let imageSize = ciImage.extent.size
        let maxDimension = max(imageSize.width, imageSize.height)
        let strokeWidth = maxDimension / 25.0
        
        // Create dilated mask for outer stroke
        let dilateFilter = CIFilter.morphologyMaximum()
        dilateFilter.radius = Float(strokeWidth)
        dilateFilter.inputImage = maskImage
        
        guard let dilatedMask = dilateFilter.outputImage else {
            throw BackgroundRemovalError.maskApplicationFailed
        }
        
        // Create white color image for stroke
        let strokeColor = CIImage.white
        
        // Blend stroke with original masked image
        let strokeFilter = CIFilter.blendWithMask()
        strokeFilter.inputImage = strokeColor
        strokeFilter.maskImage = dilatedMask
        strokeFilter.backgroundImage = CIImage.empty()
        
        guard let strokeImage = strokeFilter.outputImage else {
            throw BackgroundRemovalError.maskApplicationFailed
        }
        
        // Apply mask to original image
        let mainFilter = CIFilter.blendWithMask()
        mainFilter.inputImage = ciImage
        mainFilter.maskImage = maskImage
        mainFilter.backgroundImage = CIImage.empty()
        
        guard let maskedImage = mainFilter.outputImage else {
            throw BackgroundRemovalError.maskApplicationFailed
        }
        
        // Composite stroke and masked image
        let compositeFilter = CIFilter.sourceOverCompositing()
        compositeFilter.backgroundImage = strokeImage
        compositeFilter.inputImage = maskedImage
        
        guard let outputCIImage = compositeFilter.outputImage else {
            throw BackgroundRemovalError.maskApplicationFailed
        }
        
        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            throw BackgroundRemovalError.cgImageConversionFailed
        }
        
        let cutOutUIImage = UIImage(cgImage: cgImage)
        
        return cutOutUIImage
    }.value
}
