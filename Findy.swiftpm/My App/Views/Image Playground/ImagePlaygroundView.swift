import SwiftUI
import ImagePlayground

struct ImagePlaygroundView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @State private var showImagePlayground = false
    
    @State private var concepts: [ImagePlaygroundConcept] = []
    @State private var sourceImage: Image?
    
    
    var body: some View {
        VStack {
            if let url = appViewModel.savedObject.appleIntelligencePreviewImage {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 20))
                        .frame(maxWidth: 300, maxHeight: 300)
                } placeholder: {
                    ProgressView()
                }
            }
            
            
            if supportsImagePlayground {
                Button(action: {openImagePlaygrounds()}) {
                    ImagePlaygroundButtonLabel()
                }
                .tint(.white)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .buttonStyle(.borderedProminent)
                .clipShape(.capsule)
                .imagePlaygroundSheet(isPresented: $showImagePlayground, concepts: concepts, sourceImage: sourceImage) { url in
                    appViewModel.savedObject.appleIntelligencePreviewImage = url
                }
            } else {
                ContentUnavailableView(
                    "Image Playground Isn't Available Yet",
                    systemImage: "xmark.circle",
                    description: Text("Update to iOS 18.2 to use this feature!")
                )
                .fontDesign(.rounded)
            }
        }
    }
    
    func openImagePlaygrounds(){
        self.concepts = []
        let visionClassifications = appViewModel.savedObject.userPickedClassifications
        for classification in visionClassifications {
            self.concepts.append(.text(classification.description))
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
        HStack{
            Group{
                Image(systemName: "apple.intelligence")
                    .foregroundStyle(.white)
                    .overlay(
                        ImagePlaygroundLabelGradient()
                            .blur(radius: 5)
                            .rotationEffect(.init(degrees: 180))
                            .mask(Image(systemName: "apple.intelligence"))
                    )
                
                Text("Generate Preview Image")
            }
            .font(.body)
        }
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
    Button(action: {}) {
        ImagePlaygroundButtonLabel()
    }
    .tint(.white)
    .fontDesign(.rounded)
    .fontWeight(.semibold)
    .foregroundStyle(.black)
    .buttonStyle(.borderedProminent)
    .clipShape(.capsule)
}
