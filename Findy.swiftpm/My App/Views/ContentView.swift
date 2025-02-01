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
            Tab("Watch Now", systemImage: "play") {
                Text("Watch Now")
            }
            Tab("Library", systemImage: "books.vertical") {
                Text("Library")
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
