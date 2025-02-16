import Foundation

class ObjectScanViewModel {
    let cards: [OnboardingCardDescriptionModel] = [
        OnboardingCardDescriptionModel(
            icon: "cube.box.fill",
            description: "**Pick one small object:** Think bottle, mug, fruit, plant, TV remote or book."),
        OnboardingCardDescriptionModel(
            icon: "rectangle.on.rectangle.slash.fill",
            description: "**Clear the background:** Use a plain, uncluttered space to keep distractions away."),
        OnboardingCardDescriptionModel(
            icon: "viewfinder",
            description: "**Frame It Right:** Make sure your object fits in the viewfinder before capturing a photo."),
        OnboardingCardDescriptionModel(
            icon: "arrow.trianglehead.2.clockwise.rotate.90",
            description: "**Show different angles:** Snap multiple shots to give AI a complete view."),
//        OnboardingCardDescriptionModel(
//            icon: "sun.max.fill",
//            description: "**Light it up:** Make sure the area is well lit.")
    ]
    
    let card: OnboardingCardModel
    
    init(action: @escaping () -> Void){
        self.card = .init(infoCards: cards, buttonAction: action, buttonTitle: "Let's find your item", mainTitle: "Object Scanning", mainDescription: "Scan your object to train an AI model.")
    }
}
