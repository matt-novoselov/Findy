//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 01/02/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            Tab("Object Detection", systemImage: "xmark") {
                ObjectFinderView()
            }
            Tab("Settings", systemImage: "xmark") {
                SettingsView()
            }
            Tab(role: .search) {
                Text("Search")
            }
        }
        .tabViewStyle(.tabBarOnly)
        
    }
}

#Preview {
    ContentView()
}
