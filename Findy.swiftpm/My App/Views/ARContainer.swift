import ARKit
import RealityKit
import SwiftUI
import Combine

#warning("")

/// Filters and selects the most prominent ProcessedObservation based on target object and bounding box area
/// - Parameters:
///   - observations: Array of ProcessedObservation to filter
///   - targetObject: The target object name to filter by
/// - Returns: The ProcessedObservation with the largest bounding box area for the target object
func selectMostProminentObservation(from observations: [ProcessedObservation], targetObject: String? = nil) -> ProcessedObservation? {
    
    let filteredObservations: [ProcessedObservation]
    
    if (targetObject != nil){
        // Filter observations by target object
        filteredObservations = observations.filter { $0.label == targetObject }
        
        guard !filteredObservations.isEmpty else {
            return nil
        }
    } else {
        filteredObservations = observations
    }

    // If only one observation, return it immediately
    guard filteredObservations.count > 1 else {
        return filteredObservations.first
    }
    
    var maxArea: CGFloat = 0
    var mostProminentObservation: ProcessedObservation?
    
    // Find observation with largest bounding box area
    for observation in filteredObservations {
        let area = observation.boundingBox.width * observation.boundingBox.height
        if area > maxArea {
            maxArea = area
            mostProminentObservation = observation
        }
    }
    
    return mostProminentObservation
}

func checkLightingLevel(frame: ARFrame) {
    let lowThreshold: CGFloat = 500
    // Check if light estimate is available
    guard let lightEstimate = frame.lightEstimate else {
        print("Light estimation not available")
        return
    }
    
    // Get ambient intensity in lumens
    let ambientIntensity = lightEstimate.ambientIntensity
    
    // Check against threshold and print warning
    if ambientIntensity < lowThreshold {
        print("⚠️ Lighting is too low: \(String(format: "%.0f", ambientIntensity)) lumens")
    }
}

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
    private var metalDetector: MetalDetector = .init()
    
    // Measurement state
    private(set) var currentMeasurement: SceneMeasurement?
    
    // Object Detection
    private(set) var detectionResults: [ProcessedObservation] = [] {
        didSet {
            Task{
                await shootRaycastAtDetectedResult()
            }
        }
    }
    private let objectDetection: ObjectDetection
    
    // AR tracking properties
    private var sceneUpdateSubscription: Cancellable?
    private var trackedAnchor: AnchorEntity?
    private var activeRaycast: ARTrackedRaycast?
    public var normalizedCaptureImage: CIImage?
    
    weak var appViewModel: AppViewModel?
    weak var speechSynthesizer: SpeechSynthesizer?
    
    init(objectDetection: ObjectDetection) {
        self.objectDetection = objectDetection
        self.metalDetector.arCoordinator = self
    }
    
    deinit {
        cleanUpResources()
    }
    
    @MainActor
    func shootRaycastAtDetectedResult() {
        guard let appViewModel = objectDetection.appViewModel else { return }
        
        let targetObject = appViewModel.targetDetectionObject
        let matchingResults = self.detectionResults.filter { $0.label == targetObject }

        guard !matchingResults.isEmpty else { return }

        // Process and select the most prominent observation
        let adjustedResults = adjustObservations(
            detectionResults: matchingResults,
            cameraImageDimensions: appViewModel.cameraImageDimensions
        )

        guard let selectedObservation = selectMostProminentObservation(from: adjustedResults, targetObject: targetObject) else {
            return
        }

        // Perform raycast and handle detection announcement
        let raycastPoint = CGPoint(x: selectedObservation.boundingBox.midX, y: selectedObservation.boundingBox.minY)
        self.handleRaycast(at: raycastPoint)

        if !appViewModel.hasObjectBeenDetected {
            speechSynthesizer?.speak(text: "\(targetObject) detected!")
            
            if let distance = self.currentMeasurement?.formattedValue {
                speechSynthesizer?.speak(text: "\(targetObject) is \(distance) away.")
            }
            
            appViewModel.hasObjectBeenDetected = true
        }

    }
    
    // MARK: - Configuration
    func setup(arView: ARView) {
        self.arView = arView
        
        // Configure AR session with light estimation
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true // Enable light estimation
        arView.session.run(configuration)
        
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
        
        if let currentFrame = arView?.session.currentFrame {
            checkLightingLevel(frame: currentFrame)
        }
    }
    
    // MARK: - Measurement Handling
    private func updateMeasurements() {
        guard let arView,
              let currentFrame = arView.session.currentFrame,
              let anchor = trackedAnchor else {
            currentMeasurement = nil
            return
        }
        
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = cameraTransform.position
        let anchorPosition = anchor.transform.translation
        let distance = simd_distance(cameraPosition, anchorPosition)
        
        // Calculate the camera's forward vector (note: -Z is forward in ARKit)
        let cameraForward = -simd_make_float3(cameraTransform.columns.2)
        // Project to horizontal plane
        let cameraForwardProjected = simd_normalize(simd_float3(cameraForward.x, 0, cameraForward.z))
        
        // Calculate direction vector from camera to anchor and project it
        let direction = anchorPosition - cameraPosition
        let directionProjected = simd_normalize(simd_float3(direction.x, 0, direction.z))
        
        // Compute the yaw difference using atan2
        let cameraYaw = atan2(cameraForwardProjected.x, cameraForwardProjected.z)
        let targetYaw = atan2(directionProjected.x, directionProjected.z)
        let angleRadians = targetYaw - cameraYaw
        let angleDegrees = angleRadians * 180 / .pi
        
        currentMeasurement = SceneMeasurement(
            meterDistance: distance,
            rotationDegrees: angleDegrees
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
//            print("[ObjectDetection] Error: Failed to get interface orientation")
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
    
    private func addFloatingAnimation(to entity: Entity, offset: Float = 0.05, duration: TimeInterval = 3.0) {
        let originalTransform = entity.transform
        var upTransform = originalTransform
        upTransform.translation.y += offset

        // Move entity upward
        _ = entity.move(to: upTransform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
        
        // After the upward animation, move back down
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self, weak entity] in
            guard let self = self, let entity = entity else { return }
            _ = entity.move(to: originalTransform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
            
            // Loop the animation after moving back down
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.addFloatingAnimation(to: entity, offset: offset, duration: duration)
            }
        }
    }

    // In your setupNewTracking function, right after adding the arrowEntity:
    private func setupNewTracking(with query: ARRaycastQuery) {
        guard let arView else { return }
        
        // Create visual indicator
        let arrow = arrowEntity()
        let newAnchor = AnchorEntity()
        newAnchor.addChild(arrow)
        arView.scene.addAnchor(newAnchor)
        trackedAnchor = newAnchor
        
        // Start floating animation on the arrow
        addFloatingAnimation(to: arrow)
        
        // Start continuous tracking
        activeRaycast = arView.session.trackedRaycast(query) { [weak self, weak newAnchor] results in
            guard let self, let newAnchor else { return }
            
            if let result = results.first {
                newAnchor.transform = Transform(matrix: result.worldTransform)
                newAnchor.transform.rotation = .init()
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
