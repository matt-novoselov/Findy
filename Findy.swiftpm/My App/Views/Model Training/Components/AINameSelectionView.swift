import SwiftUI

struct AINameSelectionView: View {
    
    @Environment(AppViewModel.self) private var appViewModel
    @State private var selectedCuisines: Set<String> = []
    
    // Define a computed property that builds the desired HStack.
    var capsuleView: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(appViewModel.savedObject.visionClassification ?? [], id: \.self) { cuisine in
                CapsuleButton(
                    title: cuisine.processedCuisine,
                    isSelected: selectedCuisines.contains(cuisine)
                ) {
                    if selectedCuisines.contains(cuisine) {
                        selectedCuisines.remove(cuisine)
                    } else {
                        selectedCuisines.insert(cuisine)
                    }
                }
            }
        }
        .padding()
        .animation(.spring, value: selectedCuisines.count)
    }
    
    var body: some View {
        ViewThatFits {
            // Try to show capsuleView directly...
            capsuleView
            
            // ...or in a horizontal ScrollView if it doesn't fit.
            ScrollView(.horizontal) {
                capsuleView
            }
            .scrollIndicators(.hidden)
        }
    }
}

// Extension to process cuisine strings.
extension String {
    var processedCuisine: String {
        // Replace underscores with spaces.
        let withSpaces = self.replacingOccurrences(of: "_", with: " ")
        // Capitalize each word.
        return withSpaces.capitalized
    }
}

// Custom capsule button component
struct CapsuleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack{
                Text(title)
                    .fontDesign(.rounded)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .orange : .primary)
                    .lineLimit(1)
                    .transition(.move(edge: .leading))
                    .animation(.none, value: isSelected)
                
                if isSelected{
                    Image(systemName: "checkmark.circle.fill")
                        .fontDesign(.rounded)
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .transition(.scale(scale: 0, anchor: .leading))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .strokeBorder(.tertiary, style: .init(lineWidth: 1))
                    .fill(isSelected ? .orange.opacity(0.2) : .clear)
            )
            .background(Material.regular, in: .capsule)
            .animation(.bouncy, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
