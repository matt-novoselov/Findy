import ARKit
import RealityKit
import SwiftUI
import Combine


// MARK: - AR Scene Coordinator
@Observable
class ARSceneCoordinator {
    private weak var arView: ARView?
    private let objectDetector: ObjectDetection
    private let pingManager: PingSoundManager = .init()
    
    // Scene state properties
    private var sceneUpdateSubscription: Cancellable?
    private var activeRaycast: ARTrackedRaycast?
    var trackedAnchor: AnchorEntity?
    private(set) var currentMeasurement: SceneMeasurement?
    
    // Detection properties
    private(set) var detectedObjects: [ProcessedObservation] = []
    public var processedFrameImage: CIImage?
    
    weak var appViewModel: AppViewModel?
    weak var speechSynthesizer: SpeechSynthesizer?
    weak var toastManager: ToastManager?
    weak var coachingOverlayView: ARCoachingOverlayView?
    
    var hasTargetObjectBeenDetected: Binding<Bool>?
    var objectDetectedAtPosition: CGPoint?
    var isCoachingActive: Bool = false
    var shouldSearchForTargetObject: Bool = false
    
    var isARContainerVisible: Bool = false
    
    init(objectDetection: ObjectDetection) {
        self.objectDetector = objectDetection
        self.pingManager.arCoordinator = self
    }
    
    deinit { releaseResources() }
}

// MARK: - AR Configuration
extension ARSceneCoordinator {
    func initializeARScene(with view: ARView) {
        arView = view
        configureWorldTracking()
        enableSceneUpdates()
    }
    
    private func configureWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView?.session.run(configuration)
    }
}

// MARK: - Scene Update Handling
extension ARSceneCoordinator {
    private func enableSceneUpdates() {
        sceneUpdateSubscription = arView?.scene.subscribe(
            to: SceneEvents.Update.self,
            { [weak self] _ in self?.processFrame() }
        )
    }
    
    private func processFrame() {
        guard isARContainerVisible else { print("No update"); return }
        guard appViewModel?.state != .onboarding else { print("No update"); return }
        
        updateDistanceMeasurement()
        performFrameAnalysis()
        
        if let currentFrame = arView?.session.currentFrame {
            evaluateLightingConditions(frame: currentFrame)
        }
    }
}

extension ARView: @retroactive ARCoachingOverlayViewDelegate {
    func addCoaching() -> ARCoachingOverlayView {
        let coachingOverlay = ARCoachingOverlayView()

        coachingOverlay.activatesAutomatically = false
             
        // The session this view uses to provide coaching.
        coachingOverlay.session = self.session
        
        coachingOverlay.subviews.forEach { $0.backgroundColor = .clear }
             
        // How a view should resize itself when its superview's bounds change.
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.addSubview(coachingOverlay)
        return coachingOverlay
    }
}

// MARK: - Measurement System
extension ARSceneCoordinator {
    private func updateDistanceMeasurement() {
        guard let arView,
              let frame = arView.session.currentFrame,
              let anchor = trackedAnchor else {
            currentMeasurement = nil
            return
        }
        
        let cameraPosition = frame.camera.transform.position
        let anchorPosition = anchor.transform.translation
        let distance = simd_distance(cameraPosition, anchorPosition)
        
        let directionAngle = calculateAngles(
            cameraTransform: frame.camera.transform,
            targetPosition: anchorPosition
        )
        
        currentMeasurement = SceneMeasurement(
            meterDistance: distance,
            rotationDegrees: directionAngle
        )
    }
    
    private func calculateAngles(
        cameraTransform: simd_float4x4,
        targetPosition: SIMD3<Float>
    ) -> (yaw: Float, pitch: Float, roll: Float) {
        // Extract camera position from the transform’s fourth column.
        let cameraPosition = SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )

        // The camera’s forward vector
        let cameraForward = -SIMD3<Float>(
            cameraTransform.columns.2.x,
            cameraTransform.columns.2.y,
            cameraTransform.columns.2.z
        )
        
