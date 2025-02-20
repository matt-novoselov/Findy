import Foundation

// Extension to calculate area and midpoint for CGRect
extension CGRect {
    // Computed property to calculate the area of the CGRect.
    var area: CGFloat { width * height }
    
    // Computed property to calculate the midpoint of the CGRect.
    var midPoint: CGPoint { CGPoint(x: midX, y: midY) }
}
