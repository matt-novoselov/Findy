//
//  CornerRadiusHelper.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//


import SwiftUI
import UIKit

func getCornerRadius() -> CGFloat {
    let screenSize = UIScreen.main.bounds.size
    let sortedScreen = [screenSize.width, screenSize.height].sorted()
    
    let dimensionsToRadius: [([CGFloat], CGFloat)] = [
        ([744, 1133].sorted(), 21.5),
        ([820, 1180].sorted(), 18),
        ([1024, 1366].sorted(), 18),
        ([834, 1194].sorted(), 18),
        ([834, 1210].sorted(), 30),
        ([1032, 1376].sorted(), 30),
        ([768, 1024].sorted(), 0),
        ([810, 1080].sorted(), 0),
        ([834, 1112].sorted(), 0)
    ]
    
    return dimensionsToRadius.first(where: { $0.0 == sortedScreen })?.1 ?? 0
}
