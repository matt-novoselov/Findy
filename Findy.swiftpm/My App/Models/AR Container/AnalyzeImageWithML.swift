#if canImport(CreateML)
import CreateML
#endif

extension ARSceneCoordinator{
    public func analyzeImageWithML() {
        #if canImport(CreateML)
        // Ensure we have appViewModel
        guard let appViewModel = self.appViewModel else {
            return
        }
        
        // Select the dominant observation using the target detection object.
        guard let mostProminentResult = selectDominantObservation(
            from: self.detectedObjects,
            targetObject: appViewModel.savedObject.targetDetectionObject
        ) else {
            return
        }
        
        // Convert the processed frame image to CGImage.
        guard let cgImage = self.processedFrameImage?.toCGImage() else {
            return
        }
        
        // Crop the CGImage based on the detected bounding box.
        let cropRect = mostProminentResult.boundingBox
        guard let cgImageCropped = cgImage.cropping(to: cropRect) else {
            // Log error if needed: cropping failed.
            return
        }
        
        // Ensure the image classifier is available.
        guard let imageClassifier = appViewModel.savedObject.imageClassifier else {
            return
        }
        
        // Attempt prediction and handle possible errors.
        do {
            let prediction = try imageClassifier.prediction(from: cgImageCropped)
            if prediction == "myObject" {
                self.handleNewDetectionResults()
            }
        } catch {
            return
        }
        #endif
    }

}
