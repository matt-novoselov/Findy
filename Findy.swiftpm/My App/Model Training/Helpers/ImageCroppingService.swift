import UIKit

struct ImageCroppingService {
    // Asynchronously crops images based on bounding boxes from a list of captured photos.
    static func cropImages(from takenPhotos: [CapturedPhoto]) async throws -> [UIImage] {
        // Use a task group to process the cropping concurrently.
        try await withThrowingTaskGroup(of: UIImage?.self) { group in
            // Iterate through the taken photos and add a task for each.
            for takenPhoto in takenPhotos {
                group.addTask {
                    // Extract the photo and bounding box from the captured photo.
                    let photo = takenPhoto.photo
                    let boundingBox = takenPhoto.processedObservation.boundingBox
                    
                    // Ensure the bounding box has valid dimensions and crop the image.
                    guard boundingBox.size.width > 0, boundingBox.size.height > 0,
                          let croppedCGImage = photo.cropping(to: boundingBox)
                    else {
                        // Return nil if cropping fails.
                        return nil
                    }
                    
                    // Create a UIImage from the cropped CGImage.
                    return UIImage(cgImage: croppedCGImage)
                }
            }
            
            // Collect the results from the task group.
            var results = [UIImage]()
            for try await cropped in group {
                // Append the cropped image to the results if it's not nil.
                if let image = cropped {
                    results.append(image)
                }
            }
            return results
        }
    }
}
