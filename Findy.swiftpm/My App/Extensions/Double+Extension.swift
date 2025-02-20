import Foundation

extension Double {
    // Clamps a Double value to be within a specified closed range.
    func clamped(to limits: ClosedRange<Double>) -> Double {
        // Use min and max to ensure the value stays within the range.
        return Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
