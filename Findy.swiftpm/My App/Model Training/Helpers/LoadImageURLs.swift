import Foundation

#if canImport(CreateML)
extension ImageClassifierTrainer{
    static func loadImageURLs(extension: String, prefix: String) throws -> [URL] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: `extension`, subdirectory: nil) else {
            throw ModelTrainingError.missingTrainingData
        }
        
        return urls.filter { $0.lastPathComponent.hasPrefix(prefix) }
    }
}
#endif
