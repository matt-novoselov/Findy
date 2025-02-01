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
            Group{
                if appViewModel != nil, arCoordinator != nil {
                    ProxyBootstrapView()
                        .environment(appViewModel)
                        .environment(arCoordinator)
                        .environment(speechSynthesizer)
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
}

struct ProxyBootstrapView: View {    
    var body: some View {
        ContentView()
            .colorScheme(.dark)
            .persistentSystemOverlays(.hidden)
            .statusBarHidden()
    }
}
