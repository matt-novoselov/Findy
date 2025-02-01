//
//  ARContainer.swift
//  TestRealityKit
//
//  Created by Matt Novoselov on 25/01/25.
//

import ARKit
import RealityKit
import SwiftUI
import Combine

// MARK: - AR View Container
struct ARContainer: UIViewRepresentable {
    var coordinator: ARCoordinator
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        coordinator.setup(arView: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - AR Coordinator
@Observable
class ARCoordinator {
    // Weak reference to prevent retain cycle
    private weak var arView: ARView?
    
    // Measurement state
    private(set) var currentMeasurement: Measurement?
    
    // Object Detection
    private(set) var detectionResults: [ProcessedObservation] = []
    private let objectDetection: ObjectDetection
    
    // AR tracking properties
    private var sceneUpdateSubscription: Cancellable?
    private var trackedAnchor: AnchorEntity?
    private var activeRaycast: ARTrackedRaycast?
    public var normalizedCaptureImage: CIImage?
    
    weak var appViewModel: AppViewModel?
    
    init(objectDetection: ObjectDetection) {
        self.objectDetection = objectDetection
    }
    
    deinit {
        cleanUpResources()
    }
    
    // MARK: - Configuration
    func setup(arView: ARView) {
        self.arView = arView
        setupSceneUpdates()
    }
    
    // MARK: - Scene Updates
    private func setupSceneUpdates() {
        sceneUpdateSubscription = arView?.scene.subscribe(
            to: SceneEvents.Update.self,
            { [weak self] _ in
                self?.processFrameUpdates()
            }
        )
    }
    
    private func processFrameUpdates() {
        updateMeasurements()
        performObjectDetection()
    }
    
    // MARK: - Measurement Handling
    private func updateMeasurements() {
        guard let arView, let currentFrame = arView.session.currentFrame, let anchor = trackedAnchor else {
            currentMeasurement = nil
            return
        }
        
        let cameraPosition = currentFrame.camera.transform.position
        let anchorPosition = anchor.transform.translation
        
        let distance = simd_distance(cameraPosition, anchorPosition)
        currentMeasurement = Measurement(
            meterDistance: distance
        )
    }
    
    // MARK: - Object Detection
    private func performObjectDetection() {
        // Ensure we have a valid AR frame to process
        guard let currentFrame = arView?.session.currentFrame else {
            detectionResults = [] // Clear previous results
            print("[ObjectDetection] Error: No AR frame available")
            return
        }

        // Get interface orientation for image transformation
        guard let interfaceOrientation = arView?.window?.windowScene?.interfaceOrientation else {
            detectionResults = []
            print("[ObjectDetection] Error: Failed to get interface orientation")
            return
        }

        // Get viewport size for image transformation
        let viewPortSize = UIScreen.main.bounds.size

        // Create transform to convert from camera buffer to view orientation
        let orientationTransform = currentFrame.displayTransform(
            for: interfaceOrientation,
            viewportSize: viewPortSize
        ).inverted()

        // Convert camera buffer to Core Image and apply orientation correction
        let cameraPixelBuffer = currentFrame.capturedImage
        let cameraImage = CIImage(cvPixelBuffer: cameraPixelBuffer)
        self.normalizedCaptureImage = cameraImage.transformed(by: orientationTransform)
        
        guard let normalizedCaptureImage else {
            detectionResults = []
            print("[ObjectDetection] Error: Failed to transform camera image")
            return
        }

        // Update view model with current image dimensions
        appViewModel?.cameraImageDimensions = normalizedCaptureImage.extent.size

        // Perform detection and update results
        detectionResults = objectDetection.detectAndProcess(image: normalizedCaptureImage)
    }
    
    // MARK: - Raycast Handling
    func handleRaycast(at location: CGPoint) {
        guard let arView else {
            print("ARView not available")
            return
        }
        
        guard let query = arView.makeRaycastQuery(
            from: location,
            allowing: .estimatedPlane,
            alignment: .any
        ) else {
            print("Failed to create raycast query")
            return
        }
        
        let initialResults = arView.session.raycast(query)
        guard !initialResults.isEmpty else {
            print("No surface detected at location")
            return
        }
        
        cleanupPreviousTracking()
        setupNewTracking(with: query)
    }
    
    private func setupNewTracking(with query: ARRaycastQuery) {
        guard let arView else { return }
        
        // Create visual indicator
        let sphereEntity = debugSphere(color: .red)
        let newAnchor = AnchorEntity()
        newAnchor.addChild(sphereEntity)
        arView.scene.addAnchor(newAnchor)
        trackedAnchor = newAnchor
        
        // Start continuous tracking
        activeRaycast = arView.session.trackedRaycast(query) {
            [weak self, weak newAnchor] results in
            guard let self, let newAnchor else { return }
            
            if let result = results.first {
                newAnchor.transform = Transform(matrix: result.worldTransform)
            } else {
                self.cleanupPreviousTracking()
            }
        }
    }
    
    // MARK: - Cleanup
    private func cleanupPreviousTracking() {
        activeRaycast?.stopTracking()
        activeRaycast = nil
        
        if let existingAnchor = trackedAnchor {
            arView?.scene.removeAnchor(existingAnchor)
            trackedAnchor = nil
        }
    }
    
    private func cleanUpResources() {
        sceneUpdateSubscription?.cancel()
        cleanupPreviousTracking()
    }
}
