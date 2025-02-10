import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            Tab("Object Detection", systemImage: "xmark") {
                ARControllerView()
            }
            Tab("Settings", systemImage: "xmark") {
                SettingsView()
            }
            Tab("Image Playground", systemImage: "xmark") {
                ImagePlaygroundView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        
    }
}

#Preview {
    ContentView()
}
