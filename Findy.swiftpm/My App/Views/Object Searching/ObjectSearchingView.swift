import SwiftUI

struct ObjectSearchingView: View {
    @Environment(ARSceneCoordinator.self) private var arCoordinator
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    @State private var hasTargetObjectBeenDetected: Bool = false
    @State private var isOnboardingActive: Bool = true
    
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
        
            .overlay(alignment: .topLeading){
                SearchingLabelView()
                    .padding()
                    .padding(.top)
                    .ignoresSafeArea()
            }
        
            // MARK: Arrow
            .overlay{
                if let currentMeasurement = arCoordinator.currentMeasurement {
                    ArrowView(degrees: Double(currentMeasurement.rotationDegrees))
                }
            }
        
            // MARK: Distance measurements
            .overlay(alignment: .bottom){
                if let currentMeasurement = arCoordinator.currentMeasurement {
                    DynamicFontMeasurementsView(numericValue: currentMeasurement.numericValue, unitSymbol: currentMeasurement.unitSymbol, referenceText: currentMeasurement.getDirection.0)
                        .padding()
                }
            }
        
            .allowsHitTesting(false)
        
            .toolbar(isOnboardingActive ? .hidden : .visible, for: .tabBar)
        
            // Onboarding
            .overlay{
                Group{
                    if isOnboardingActive{
                        OnboardingAlertView(card: ObjectSearchViewModel(action: {
                            isOnboardingActive = false
                            arCoordinator.shouldSearchForTargetObject = true
                            arCoordinator.coachingOverlayView?.setActive(true, animated: true)
                            speechSynthesizer.speak(text: SSPrompts.searching)
                        }).card)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    }
                }
                .animation(.spring, value: isOnboardingActive)
            }
        
            .onChange(of: hasTargetObjectBeenDetected){
                arCoordinator.coachingOverlayView?.setActive(false, animated: false)
            }
        
            .onAppear{
                arCoordinator.hasTargetObjectBeenDetected = $hasTargetObjectBeenDetected
            }
            
            .onChange(of: arCoordinator.currentMeasurement?.getDirection.1){
                let currentMeasurement = arCoordinator.currentMeasurement
                if let distance = currentMeasurement?.formattedValue, let direction = currentMeasurement?.getDirection.1, let object = appViewModel.savedObject.targetDetectionObject {
                    speechSynthesizer.speak(text: "\(object) is \(distance) \(direction) ")
                }
            }

    }
}
