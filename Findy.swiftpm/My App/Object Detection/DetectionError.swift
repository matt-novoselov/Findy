import Foundation

/// Custom error types for detection initialization
enum DetectionError: Error {
    case modelConversionFailed
    case modelLoadingFailed
}

extension DetectionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .modelConversionFailed:
            return "Failed to convert Core ML model to Vision model"
        case .modelLoadingFailed:
            return "Failed to load Core ML model"
        }
    }
}
