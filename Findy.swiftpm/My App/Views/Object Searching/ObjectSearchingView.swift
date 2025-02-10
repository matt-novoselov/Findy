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
                    
                    DynamicFontMeasurementsView(numericValue: currentMeasurement.numericValue, unitSymbol: currentMeasurement.unitSymbol, referenceText: getDirection(degrees: Double(currentMeasurement.rotationDegrees)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding()
                }
            }
        
            .allowsHitTesting(false)
    }
}
