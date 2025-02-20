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
        // Perform the initialization on a background thread to avoid blocking the main thread.
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Load the Core ML model.
                let config = MLModelConfiguration()
                let model = try yolov8n(configuration: config).model

                // Convert the Core ML model to a Vision model.
                guard let visionModel = try? VNCoreMLModel(for: model) else {
                    throw DetectionError.modelConversionFailed
                }

                // Create a VNCoreMLRequest with the Vision model.
                let request = VNCoreMLRequest(model: visionModel)
                request.imageCropAndScaleOption = .scaleFill

                // Update the detection request
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
        // Ensure the model is ready and the image can be converted to a CGImage.
        guard isReady, let request = detectionRequest, let transformedImage = image.toCGImage() else {
            return []
        }
        
        do {
            // Create a VNImageRequestHandler to perform the request.
            let handler = VNImageRequestHandler(cgImage: transformedImage)
            try handler.perform([request])
            
            // Get the observations from the request.
            let observations = request.results ?? []
            // Process the observations and return the results.
            return processObservations(observations)
        } catch {
            // Handle any errors during detection.
            print("Detection failed: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Processes raw VNObservations into standardized format
    private func processObservations(_ observations: [VNObservation]) -> [ProcessedObservation] {
        // Filter and transform the observations.
        observations.compactMap { observation in
            // Only process recognized objects with certain detection threshold
            guard let objectObservation = observation as? VNRecognizedObjectObservation,
                  objectObservation.confidence > AppMetrics.objectDetectionThreshold else { return nil }
            
            // Convert the bounding box to view coordinates.
            let convertedRect = convertedBoundingRect(
                normalizedRect: objectObservation.boundingBox
            )
            
            // Check label validity and filter against blacklist
            guard let label = objectObservation.labels.first?.identifier,
                  !BlacklistObservation.items.contains(label) else {
                return nil
            }
            
            // Return a ProcessedObservation if all checks pass.
            return ProcessedObservation(
                label: label,
                confidence: objectObservation.confidence,
                boundingBox: convertedRect
            )
        }
    }
    
    /// Converts normalized coordinates to view coordinates with vertical flip
    private func convertedBoundingRect(normalizedRect: CGRect) -> CGRect {
        // Get the camera image dimensions from the app view model.
        guard let viewSize = appViewModel?.cameraImageDimensions else {
            return normalizedRect
        }
        
        // Convert the normalized rect to image coordinates.
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
