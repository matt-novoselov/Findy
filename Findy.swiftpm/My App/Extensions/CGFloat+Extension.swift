import Foundation

// An extension to clamp a CGFloat into a closed range.
extension CGFloat {
    // Clamps the CGFloat value to be within the specified range.
    func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        // Use min and max to ensure the value stays within the range.
        return Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
