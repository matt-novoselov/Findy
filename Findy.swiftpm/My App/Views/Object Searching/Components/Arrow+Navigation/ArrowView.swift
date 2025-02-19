import SwiftUI

struct ArrowView: View {
    var degrees: (yaw: Float, pitch: Float, roll: Float)
    
    var body: some View {
        let yawDegrees = Double(degrees.yaw)
        let pitchDegrees = Double(degrees.pitch)
        
        Image(systemName: "arrow.up")
            .font(.system(size: 180, weight: .heavy))
            .rotation3DEffect(
                .init(degrees: -yawDegrees),
                axis: (x: 0, y: 0, z: 1),
                perspective: 0
            )
            .rotation3DEffect(
                .init(degrees: (-pitchDegrees + 90).clamped(to: -60...60)),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay{
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

//#Preview{
//    @Previewable @State var degrees: Double = 0
//    VStack{
//        ArrowView(degrees: degrees)
//
//        Slider(value: $degrees, in: -360...360)
//            .padding()
//
////        // Add the direction text
////        Text("Pointing: \(getDirection(degrees: degrees))")
////            .fontDesign(.rounded)
////            .font(.title)
////            .padding()
//    }
//    .padding()
//}
