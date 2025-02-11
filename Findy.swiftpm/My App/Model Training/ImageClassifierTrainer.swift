#if canImport(CreateML)
import CreateML
import Foundation

final class ImageClassifierTrainer {
    public func train(on customImages: [UIImage]) async throws -> MLImageClassifier {
        let generalObjects = try ImageClassifierTrainer.loadImageURLs(
            extension: "jpg",
            prefix: "GeneralObject"
        )
        
        let customObjects: [URL] = getImageURLs(from: customImages)
        
        let trainingData: [String: [URL]] = [
            "GeneralObject": generalObjects,
            "myObject": customObjects
        ]
        
        let parameters = MLImageClassifier.ModelParameters(
            validation: .split(strategy: .automatic),
            maxIterations: 100,
            augmentation: [.blur, .exposure, .flip, .noise, .rotation]
        )
        
        return try await Task.detached(priority: .userInitiated) {
            try MLImageClassifier(
                trainingData: .filesByLabel(trainingData),
                parameters: parameters
            )
        }.value
    }
}
#endif

import UIKit

func getImageURLs(from images: [UIImage]) -> [URL] {
    var urls = [URL]()
    let tempDirectory = FileManager.default.temporaryDirectory
    
    for (index, image) in images.enumerated() {
        let fileName = "croppedImage_\(index).jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
                urls.append(fileURL)
            } catch {
                print("Error saving image \(index): \(error)")
            }
        }
    }
    return urls
}
