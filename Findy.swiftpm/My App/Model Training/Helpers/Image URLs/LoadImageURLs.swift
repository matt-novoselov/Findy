import Foundation

#if canImport(CreateML)
extension ImageClassifierTrainer{
    // Loads image URLs from the main bundle based on a file extension and prefix.
    static func loadImageURLs(extension: String, prefix: String) throws -> [URL] {
        // Get all URLs with the specified file extension from the main bundle.
        guard let urls = Bundle.main.urls(forResourcesWithExtension: `extension`, subdirectory: nil) else {
            throw ModelTrainingError.missingTrainingData
        }
        
        // Filter the URLs to include only those that start with the specified prefix.
        return urls.filter { $0.lastPathComponent.hasPrefix(prefix) }
    }
}
#endif
