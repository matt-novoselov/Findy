//
//  ArrowView.swift
//  Findy
//
//  Created by Matt Novoselov on 06/02/25.
//

import SwiftUI

struct ArrowView: View {
    var degrees: Double = 0
    
    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 180, weight: .heavy))
            .overlay{
                Image(systemName: "circle.fill")
                    .font(.title)
                    .offset(y: -160)
            }
            .rotationEffect(.init(degrees: -degrees))
            .background{
                Image(systemName: "circle.fill")
                    .font(.title)
                    .offset(y: -160)
            }
            .background{
                CircularProgressView(degrees: -degrees)
                    .padding(-65)
            }
    }
}

extension View {
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
            self.mask(
                ZStack {
                    Rectangle()

                    mask()
                        .blendMode(.destinationOut)
                }
            )
        }
}

#Preview{
    @Previewable @State var degrees: Double = 0
    VStack{
        ArrowView(degrees: degrees)

        Slider(value: $degrees, in: -360...360)
            .padding()
        
        Text(normalizedDegrees(degrees).description)
        
        // Add the direction text
        Text("Pointing: \(getDirection(degrees: degrees))")
            .padding()
            .font(.title)
    }
    .padding()
}

struct CircularArc: Shape {
    let startAngle: Double
    let endAngle: Double
    // When drawing with addArc, “clockwise” means “drawing in the decreasing angle direction”
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
    private let adjustment: Double = 15
    
    var body: some View {
        let normalizedDegrees = degrees.remainder(dividingBy: 360)
        let isClockwise = normalizedDegrees < 0
        let startAngle = isClockwise ? -adjustment : adjustment
        let endAngle = normalizedDegrees + (isClockwise ? adjustment : -adjustment)
        
        return CircularArc(
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: isClockwise
        )
        .stroke(Color.black.tertiary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
        .animation(.easeOut, value: degrees)
        .rotationEffect(.degrees(-90))
        .opacity(abs(degrees) < adjustment*2 ? 0 : 1)
        .opacity(abs(degrees) > 360-adjustment*2 ? 0 : 1)
    }
}

// Add this function to calculate the direction
func getDirection(degrees: Double) -> String {
    let normalizedDegrees = normalizedDegrees(degrees)
    let angle = normalizedDegrees
    if (0...45).contains(angle) || (315...360).contains(angle) {
        return "Ahead"
    } else if (225...315).contains(angle) {
        return "Right"
    } else if (135...225).contains(angle) {
        return "Behind"
    } else {
        return "Left"
    }
}

func normalizedDegrees(_ degrees: Double) -> Double {
    let modDegrees = degrees.truncatingRemainder(dividingBy: 360)
    return modDegrees >= 0 ? modDegrees : modDegrees + 360
}
