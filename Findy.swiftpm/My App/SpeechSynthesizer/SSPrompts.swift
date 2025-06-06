import Foundation

// A list of predefined Speech Synthesizer propmpts
enum SSPrompts {
    static let captureFirstItem = "Let's capture your first item! Choose an object and take \(AppMetrics.maxPhotoArrayCapacity) photos from different angles."
    static let trainAI = "Great shot! Now, could you take a few more photos of this item?"
    static let halfway = "We're halfway there—just \(AppMetrics.maxPhotoArrayCapacity/2) more photos to go!"
    static let searching = "Searching for your item. Please move your iPad slowly and show me different views of your room."
}
