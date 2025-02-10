import SwiftUI

struct ObjectSearchingView: View {
    @Environment(ARCoordinator.self) private var arCoordinator
    
    var body: some View {
        Color.clear
            // MARK: Glowing effect
            .background{
                GlowingEdgesView()
                    .ignoresSafeArea()
            }
        
            // MARK: Arrow & Measurements
            .overlay{
                if let currentMeasurement = arCoordinator.currentMeasurement {
                    ArrowView(degrees: Double(currentMeasurement.rotationDegrees))
                    
                    DynamicFontMeasurementsView(numberValue: currentMeasurement.numericValue, measurementString: currentMeasurement.unitSymbol, text2: getDirection(degrees: Double(currentMeasurement.rotationDegrees)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding()
                }
            }
            .allowsHitTesting(false)
            
            .onChange(of: arCoordinator.detectionResults) {
                arCoordinator.shootRaycastAtDetectedResult()
            }
    }
}
