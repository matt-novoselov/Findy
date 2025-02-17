import SwiftUI
import RealityKit

// Function to load game table
func arrowEntity() -> Entity {
    let modelName = "arrow"
    let modelEntity = try! Entity.loadModel(named: modelName)
    modelEntity.transform.scale /= 50
    modelEntity.position.y = 0.1
    return modelEntity
}
