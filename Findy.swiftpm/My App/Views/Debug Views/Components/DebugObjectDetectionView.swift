import SwiftUI

struct DebugObjectDetectionView: View {
    
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        // Display object detection results if debug mode is enabled.
        if appViewModel.isDebugMode{
            // Adjust the bounding boxes to match the view's coordinate system.
            let adjustedResults = adjustObservations(
                detectionResults: arCoordinator.detectedObjects,
                cameraImageDimensions: appViewModel.cameraImageDimensions
            )
            // Get the dimensions of the camera image.
            let imageDimensions = appViewModel.cameraImageDimensions
            
            // Iterate through the adjusted results and display bounding boxes.
            ForEach(adjustedResults, id: \.id) { result in
                BoundingBox(result: result)
            }
            .aspectRatio(imageDimensions.width / imageDimensions.height, contentMode: .fit)
            .allowsHitTesting(false)
        }

    }
}

struct BoundingBox: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    var result: ProcessedObservation
    
    var body: some View {
        // Get the bounding box rectangle.
        let rect = result.boundingBox
        // Determine the color of the bounding box based on whether it's the target object.
        let boxColor: Color = (result.label == appViewModel.savedObject.targetDetectionObject) ? Color.green : .red
        
        ZStack(alignment: .topLeading) {
            // Draw bounding box
            Rectangle()
                .stroke(boxColor, lineWidth: 2)
                .background(boxColor.opacity(0.1))
            
            // Label and confidence
            Text("\(result.label) \(String(format: "%.1f", result.confidence * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .padding(4)
                .background(.black.opacity(0.7))
                .cornerRadius(4)
                .offset(y: -20)
        }
        // Set the frame size and position of the bounding box.
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.midX, y: rect.midY)
    }
}
