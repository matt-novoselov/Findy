import Foundation

class ObjectScanViewModel {
    let cards: [OnboardingCardDescriptionModel] = [
      OnboardingCardDescriptionModel(
        icon: "cube.box.fill",
        description: "**Pick one small object:** Think bottle, mug, fruit, plant, remote, or book."
      ),
      OnboardingCardDescriptionModel(
        icon: "rectangle.on.rectangle.slash.fill",
        description: "**Clear the background:** Use a plain, simple space."
      ),
      OnboardingCardDescriptionModel(
        icon: "viewfinder",
        description: "**Frame it:** Ensure your object fits in the viewfinder."
      ),
      OnboardingCardDescriptionModel(
        icon: "arrow.trianglehead.2.clockwise.rotate.90",
        description: "**Show different angles:** Snap multiple shots for a better AI training."
      ),
    ]
    
    let card: OnboardingCardModel
    
    init(action: @escaping () -> Void){
        self.card = .init(infoCards: cards, buttonAction: action, buttonTitle: "Let’s capture first item", mainTitle: "Object Scanning", mainDescription: "Scan your object to train an AI model.")
    }
}
