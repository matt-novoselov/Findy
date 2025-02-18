import SwiftUI
import ImagePlayground

struct ImagePlaygroundView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var showImagePlayground = false
    
    @State private var concepts: [ImagePlaygroundConcept] = []
    @State private var sourceImage: Image?
    
    var body: some View {
        VStack (alignment: .leading){
            HStack{
                Group{
                    Image(systemName: "photo")
                    Text("AI Preview Image")
                }
                .font(.body)
                .foregroundStyle(Color.primary)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            }
            
            Button(action: {openImagePlaygrounds()}) {
                ImagePlaygroundButtonLabel()
            }
            .clipShape(.capsule)
            .imagePlaygroundSheet(isPresented: $showImagePlayground, concepts: concepts, sourceImage: sourceImage) { url in
                appViewModel.savedObject.appleIntelligencePreviewImage = url
            }
        }
    }
    
    func openImagePlaygrounds(){
        self.concepts = []
        let visionClassifications = appViewModel.savedObject.userPickedClassifications
        for classification in visionClassifications {
            self.concepts.append(.text(classification.description))
        }
        
        if !appViewModel.savedObject.userGivenObjectName.isEmpty {
            self.concepts.append(.text(appViewModel.savedObject.userGivenObjectName))
        }
        
        if let cutOutImage = appViewModel.savedObject.objectCutOutImage {
            let imageWithWhiteBG = cutOutImage.imageWithWhiteBackgroundSquare()
            self.sourceImage = Image(uiImage: imageWithWhiteBG)
        }
        
        showImagePlayground = true
    }
}

struct ImagePlaygroundButtonLabel: View {
    var body: some View {
        HStack(spacing: 8){
            Group{
                Image(systemName: "apple.intelligence")
                    .foregroundStyle(.white)
                    .overlay(
                        ImagePlaygroundLabelGradient()
                            .blur(radius: 5)
                            .rotationEffect(.init(degrees: 180))
                            .mask(Image(systemName: "apple.intelligence"))
                    )
                
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
