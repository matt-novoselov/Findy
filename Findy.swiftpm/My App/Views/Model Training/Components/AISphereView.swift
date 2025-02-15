import SwiftUI

struct AISphereView: View {
    
    @State private var movingColor: [Color] = [
        Color(hex: 0xC84EF7),
        Color(hex: 0x898CF6),
        Color(hex: 0xF2A3FA),
        Color(hex: 0xEB74F8),
        Color(hex: 0xA78FF8),
    ]
    @State private var animationTimer: Timer?
    
    var body: some View {
        VStack{
            Circle()
                .fill(
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points:
                            [
                                [0,0],[0.5,0],[1,0],
                                [0, 0.5],[0.5,0.5],[1.0, 0.5],
                                [0, 1],[0.5, 1],[1, 1]
                            ],
                        colors: movingColor
                    )
                    .shadow(.inner(color: Color.white, radius: 5, x: 0, y: -5))
                    .shadow(.inner(color: Color(hex: 0xC84EF7), radius: 10, x: 0, y: -10))
                )
                .background(Color(hex: 0xF2A3FA), in: .circle)
                .overlay{
                    Circle()
                        .trim(from: 0.6, to: 0.9)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(
                                lineWidth: 15,
                                lineCap: .round
                            )
                        )
                        .padding(.all, 20)
                        .blur(radius: 15)
                }
                .onAppear { initiateAnimationCycle() }
                .onDisappear{
                    animationTimer?.invalidate()
                }
        }
    }
    
    private func initiateAnimationCycle() {
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { _ in
            withAnimation(.spring(duration: 2)){
                let firstColor = movingColor.removeFirst()
                movingColor.append(firstColor)
            }
        }
    }
}
