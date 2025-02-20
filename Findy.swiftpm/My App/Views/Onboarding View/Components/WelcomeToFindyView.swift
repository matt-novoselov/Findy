import SwiftUI

struct WelcomeToFindyView: View {
    // State variables to drive each sequential animation.
    @State private var iconScale: CGFloat = 1.0
    @State private var titleReveal: CGFloat = 0.0
    @State private var showDescription: Bool = false

    var body: some View {
        VStack(spacing: 10) {
            // 1. Bouncy AppIconView animation
            AppIconView(size: 100)
                .scaleEffect(iconScale)
                .padding()

            // 2. Title text that reveals by unfolding a mask from left to right
            Text("Welcome to Findy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .mask {
                    GeometryReader { geo in
                        Rectangle()
                            .frame(
                                width: geo.size.width * titleReveal,
                                alignment: .leading
                            )
                            .blur(radius: 10)
                    }
                }

            // 3. Description text appears with an opacity animation.
            Text("Findy helps users with vision loss to capture, train, and locate their belongings using AI and AR.")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
                .opacity(showDescription ? 1 : 0)
        }
        .frame(width: 500)
        .padding(40)
        .glassBackground(cornerRadius: 60)
        .transition(.opacity)
        .onAppear {
            // 1. Animate AppIconView bounce (scale 1 -> 1.5 -> 1)
            withAnimation(.easeOut(duration: 0.3)) {
                iconScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    iconScale = 1.0
                }
            }

            // 2. Animate the title reveal with a left-to-right mask.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeInOut(duration: 3.0)) {
                    titleReveal = 1.0
                }
            }

            // 3. Animate the description text’s opacity.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showDescription = true
                }
            }
        }
    }
}
