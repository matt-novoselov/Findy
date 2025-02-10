import SwiftUI
import RealityKit

// Function to load game table
func debugSphere(color: Color) -> Entity {
    let entity = Entity()
    let simpleMaterial = SimpleMaterial(
        color: UIColor(color), isMetallic: true
    )
    let model = ModelComponent(
        mesh: .generateSphere(radius: 0.02),
        materials: [simpleMaterial]
    )
    entity.components.set(model)
    return entity
}
