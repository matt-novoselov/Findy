import ARKit
import RealityKit
import SwiftUI
import Combine


// MARK: - AR Scene Coordinator
@Observable
class ARSceneCoordinator {
    private weak var arView: ARView?
    private let objectDetector: ObjectDetection
    private let metalDetector: MetalDetector = .init()
    
    // Scene state properties
    private var sceneUpdateSubscription: Cancellable?
    private var activeRaycast: ARTrackedRaycast?
    private var trackedAnchor: AnchorEntity?
    private(set) var currentMeasurement: SceneMeasurement?
    
    // Detection properties
    private(set) var detectedObjects: [ProcessedObservation] = []
    public var processedFrameImage: CIImage?
    
    weak var appViewModel: AppViewModel?
    weak var speechSynthesizer: SpeechSynthesizer?
    weak var toastManager: ToastManager?
    
    var hasTargetObjectBeenDetected: Binding<Bool>?
    var objectDetectedAtPosition: CGPoint?
    
    var isARContainerVisible: Bool = false
    
    init(objectDetection: ObjectDetection) {
        self.objectDetector = objectDetection
        self.metalDetector.arCoordinator = self
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
    
    private func calculateAngles(cameraTransform: float4x4, targetPosition: SIMD3<Float>) -> Float {
        let cameraForward = -simd_make_float3(cameraTransform.columns.2)
        let horizontalForward = simd_normalize(simd_float3(cameraForward.x, 0, cameraForward.z))
        
        let directionVector = targetPosition - cameraTransform.position
        let horizontalDirection = simd_normalize(simd_float3(directionVector.x, 0, directionVector.z))
        
        let cameraYaw = atan2(horizontalForward.x, horizontalForward.z)
        let targetYaw = atan2(horizontalDirection.x, horizontalDirection.z)
        let radiansDifference = targetYaw - cameraYaw
        
        return radiansDifference * 180 / .pi
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
        analyzeImageWithML()
        
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
        
        if let distance = currentMeasurement?.formattedValue {
            speechSynthesizer?.speak(text: "\(object) is \(distance) away.")
        }
        
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
        
        resetCurrentTracking()
        establishNewTracking(with: query)
    }
}

// MARK: - Visual Feedback
extension ARSceneCoordinator {
    private func establishNewTracking(with query: ARRaycastQuery) {
        guard let arView else { return }
        
        if let dominantObservation = getDominantObservation(), let targetObject = appViewModel?.savedObject.targetDetectionObject {
            let detectionPoint = dominantObservation.boundingBox.midPoint
            Task{
                await provideDetectionFeedback(for: targetObject, at: detectionPoint)
            }
        }
        
        let indicatorAnchor = createVisualIndicator()
        arView.scene.addAnchor(indicatorAnchor)
        trackedAnchor = indicatorAnchor
        
        animateVisualIndicator(indicatorAnchor)
        maintainContinuousTracking(with: query, for: indicatorAnchor)
    }
    
    private func createVisualIndicator() -> AnchorEntity {
        let anchor = AnchorEntity()
        let indicatorModel = arrowEntity()
        anchor.addChild(indicatorModel)
        return anchor
    }
    
    private func animateVisualIndicator(_ entity: Entity) {
        let floatHeight: Float = 0.05
        let animationDuration: TimeInterval = 3.0
        
        let basePosition = entity.transform
        var elevatedPosition = basePosition
        elevatedPosition.translation.y += floatHeight
        
        entity.move(to: elevatedPosition, relativeTo: entity.parent,
                    duration: animationDuration, timingFunction: .easeInOut)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.queueReturnAnimation(for: entity,
                                       originalPosition: basePosition,
                                       duration: animationDuration)
        }
    }
    
    private func queueReturnAnimation(for entity: Entity,
                                      originalPosition: Transform,
                                      duration: TimeInterval) {
        entity.move(to: originalPosition, relativeTo: entity.parent,
                    duration: duration, timingFunction: .easeInOut)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.animateVisualIndicator(entity)
        }
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
            } else {
                self.resetCurrentTracking()
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
