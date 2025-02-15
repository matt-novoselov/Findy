final class ModelTrainingCoordinator {
    func runTraining(with takenPhotos: [CapturedPhoto]) async throws -> ModelTrainingResult {
        // 1. Compute average label.
        let labels = takenPhotos.compactMap { $0.processedObservation.label }
        let averageLabel = AverageLabelService.computeAverageLabel(from: labels)
        
        // 2. Crop photos in parallel.
        let croppedPhotos = try await ImageCroppingService.cropImages(from: takenPhotos)
        
        // 3. Determine aesthetics scores and train classifier concurrently.
        async let aestheticsResults = AestheticsEvaluationService.evaluate(for: croppedPhotos)
        async let classifierTraining = ImageClassifierTrainerService.train(with: croppedPhotos)
        
        let aestheticScores = try await aestheticsResults
        
        // 4. Select the most beautiful image.
        guard let mostBeautiful = aestheticScores.max(
            by: { ($0.score?.overallScore ?? 0) < ($1.score?.overallScore ?? 0) }
        )?.image else {
            throw TrainingError.noBeautifulImage
        }
        
        // 5. Remove background from the chosen image.
        let resultImage = try await removeBackground(from: mostBeautiful)
        
        // 6. Classify the cut-out image.
        let classifications = try await ImageClassificationService.classify(image: resultImage)
        let filtered = ImageClassificationService.filterIdentifiers(from: classifications)
        var processedClassifications = filtered.map { $0.processedMLTag }
        if let avgLabel = averageLabel?.processedMLTag,
           !processedClassifications.contains(avgLabel) {
            processedClassifications.append(avgLabel)
        }
        
        // 7. Await classifier training.
        let trainedModel = try await classifierTraining
        
        return ModelTrainingResult(
            objectCutOutImage: resultImage,
            averageLabel: averageLabel,
            visionClassifications: processedClassifications,
            trainedModel: trainedModel
        )
    }
}
