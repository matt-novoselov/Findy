import SwiftUI
import RealityKit

// Function to load game table
func arrowEntity() -> Entity {
    let modelName = "arrow"
    let modelEntity = try! Entity.loadModel(named: modelName)
    modelEntity.transform.scale /= 50
    return modelEntity
}
