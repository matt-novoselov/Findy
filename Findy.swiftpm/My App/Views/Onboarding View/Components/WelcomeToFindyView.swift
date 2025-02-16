import SwiftUI

struct WelcomeToFindyView: View {
    var body: some View {
        VStack(spacing: 10){
            AppIconView(size: 100)
                .padding()
            
            Text("Welcome to Findy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Text("Findy helps users with vision loss to capture, train, and locate their belongings using AI and AR.")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
        }
        .frame(width: 500)
        .padding(.all, 40)
        .glassBackground(cornerRadius: 60)
        .transition(.opacity)
        
    }
}
