import Foundation

// Extension to calculate area and midpoint for CGRect
extension CGRect {
    var area: CGFloat { width * height }
    var midPoint: CGPoint { CGPoint(x: midX, y: midY) }
}
