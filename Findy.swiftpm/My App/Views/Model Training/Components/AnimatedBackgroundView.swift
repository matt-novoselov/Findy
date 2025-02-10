import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var timeValue: Float = 0.0
    @State private var animationTimer: Timer?
    
    var body: some View {
        CanvasRenderer(
            colorSequence: [
                .black, .black, .black,
                .orange, .red, .orange,
                .indigo, .black, .green
            ],
            timeParameter: timeValue
        )
        .onAppear { initiateAnimationCycle() }
    }
    
    private func initiateAnimationCycle() {
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.015,
            repeats: true
        ) { _ in
            timeValue += 0.03
        }
    }
}

struct CanvasRenderer: View {
    let colorSequence: [Color]
    let timeParameter: Float
    
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: generateDynamicPoints(),
            colors: colorSequence,
            background: .black
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func generateDynamicPoints() -> [SIMD2<Float>] {
        [
            [0.0, 0.0],
            [0.5, 0.0],
            [1.0, 0.0],
            [
                oscillateValue(
                    phase: 0.342,
                    within: -0.8...(-0.2),
                    shift: 0.439,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.984,
                    within: 0.3...0.7,
                    shift: 3.42,
                    at: timeParameter
                )
            ],
            [
                oscillateValue(
                    phase: 0.084,
                    within: 0.1...0.8,
                    shift: 0.239,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.242,
                    within: 0.2...0.8,
                    shift: 5.21,
                    at: timeParameter
                )
            ],
            [
                oscillateValue(
                    phase: 0.084,
                    within: 1.0...1.5,
                    shift: 0.939,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.642,
                    within: 0.4...0.8,
                    shift: 0.25,
                    at: timeParameter
                )
            ],
            [
                oscillateValue(
                    phase: 0.442,
                    within: -0.8...0.0,
                    shift: 1.439,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.984,
                    within: 1.4...1.9,
                    shift: 3.42,
                    at: timeParameter
                )
            ],
            [
                oscillateValue(
                    phase: 0.784,
                    within: 0.3...0.6,
                    shift: 0.339,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.772,
                    within: 1.0...1.2,
                    shift: 1.22,
                    at: timeParameter
                )
            ],
            [
                oscillateValue(
                    phase: 0.056,
                    within: 1.0...1.5,
                    shift: 0.939,
                    at: timeParameter
                ),
                oscillateValue(
                    phase: 0.342,
                    within: 1.3...1.7,
                    shift: 0.47,
                    at: timeParameter
                )
            ]
        ]
    }
    
    private func oscillateValue(
        phase: Float,
        within bounds: ClosedRange<Float>,
        shift: Float,
        at currentTime: Float
    ) -> Float {
        let delta = (bounds.upperBound - bounds.lowerBound) * 0.5
        let center = (bounds.upperBound + bounds.lowerBound) * 0.5
        return center + delta * sin(phase * currentTime + shift)
    }
}


#Preview {
    AnimatedBackgroundView()
}
