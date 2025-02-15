import UIKit

struct ImageCroppingService {
    static func cropImages(from takenPhotos: [CapturedPhoto]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage?.self) { group in
            for takenPhoto in takenPhotos {
                group.addTask {
                    let photo = takenPhoto.photo
                    let boundingBox = takenPhoto.processedObservation.boundingBox
                    
                    guard boundingBox.size.width > 0, boundingBox.size.height > 0,
                          let croppedCGImage = photo.cropping(to: boundingBox)
                    else {
                        return nil
                    }
                    return UIImage(cgImage: croppedCGImage)
                }
            }
            
            var results = [UIImage]()
            for try await cropped in group {
                if let image = cropped {
                    results.append(image)
                }
            }
            return results
        }
    }
}
