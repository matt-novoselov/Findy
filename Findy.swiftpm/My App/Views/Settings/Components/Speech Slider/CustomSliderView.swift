import SwiftUI

struct CustomSliderView: View {
    @Binding var value: Double
    var sliderRange: ClosedRange<Double> = 1...100
    // Number of markers to display
    var majorStepCount: Int = 10

    // This variable “locks in” the thumb’s starting coordinate when a drag starts.
    @State private var dragInitialThumbPosition: CGFloat? = nil

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            // Calculate the center line for vertical alignment.
            let centerY = height / 2

            // Define thumb size relative to the available height.
            let thumbSize = height * 0.8

            // Allow the thumb to move within these horizontal limits.
            // We use half the thumb size as padding on either side.
            let minX = thumbSize / 2
            let maxX = width - thumbSize / 2

            // The available horizontal space for the thumb.
            let availableWidth = maxX - minX

            // Compute how wide one “unit” is based on the slider’s numeric range.
            let sliderRangeSpan = CGFloat(sliderRange.upperBound - sliderRange.lowerBound)
            let stepWidth = availableWidth / sliderRangeSpan

            // Current thumb's x position based on the binding value.
            let currentThumbX =
                CGFloat(value - sliderRange.lowerBound) * stepWidth + minX

            // Define the track height. We'll center it vertically.
            let trackHeight = height

            // Compute an array of marker values along the slider range.
            let markerValues: [Double] = {
                guard majorStepCount > 1 else { return [sliderRange.lowerBound] }
                let stepValue = (sliderRange.upperBound - sliderRange.lowerBound) /
                    Double(majorStepCount - 1)
                return (0..<majorStepCount).map {
                    sliderRange.lowerBound + Double($0) * stepValue
                }
            }()

            // Configure the drag gesture.
            let dragGesture = DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    // On the first update, capture the initial thumb x position.
                    if dragInitialThumbPosition == nil {
                        dragInitialThumbPosition = currentThumbX
                    }
                    
                    // Safely unwrap dragInitialThumbPosition
                    guard let initialThumbX = dragInitialThumbPosition else { return }
                    
                    // Compute the new thumb position by adding the drag translation.
                    let newPosition = (initialThumbX + drag.translation.width)
                        .clamped(to: minX...maxX)
                    
                    // Convert the x coordinate back into a slider value.
                    let newValue = Double((newPosition - minX) / stepWidth) + sliderRange.lowerBound
                    value = newValue
                }
                .onEnded { drag in
                    if let start = dragInitialThumbPosition {
                        let newPosition = (start + drag.translation.width)
                            .clamped(to: minX...maxX)
                        let newValue = Double((newPosition - minX) / stepWidth) +
                            sliderRange.lowerBound
                        value = newValue
                    }
                    dragInitialThumbPosition = nil
                }

            // Build the slider view.
            ZStack {
                // Slider track: a capsule is used for a rounded horizontal track.
                RecessedRectangleView(cornerRadius: .infinity)
                    .frame(height: trackHeight)
                    .position(x: width / 2, y: centerY)
                    .background {
                        Circle()
                            .fill(.white.opacity(0.4))
                            .blur(radius: 10)
                            .scaleEffect(8)
                            .position(x: currentThumbX, y: centerY)
                            .blendMode(.overlay)
                    }

                // Markers along the track.
                ForEach(markerValues, id: \.self) { markerValue in
                    let markerX =
                        CGFloat(markerValue - sliderRange.lowerBound) * stepWidth + minX
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 6, height: 6)
                        .position(x: markerX, y: centerY)
                }

                // The thumb control.
                Circle()
                    .fill(.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .white, radius: 10)
                    .position(x: currentThumbX, y: centerY)
                    .gesture(dragGesture)
                    .accessibilityLabel("Slider thumb") // Provide accessibility label for the thumb
            }
            .animation(.bouncy(duration: 0.5), value: currentThumbX)
        }
        .clipShape(.capsule)
    }
}
