import Foundation

// An extension to clamp a CGFloat into a closed range.
extension CGFloat {
    func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
