import Foundation

enum BackgroundRemovalError: Error {
    case ciImageConversionFailed
    case maskGenerationFailed
    case maskApplicationFailed
    case cgImageConversionFailed
}
