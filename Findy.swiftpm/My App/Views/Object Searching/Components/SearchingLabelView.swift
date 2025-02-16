import SwiftUI

struct SearchingLabelView: View {
    @Environment(AppViewModel.self) private var appViewModel
    var body: some View {
        if let objectName = appViewModel.savedObject.targetDetectionObject {
            HStack(spacing: 15){
                if let aiImage = appViewModel.savedObject.appleIntelligencePreviewImage {
                    AsyncImage(url: aiImage) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 20))
                            .frame(maxWidth: 70, maxHeight: 70)
                    } placeholder: {
                        ProgressView()
                    }
                } else if let cutOutImage = appViewModel.savedObject.objectCutOutImage {
                    Image(uiImage: cutOutImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 70, maxHeight: 70)
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Searching:")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                    
                    Text(objectName.prefix(1).uppercased() + objectName.dropFirst())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                }
            }
        }
    }
}

#Preview {
    SearchingLabelView()
}
