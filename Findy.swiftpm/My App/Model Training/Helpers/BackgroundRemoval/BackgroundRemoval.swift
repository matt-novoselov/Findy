import Vision
import UIKit
import CoreImage.CIFilterBuiltins

// Function to remove the background from a UIImage.
func removeBackground(from image: UIImage) async -> UIImage {
    do {
        // Perform the background removal work in a detached task.
        let processedImage = try await Task.detached(priority: .userInitiated) {
            // Convert UIImage to CIImage.
            guard let ciImage = CIImage(image: image) else {
                throw BackgroundRemovalError.ciImageConversionFailed
            }
            
            // Generate foreground mask using Vision.
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])
            
            // Get the mask generation result.
            guard let result = request.results?.first else {
                throw BackgroundRemovalError.maskGenerationFailed
            }
            
            // Create scaled mask.
            let maskPixelBuffer = try result.generateScaledMaskForImage(
                forInstances: result.allInstances,
                from: handler
            )
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
            
            // Create a stroke effect.
            let imageSize = ciImage.extent.size
            let maxDimension = max(imageSize.width, imageSize.height)
            let strokeWidth = maxDimension / 25.0
            
            // Create a dilated mask for the outer stroke.
            let dilateFilter = CIFilter.morphologyMaximum()
            dilateFilter.radius = Float(strokeWidth)
            dilateFilter.inputImage = maskImage
            
            guard let dilatedMask = dilateFilter.outputImage else {
                throw BackgroundRemovalError.maskApplicationFailed
            }
            
            // Create a white color image for the stroke.
            let strokeColor = CIImage.white
            
            // Blend the stroke with the original masked image.
            let strokeFilter = CIFilter.blendWithMask()
            strokeFilter.inputImage = strokeColor
            strokeFilter.maskImage = dilatedMask
            strokeFilter.backgroundImage = CIImage.empty()
            
            guard let strokeImage = strokeFilter.outputImage else {
                throw BackgroundRemovalError.maskApplicationFailed
            }
            
            // Apply the mask to the original image.
            let mainFilter = CIFilter.blendWithMask()
            mainFilter.inputImage = ciImage
            mainFilter.maskImage = maskImage
            mainFilter.backgroundImage = CIImage.empty()
            
            guard let maskedImage = mainFilter.outputImage else {
                throw BackgroundRemovalError.maskApplicationFailed
            }
            
            // Composite the stroke and the masked image.
            let compositeFilter = CIFilter.sourceOverCompositing()
            compositeFilter.backgroundImage = strokeImage
            compositeFilter.inputImage = maskedImage
            
            guard let outputCIImage = compositeFilter.outputImage else {
                throw BackgroundRemovalError.maskApplicationFailed
            }
            
            // Convert the CIImage back to a UIImage.
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputCIImage,
                                                      from: outputCIImage.extent) else {
                throw BackgroundRemovalError.cgImageConversionFailed
            }
            
            let cutOutUIImage = UIImage(cgImage: cgImage)
            return cutOutUIImage
        }.value
        
        return processedImage
    } catch {
        // If any error occurs, log it and return the original image.
        print("Background removal error: \(error)")
        return image
    }
}
