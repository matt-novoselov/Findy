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
