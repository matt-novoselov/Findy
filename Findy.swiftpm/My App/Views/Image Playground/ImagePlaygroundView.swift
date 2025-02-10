import SwiftUI
import ImagePlayground

struct ImagePlaygroundView: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @State private var showImagePlayground = false
    @State private var createdImageURL: URL?
    
    var body: some View {
        VStack {
            if let url = createdImageURL {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 300, maxHeight: 300)
                } placeholder: {
                    ProgressView()
                }
            }
            
            if supportsImagePlayground {
                Button("Show Generation Sheet") {
                    showImagePlayground = true
                }
                .imagePlaygroundSheet(isPresented: $showImagePlayground, concepts: [.text("Lemon")]) { url in
                    createdImageURL = url
                }
            } else {
                ContentUnavailableView(
                    "Image Playground is Unavailable",
                    systemImage: "xmark",
                    description: Text("This feature requires iOS 18.2")
                )
            }
        }
    }
}
