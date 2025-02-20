import UIKit

// Function to save UIImages to temporary files and return their URLs.
func getImageURLs(from images: [UIImage]) -> [URL] {
    var urls = [URL]()
    // Get the temporary directory for storing the images.
    let tempDirectory = FileManager.default.temporaryDirectory
    
    // Iterate through the predifined images and save them as JPEG files.
    for (index, image) in images.enumerated() {
        // Create a unique file name for each image.
        let fileName = "croppedImage_\(index).jpg"
        // Create the file URL by appending the file name to the temporary directory.
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Convert the UIImage to JPEG data.
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                // Write the JPEG data to the file URL.
                try data.write(to: fileURL)
                // Append the file URL to the array of URLs.
                urls.append(fileURL)
            } catch {
                print("Error saving image \(index): \(error)")
            }
        }
    }
    // Return the array of file URLs.
    return urls
}
