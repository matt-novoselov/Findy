//
//  AppViewModel.swift
//  Findy
//
//  Created by Matt Novoselov on 26/01/25.
//

import SwiftUI

@Observable
class AppViewModel {
    var isDebugMode: Bool = true
    var cameraImageDimensions: CGSize = .init()
    var targetDetectionObject: String = "bottle"
}