        // --- Yaw Calculation ---
        let horizontalForward = simd_normalize(
            SIMD3<Float>(cameraForward.x, 0, cameraForward.z)
        )
        let cameraYaw = atan2(horizontalForward.x, horizontalForward.z)
        
        let directionVector = targetPosition - cameraPosition
        let horizontalDirection = simd_normalize(
            SIMD3<Float>(directionVector.x, 0, directionVector.z)
        )
        let targetYaw = atan2(horizontalDirection.x, horizontalDirection.z)
        
        // Compute yaw difference (in degrees)
        let yawDifference = (targetYaw - cameraYaw) * 180 / .pi

        // --- Pitch Calculation ---
        let cameraPitch = atan2(
            cameraForward.y,
            simd_length(SIMD2<Float>(cameraForward.x, cameraForward.z))
        )
        // Compute the vertical angle from the camera’s position to the target.
        let targetPitch = atan2(
            directionVector.y,
            simd_length(SIMD2<Float>(directionVector.x, directionVector.z))
        )
        let pitchDifference = (targetPitch - cameraPitch) * 180 / .pi

        // --- Roll Calculation ---
        let cameraUp = simd_normalize(
            SIMD3<Float>(
                cameraTransform.columns.1.x,
                cameraTransform.columns.1.y,
                cameraTransform.columns.1.z
            )
        )
        // Define the world up direction.
        let worldUp = SIMD3<Float>(0, 1, 0)
        // Compute the camera’s right vector from world up and camera forward.
        let cameraRight = simd_normalize(simd_cross(worldUp, cameraForward))
        let idealUp = simd_cross(cameraForward, cameraRight)
        
        // Calculate the roll (in radians)
        let rollAngle = atan2(
            simd_dot(simd_cross(idealUp, cameraUp), cameraForward),
            simd_dot(idealUp, cameraUp)
        )
        
        let rollDifference = (-rollAngle) * 180 / .pi

        return (yaw: yawDifference, pitch: pitchDifference, roll: rollDifference)
    }

}

// MARK: - Object Detection
extension ARSceneCoordinator {
    private func performFrameAnalysis() {
        guard let frame = arView?.session.currentFrame else {
            detectedObjects = []
            return
        }
        
        processCameraImage(from: frame)
    }
    
    private func processCameraImage(from frame: ARFrame) {
        guard let interfaceOrientation = arView?.window?.windowScene?.interfaceOrientation else {
            detectedObjects = []
            return
        }
        
        let viewportSize = UIScreen.main.bounds.size
        let orientationTransform = frame.displayTransform(
            for: interfaceOrientation,
            viewportSize: viewportSize
        ).inverted()
        
        let frameImage = CIImage(cvPixelBuffer: frame.capturedImage)
        processedFrameImage = frameImage.transformed(by: orientationTransform)
        
        if shouldSearchForTargetObject{
            analyzeImageWithML()
        }
        
        guard let processedImage = processedFrameImage else {
            detectedObjects = []
            return
        }
        
        appViewModel?.cameraImageDimensions = processedImage.extent.size
        detectedObjects = objectDetector.detectAndProcess(image: processedImage)
    }
}

// MARK: - Raycast Management
extension ARSceneCoordinator {
    public func handleNewDetectionResults() {
        Task { await processDetectionResults() }
    }
    
    @MainActor
    private func processDetectionResults() {
        if let dominantObservation = getDominantObservation() {
            let detectionPoint = dominantObservation.boundingBox.midPoint
            initiateRaycast(at: detectionPoint)
        }
    }
    
    private func getDominantObservation() -> ProcessedObservation? {
        guard let targetObject = appViewModel?.savedObject.targetDetectionObject else { return nil }
        
        let matchingDetections = detectedObjects.filter { $0.label == targetObject }
        guard !matchingDetections.isEmpty else { return nil }
        
        let adjustedResults = adjustObservations(
            detectionResults: matchingDetections,
            cameraImageDimensions: appViewModel?.cameraImageDimensions ?? .zero
        )
        
        guard let dominantObservation = selectDominantObservation(from: adjustedResults, targetObject: targetObject) else {
            return nil
        }
        
        return dominantObservation
    }
    
