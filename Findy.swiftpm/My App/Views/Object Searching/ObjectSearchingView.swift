import SwiftUI

struct ObjectSearchingView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @State private var hasTargetObjectBeenDetected: Bool = false
    
    var body: some View {
        Color.clear
            // MARK: Ripple View
            .background{
                RippleEffectView(objectDetected: hasTargetObjectBeenDetected)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        
            // MARK: Glowing effect
            .background{
                GlowingEdgesView(objectDetected: hasTargetObjectBeenDetected)
                    .ignoresSafeArea()
            }
        
            // MARK: Arrow & Measurements
            .overlay{
                if let currentMeasurement = arCoordinator.currentMeasurement {
                    ArrowView(degrees: Double(currentMeasurement.rotationDegrees))
                }
            }
        
            .overlay(alignment: .bottom){
                if let currentMeasurement = arCoordinator.currentMeasurement {
                    DynamicFontMeasurementsView(numericValue: currentMeasurement.numericValue, unitSymbol: currentMeasurement.unitSymbol, referenceText: getDirection(degrees: Double(currentMeasurement.rotationDegrees)))
                        .padding()
                }
            }
        
            .allowsHitTesting(false)
        
            .onAppear{
                arCoordinator.hasTargetObjectBeenDetected = $hasTargetObjectBeenDetected
            }

    }
}
