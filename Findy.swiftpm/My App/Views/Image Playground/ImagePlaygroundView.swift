import SwiftUI
import ImagePlayground

struct ImagePlaygroundView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var showImagePlayground = false
    
    @State private var concepts: [ImagePlaygroundConcept] = []
    @State private var sourceImage: Image?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    Image(systemName: "photo")
                        .accessibilityHidden(true)
                    Text("AI Preview Image")
                }
                .font(.body)
                .foregroundStyle(Color.primary)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            }
            
            Button(action: { openImagePlaygrounds() }) {
                ImagePlaygroundButtonLabel()
            }
            .clipShape(.capsule)
            
            // Present the Image Playground sheet.
            .imagePlaygroundSheet(isPresented: $showImagePlayground, concepts: concepts, sourceImage: sourceImage) { url in
                appViewModel.savedObject.appleIntelligencePreviewImage = url
            }
        }
    }
    
    // Opens the Image Playground sheet.
    func openImagePlaygrounds() {
        self.concepts = []
        // Add the user-picked classifications as text concepts.
        let visionClassifications = appViewModel.savedObject.userPickedClassifications
        for classification in visionClassifications {
            self.concepts.append(.text(classification.description))
        }
        
        // Add the user-given object name as a text concept.
        if !appViewModel.savedObject.userGivenObjectName.isEmpty {
            self.concepts.append(.text(appViewModel.savedObject.userGivenObjectName))
        }
        
        // Prepare the source image for the Image Playground.
        if let cutOutImage = appViewModel.savedObject.objectCutOutImage {
            let imageWithWhiteBG = cutOutImage.imageWithWhiteBackgroundSquare()
            self.sourceImage = Image(uiImage: imageWithWhiteBG)
        }
        
        // Show the Image Playground sheet.
        showImagePlayground = true
    }
}

struct ImagePlaygroundButtonLabel: View {
    var body: some View {
        HStack(spacing: 8) {
            Group {
                Image(systemName: "apple.intelligence")
                    .foregroundStyle(.white)
                    .overlay(
                        ImagePlaygroundLabelGradient()
                            .blur(radius: 5)
                            .rotationEffect(.init(degrees: 180))
                            .mask(Image(systemName: "apple.intelligence"))
                    )
                    .accessibilityHidden(true)
                
                Text("Open Image Playground")
            }
            .font(.body)
            .fontDesign(.rounded)
            .fontWeight(.medium)
            .foregroundStyle(Color.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .clipShape(.capsule)
        .background(RecessedRectangleView())
        .accessibilityLabel("Open Image Playground Button")
        .accessibilityHint("Tap to open the image playground.")
    }
}


struct ImagePlaygroundLabelGradient: View {
    var body: some View {
        VStack(spacing: -10){
            HStack(spacing: -10){
                Group{
                    Circle()
                        .foregroundStyle(Color(hex: 0x03AAF6))
                    Circle()
                        .foregroundStyle(Color(hex: 0xED75FA))
                }
                .frame(width: 20, height: 20)
            }
            
            HStack(spacing: -10){
                Group{
                    Circle()
                        .foregroundStyle(Color(hex: 0xF62B6A))
                    Circle()
                        .foregroundStyle(Color(hex: 0xF79B1C))
                    
                    Circle()
                        .foregroundStyle(Color(hex: 0xDB7FFB))
                }
                .frame(width: 20, height: 20)
            }
        }
    }
}

#Preview {
    ZStack{
        Color.green
        
        Button(action: {}) {
            ImagePlaygroundButtonLabel()
        }
        .clipShape(.capsule)
    }
}
