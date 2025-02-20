import SwiftUI

struct ArrowView: View {
    var degrees: (yaw: Float, pitch: Float, roll: Float)
    
    var body: some View {
        // Convert the yaw and pitch from Float to Double for use with SwiftUI's rotation effects
        let yawDegrees = Double(degrees.yaw)
        let pitchDegrees = Double(degrees.pitch)
        
        Image(systemName: "arrow.up")
            .font(.system(size: 180, weight: .heavy))
            // Apply a 3D rotation based on the yaw angle. The arrow rotates around the Z-axis.
            .rotation3DEffect(
                .init(degrees: -yawDegrees),
                axis: (x: 0, y: 0, z: 1),
                perspective: 0
            )
        
            // Apply a 3D rotation based on the pitch angle. The arrow rotates around the X-axis.
            // The pitch angle is clamped to a range of -60 to 60 degrees to limit the arrow's tilt.
            .rotation3DEffect(
                .init(degrees: (-pitchDegrees + 90).clamped(to: -60 ... 60)),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
            // Overlay the LiquidCirclesView on top of the arrow.
            .overlay {
                LiquidCirclesView(degrees: yawDegrees)
            }
    }
}

struct CircularArc: Shape {
    let startAngle: Double
    let endAngle: Double
    let clockwise: Bool
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(degrees: startAngle),
            endAngle: Angle(degrees: endAngle),
            clockwise: clockwise
        )
        return path
    }
}

struct CircularProgressView: View {
    let degrees: Double
    
    var body: some View {
        // Normalize the degrees to be within the range of 0 to 360.
        let normalizedDegrees = degrees.remainder(dividingBy: 360)
        // Determine if the arc should be drawn clockwise or counter-clockwise.
        let isClockwise = normalizedDegrees < 0
        
        return CircularArc(
            startAngle: 0,
            endAngle: normalizedDegrees,
            clockwise: isClockwise
        )
        // Apply a white stroke with a specified line width, line cap, and dash pattern.
        .stroke(
            .white,
            style: StrokeStyle(lineWidth: 40, lineCap: .round, dash: [0.1, 50])
        )

        .rotationEffect(.degrees(-90))
        .accessibilityHidden(true)
    }
}
