//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SpeechSynthesizer.self) private var speechSynthesizer
    @Environment(AppViewModel.self) private var appViewModel
#if canImport(CreateML)
    @State private var imageClassifierModel: MLImageClassifier?
#endif
    var body: some View {
        @Bindable var speechSynthesizer = speechSynthesizer
        @Bindable var appViewModel = appViewModel
        
        VStack{
            SpeechSpeedSliderView()
                .padding()
            
            Toggle(isOn: $speechSynthesizer.isSpeechSynthesizerEnabled, label: { Text("Enable Speech Synthesizer") })
            
            Toggle(isOn: $appViewModel.isMetalDetectionSoundEnabled, label: { Text("Enable Metal Detection sound") })
            
            Button("Reset Object Detection"){
                appViewModel.hasObjectBeenDetected.toggle()
            }
            
            @Bindable var appViewModel = appViewModel
            
            Toggle("Debug", isOn: $appViewModel.isDebugMode)
                .toggleStyle(.switch)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
                .padding()
                .frame(width: 200)
            
#if canImport(CreateML)
            Button("Train Model"){
                imageClassifierModel = trainModel()
            }
            
            if (imageClassifierModel != nil) {
                Button("Predict"){
//                    let croppedImage =
                    let prediction = try! imageClassifierModel?.prediction(from: appViewModel.lastCroppedImage!)
                    print(prediction)
                }
            }
#endif
        }
        .padding()
        
    }
}

#if canImport(CreateML)
import CreateML
import CoreML

func trainModel() -> MLImageClassifier {
    
    // 1. Get all jpg file URLs from the main bundle.
    guard let jpgURLs = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: nil) else {
        fatalError("No jpg files found in the bundle")
    }

    // 2. Filter to files whose name starts with "GeneralObject".
    let generalObjectURLs = jpgURLs.filter { $0.lastPathComponent.hasPrefix("GeneralObject") }
    
    // 1. Get all png file URLs from the main bundle.
    guard let pngURLs = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: nil) else {
        fatalError("No jpg files found in the bundle")
    }

    // 2. Filter to files whose name starts with "myObject".
    let myObjectURLs = pngURLs.filter { $0.lastPathComponent.hasPrefix("myObject") }

    // 3. Create the dictionary
    let generalObjectsDict: [String: [URL]] = ["GeneralObject": generalObjectURLs, "myObject": myObjectURLs]

    let dataset: MLImageClassifier.DataSource = .filesByLabel(generalObjectsDict)

    let trainParameters: MLImageClassifier.ModelParameters = .init(
        validation: .split(strategy: .automatic),
        maxIterations: 100,
        augmentation: [.blur, .exposure, .flip, .noise, .rotation]
    )
    
    let imageClassifierModel = try! MLImageClassifier(
        trainingData: dataset,
        parameters: trainParameters
    )
    
    return imageClassifierModel
}
#endif
