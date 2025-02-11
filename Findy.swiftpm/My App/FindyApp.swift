import SwiftUI

@main
struct FindyApp: App {
    
    @State private var objectDetection: ObjectDetection?
    @State private var appViewModel: AppViewModel?
    @State private var arCoordinator: ARSceneCoordinator?
    @State private var speechSynthesizer: SpeechSynthesizer?
    @State private var toastManager: ToastManager?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if ProcessInfo.processInfo.isMacCatalystApp || isMacOS || isSimulator {
                    ContentUnavailableView {
                        Text("Findy App")
                            .font(.title)
                    } description: {
                        Text("This app isn't available on macOS or the simulator.\nFor the best experience, please use **Swift Playground 4.6 on iPad.**")
                    }
                } else {
                    if appViewModel != nil, arCoordinator != nil {
                        ProxyBootstrapView()
                            .environment(appViewModel)
                            .environment(arCoordinator)
                            .environment(speechSynthesizer)
                            .environment(toastManager)
                    } else {
                        ProgressView()
                    }
                }
            }
            .task{
                // Initialize classes
                self.objectDetection = .init()
                self.appViewModel = AppViewModel()
                self.arCoordinator = ARSceneCoordinator(objectDetection: self.objectDetection!)
                self.speechSynthesizer = SpeechSynthesizer()
                self.toastManager = ToastManager()
                
                // Set weak vars
                objectDetection?.appViewModel = self.appViewModel
                arCoordinator?.appViewModel = self.appViewModel
                arCoordinator?.speechSynthesizer = self.speechSynthesizer
                arCoordinator?.toastManager = self.toastManager
            }
        }
    }
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
}

struct ProxyBootstrapView: View {    
    var body: some View {
        ToastContainer{
            ContentView()
                .colorScheme(.dark)
                .persistentSystemOverlays(.hidden)
        }
    }
}