    @MainActor
    private func provideDetectionFeedback(for object: String, at position: CGPoint) {
        guard hasTargetObjectBeenDetected?.wrappedValue == false else { return }
        
        self.objectDetectedAtPosition = position
        speechSynthesizer?.speak(text: "\(object) detected!")

        hasTargetObjectBeenDetected?.wrappedValue = true
    }
}

// MARK: - Raycast Implementation
extension ARSceneCoordinator {
    func initiateRaycast(at screenPoint: CGPoint) {
        guard let arView,
              let query = arView.makeRaycastQuery(
                from: screenPoint,
                allowing: .estimatedPlane,
                alignment: .any
              ) else {
            print("Raycast setup failed")
            return
        }
        
        handleRaycastResults(for: query)
    }
    
    private func handleRaycastResults(for query: ARRaycastQuery) {
        guard let arView else { return }
        
        let initialResults = arView.session.raycast(query)
        guard !initialResults.isEmpty else {
            print("No surface detected")
            return
        }
        
        // Get the first raycast result's position
        let newPosition = SIMD3<Float>(
            initialResults[0].worldTransform.columns.3.x,
            initialResults[0].worldTransform.columns.3.y,
            initialResults[0].worldTransform.columns.3.z
        )
        
        // If we have a current tracked anchor, check the distance
        if let currentAnchor = trackedAnchor {
            let currentPosition = currentAnchor.transform.translation
            let distance = simd_distance(newPosition, currentPosition)
            
            // Convert 5cm to meters (0.05m)
            let minimumDistance: Float = 0.05
            
            // Only proceed if the distance is greater than 5cm
            guard distance > minimumDistance else {
                print("New detection too close to current anchor (\(distance)m)")
                return
            }
        }
        
        resetCurrentTracking()
        establishNewTracking(with: query)
    }

}

// MARK: - Visual Feedback
extension ARSceneCoordinator {
    private func establishNewTracking(with query: ARRaycastQuery) {
        guard let arView else { return }
        
        if let dominantObservation = getDominantObservation(), let appViewModel {
            let givenObjectName = appViewModel.savedObject.userGivenObjectName
            let itemName = givenObjectName.isEmpty ? "Your item" : givenObjectName
            let detectionPoint = dominantObservation.boundingBox.midPoint
            Task{
                await provideDetectionFeedback(for: itemName, at: detectionPoint)
            }
        }
        
        let indicatorAnchor = createVisualIndicator()
        arView.scene.addAnchor(indicatorAnchor)
        trackedAnchor = indicatorAnchor
        if let trackedAnchor {
            pingManager.setupBeepAudio(anchor: trackedAnchor)
        }
        
        maintainContinuousTracking(with: query, for: indicatorAnchor)
    }
    
    private func createVisualIndicator() -> AnchorEntity {
        let anchor = AnchorEntity()
        let indicatorModel = arrowEntity()
        anchor.addChild(indicatorModel)
        return anchor
    }
}

// MARK: - Tracking Management
extension ARSceneCoordinator {
    private func maintainContinuousTracking(with query: ARRaycastQuery, for anchor: AnchorEntity) {
        activeRaycast = arView?.session.trackedRaycast(query) { [weak self] results in
            guard let self, let anchor = self.trackedAnchor else { return }
            
            if let firstResult = results.first {
                anchor.transform = Transform(matrix: firstResult.worldTransform)
                anchor.transform.rotation = .init()
            }
        }
    }
    
    private func resetCurrentTracking() {
        activeRaycast?.stopTracking()
        activeRaycast = nil
        
        if let existingAnchor = trackedAnchor {
            arView?.scene.removeAnchor(existingAnchor)
            trackedAnchor = nil
        }
    }
    
    private func releaseResources() {
        sceneUpdateSubscription?.cancel()
        resetCurrentTracking()
    }
}
