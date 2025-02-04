//  NQ Detect
//
//  Created by NULL on 10/9/22.
//

import Vision
import CoreImage

/// Handles object detection using a Core ML model and processes observations
class ObjectDetection {
    private var detectionRequest: VNCoreMLRequest?
    private(set) var isReady = false
    weak var appViewModel: AppViewModel?
    
    init() {
        initializeDetection()
    }
    
    /// Asynchronously initializes the detection model and request
    private func initializeDetection() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config = MLModelConfiguration()
                let model = try yolov8n(configuration: config).model

                guard let visionModel = try? VNCoreMLModel(for: model) else {
                    throw DetectionError.modelConversionFailed
                }

                let request = VNCoreMLRequest(model: visionModel)
                request.imageCropAndScaleOption = .scaleFill

                DispatchQueue.main.async {
                    self.detectionRequest = request
                    self.isReady = true
                    print("Detection model initialized successfully")
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleInitializationError(error)
                }
            }
        }
    }
    
    /// Processes an image buffer and returns processed observations
    public func detectAndProcess(image: CIImage) -> [ProcessedObservation] {
        guard isReady, let request = detectionRequest, let transformedImage = image.toCGImage() else {
            return []
        }
        
        do {
            let handler = VNImageRequestHandler(cgImage: transformedImage)
            try handler.perform([request])
            
            let observations = request.results ?? []
            return processObservations(observations)
        } catch {
            print("Detection failed: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Processes raw VNObservations into standardized format
    private func processObservations(_ observations: [VNObservation]) -> [ProcessedObservation] {
        observations.compactMap { observation in
            // Only process recognized objects with certain detection threshold
            guard let objectObservation = observation as? VNRecognizedObjectObservation,
                  objectObservation.confidence > AppMetrics.detectionThreshold else { return nil }
            
            let convertedRect = convertedBoundingRect(
                normalizedRect: objectObservation.boundingBox
            )
            
            // Check label validity and filter against blacklist
            guard let label = objectObservation.labels.first?.identifier,
                  !BlacklistObservation.items.contains(label) else {
                return nil
            }
            
            return ProcessedObservation(
                label: label,
                confidence: objectObservation.confidence,
                boundingBox: convertedRect
            )
        }
    }
    
    /// Converts normalized coordinates to view coordinates with vertical flip
    private func convertedBoundingRect(normalizedRect: CGRect) -> CGRect {
        guard let viewSize = appViewModel?.cameraImageDimensions else {
            return normalizedRect
        }
        
        let imageRect = VNImageRectForNormalizedRect(
            normalizedRect,
            Int(viewSize.width),
            Int(viewSize.height)
        )
        
        // Convert from Vision coordinates (bottom-left origin) to View coordinates (top-left origin)
        return CGRect(
            x: imageRect.minX,
            y: viewSize.height - imageRect.maxY,
            width: imageRect.width,
            height: imageRect.height
        )
    }
    
    /// Handles errors during model initialization
    private func handleInitializationError(_ error: Error) {
        DispatchQueue.main.async {
            self.isReady = false
            print("Model initialization error: \(error.localizedDescription)")
        }
    }
}
