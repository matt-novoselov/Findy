import SwiftUI

struct ObjectTagsPickerView: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    @State private var newTag: String = ""
    
    // Define a computed property that builds the desired HStack.
    var capsuleView: some View {
        return HStack(alignment: .center, spacing: 5) {
            ForEach(appViewModel.savedObject.visionClassifications, id: \.self) { classifiedTag in
                CapsuleButton(
                    title: classifiedTag,
                    isSelected: appViewModel.savedObject.userPickedClassifications.contains(classifiedTag)
                ) {
                    if appViewModel.savedObject.userPickedClassifications.contains(classifiedTag) {
                        appViewModel.savedObject.userPickedClassifications.remove(classifiedTag)
                    } else {
                        appViewModel.savedObject.userPickedClassifications.insert(classifiedTag)
                    }
                }
                .transition(.blurReplace)
            }
            .animation(.spring, value: appViewModel.savedObject.visionClassifications.count)
        }
        .animation(.spring, value: appViewModel.savedObject.userPickedClassifications.count)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    Image(systemName: "sparkles")
                        .accessibility(hidden: true)
                    Text("AI generated tags: select all that are relevant")
                        .accessibilityLabel("AI generated tags")
                        .accessibilityHint("Select all relevant tags.")
                }
                .font(.body)
                .foregroundStyle(Color.primary)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
            }
            
            HStack(spacing: 4) {
                AISphereView()
                    .frame(width: 36, height: 36)
                    .padding(.trailing, 4)
                
                ScrollView(.horizontal) {
                    capsuleView
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

// Custom capsule button component
struct CapsuleButton: View {
    let title: String
    var isSelected: Bool = false
    let buttonAccentColor: Color = .purple.mix(with: .white, by: 0.5)
    var customSFSymbolName: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 4) {
                    if let customSFSymbolName {
                        Image(systemName: customSFSymbolName)
                            .fontDesign(.rounded)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .accessibilityHidden(true)
                    }
                    
                    Text(title)
                        .fontDesign(.rounded)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? buttonAccentColor : .primary)
                        .lineLimit(1)
                        .transition(.move(edge: .leading))
                        .animation(.none, value: isSelected)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .fontDesign(.rounded)
                        .font(.subheadline)
                        .foregroundStyle(buttonAccentColor)
                        .transition(.scale(scale: 0, anchor: .leading))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(RecessedRectangleView(cornerRadius: .infinity))
            .animation(.bouncy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tag: \(title)") 
        .accessibilityHint(isSelected ? "Deselect this tag." : "Select this tag.")
    }
}

// Extension to process ML classified strings.
extension String {
    var processedMLTag: String {
        // Replace underscores with spaces.
        let withSpaces = self.replacingOccurrences(of: "_", with: " ")
        // Capitalize each word.
        return withSpaces.capitalized
    }
}

#Preview {
    @Previewable @State var appViewModel: AppViewModel = .init()
    ObjectTagsPickerView()
        .environment(appViewModel)
        .onAppear {
            appViewModel.savedObject.visionClassifications = ["Cat", "Dog", "Bird"]
        }
}
