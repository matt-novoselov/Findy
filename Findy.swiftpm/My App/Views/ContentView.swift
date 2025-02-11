import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Viewfinder", systemImage: "camera.viewfinder") {
                ARControllerView()
            }

            Tab("Settings", systemImage: "gearshape.2.fill") {
                SettingsView()
            }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
