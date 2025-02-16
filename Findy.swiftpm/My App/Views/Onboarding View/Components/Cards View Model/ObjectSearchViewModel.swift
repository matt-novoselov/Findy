//
//  ObjectSearchViewModel.swift
//  Findy
//
//  Created by Matt Novoselov on 16/02/25.
//


import Foundation

class ObjectSearchViewModel {
    let cards: [OnboardingCardDescriptionModel] = [
        OnboardingCardDescriptionModel(
            icon: "hand.raised.fill",
            description: "**Steady Hands:** Hold your camera steady and pan slowly. "),
        OnboardingCardDescriptionModel(
            icon: "eye.fill",
            description: "**Wide View:** AI can spot objects from up to 4 meters away. "),
        OnboardingCardDescriptionModel(
            icon: "sun.max.fill",
            description: "**Bright Space:** Keep the area well-lit for the best detection.")
    ]
    
    let card: OnboardingCardModel
    
    init(action: @escaping () -> Void){
        self.card = .init(infoCards: cards, buttonAction: action, buttonTitle: "Find captured item", mainTitle: "Object Searching", mainDescription: "Search for the scanned object in your surroundings.")
    }
}
