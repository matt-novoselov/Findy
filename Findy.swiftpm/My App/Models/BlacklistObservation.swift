import Foundation

// Static array of blacklisted object identifiers that will be excluded from the object detection results
enum BlacklistObservation {
    static let items: [String] = [
        "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat",
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
        "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "bed", "chair", "couch", "dining table", "toilet", "tv", "refrigerator"
    ]
}
