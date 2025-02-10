#if canImport(CreateML)
extension ImageClassifierTrainer{
    enum ModelTrainingError: Error {
        case missingTrainingData
        case trainingFailed(Error)
    }
}
#endif
