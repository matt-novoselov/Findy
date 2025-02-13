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
                Button("Show Generation Sheet") {
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
                .imagePlaygroundSheet(isPresented: $showImagePlayground, concepts: concepts, sourceImage: sourceImage) { url in
                    appViewModel.savedObject.appleIntelligencePreviewImage = url
                }
            } else {
                ContentUnavailableView(
                    "Image Playground Isn't Available Yet",
                    systemImage: "xmark.circle",
                    description: Text("Update to iOS 18.2 to use this feature!")
                )
            }
        }
    }
}
