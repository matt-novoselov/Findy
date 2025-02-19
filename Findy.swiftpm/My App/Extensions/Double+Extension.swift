import Foundation

extension Double {
    func clamped(to limits: ClosedRange<Double>) -> Double {
        return Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
