import SwiftUI

struct ArrowView: View {
    var degrees: Double = 0
    
    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 180, weight: .heavy))
            .rotationEffect(.init(degrees: -degrees))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay{
                LiquidCirclesView(degrees: degrees)
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
        let normalizedDegrees = degrees.remainder(dividingBy: 360)
        let isClockwise = normalizedDegrees < 0
        
        return CircularArc(
            startAngle: 0,
            endAngle: normalizedDegrees,
            clockwise: isClockwise
        )
        .stroke(.white, style: StrokeStyle(lineWidth: 40, lineCap: .round, dash: [0.1, 50]))
        .rotationEffect(.degrees(-90))
    }
}

// Add this function to calculate the direction
func getDirection(degrees: Double) -> String {
    let normalizedDegrees = normalizedDegrees(degrees)
    let angle = normalizedDegrees
    if (0...25).contains(angle) || (335...360).contains(angle) {
        return "In front"
    } else if (225...335).contains(angle) {
        return "To the right"
    } else if (135...225).contains(angle) {
        return "Behind"
    } else {
        return "To the left"
    }
    
    func normalizedDegrees(_ degrees: Double) -> Double {
        let modDegrees = degrees.truncatingRemainder(dividingBy: 360)
        return modDegrees >= 0 ? modDegrees : modDegrees + 360
    }
}

#Preview{
    @Previewable @State var degrees: Double = 0
    VStack{
        ArrowView(degrees: degrees)

        Slider(value: $degrees, in: -360...360)
            .padding()

        // Add the direction text
        Text("Pointing: \(getDirection(degrees: degrees))")
            .fontDesign(.rounded)
            .font(.title)
            .padding()
    }
    .padding()
}
