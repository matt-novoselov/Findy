//
//  DebugDistanceView.swift
//  Findy
//
//  Created by Matt Novoselov on 26/01/25.
//

import SwiftUI

struct DebugDistanceView: View {
    
    @Environment(ARCoordinator.self) private var arCoordinator
    
    var body: some View {
        let currentMeasurement = arCoordinator.currentMeasurement
        Text(currentMeasurement?.formatDistance() ?? "N/A")
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
    }
}
