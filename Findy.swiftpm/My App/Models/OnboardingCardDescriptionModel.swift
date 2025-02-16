import Foundation

struct OnboardingCardDescriptionModel: Identifiable {
    let id = UUID()
    let icon: String
    let description: String
}

struct OnboardingCardModel {
    let infoCards: [OnboardingCardDescriptionModel]
    let buttonAction: () -> Void
    let buttonTitle: String
    let mainTitle: String
    let mainDescription: String
}
