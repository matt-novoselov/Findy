//
//  TestRealityKitApp.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 24/01/25.
//

import SwiftUI

@main
struct FindyApp: App {
    
    @State private var objectDetection: ObjectDetection?
    @State private var appViewModel: AppViewModel?
    @State private var arCoordinator: ARCoordinator?
    @State private var speechSynthesizer: SpeechSynthesizer?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if ProcessInfo.processInfo.isMacCatalystApp || isMacOS || isSimulator {
                    ContentUnavailableView {
                        Text("Findy App")
                            .font(.title)
                    } description: {
                        Text("This app is unavailable on macOS and simulator. Please use iPad.")
                    }
                } else {
                    if appViewModel != nil, arCoordinator != nil {
                        ProxyBootstrapView()
                            .environment(appViewModel)
                            .environment(arCoordinator)
                            .environment(speechSynthesizer)
                    } else {
                        ProgressView()
                    }
                }
            }
            .task{
                // Initialize classes
                self.objectDetection = .init()
                self.appViewModel = AppViewModel()
                self.arCoordinator = ARCoordinator(objectDetection: self.objectDetection!)
                self.speechSynthesizer = SpeechSynthesizer()
                
                // Set weak vars
                objectDetection?.appViewModel = self.appViewModel
                arCoordinator?.appViewModel = self.appViewModel
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
        ContentView()
            .colorScheme(.dark)
            .persistentSystemOverlays(.hidden)
            .statusBarHidden()
    }
}
