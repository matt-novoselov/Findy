import Foundation

// MARK: - Helper Extensions
extension CGRect {
    var area: CGFloat { width * height }
    var midPoint: CGPoint { CGPoint(x: midX, y: midY) }
}
