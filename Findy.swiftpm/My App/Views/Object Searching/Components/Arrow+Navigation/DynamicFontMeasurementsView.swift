import SwiftUI

struct DynamicFontMeasurementsView: View {
    @State private var secondaryTextWidth: CGFloat = 0
    @State private var primaryTextWidth: CGFloat = 0
    
    let numericValue: Double
    let unitSymbol: String
    let referenceText: String
    
    var body: some View {
        VStack {
            valueAndUnitDisplay
            referenceTextDisplay
        }
    }
    
    private var valueAndUnitDisplay: some View {
        HStack(spacing: 0) {
            let formattedValue = String(format: "%.2f", numericValue)
            let combinedText = "\(formattedValue) \(unitSymbol)"
            
            Group{
                Text(formattedValue)
                    .font(resolvedValueFont(combinedText: combinedText))
                    .contentTransition(.numericText(value: numericValue))
                    .animation(.spring, value: numericValue)
                
                Text(" \(unitSymbol)")
                    .font(resolvedUnitFont(combinedText: combinedText))
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Distance to the object")
            .accessibilityValue("\(formattedValue) \(unitSymbol)")
        }
        
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: {
            self.primaryTextWidth = $0.width
        }
    }
    
    private var referenceTextDisplay: some View {
        Text(referenceText.lowercased())
            .font(.title)
            .fontWeight(.bold)
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: {
                self.secondaryTextWidth = $0.width
            }
    }
    
    private func resolvedValueFont(combinedText: String) -> Font {
        fontForTargetWidth(targetWidth: secondaryTextWidth, text: combinedText)
    }
    
    private func resolvedUnitFont(combinedText: String) -> Font {
        fontForTargetWidth(targetWidth: secondaryTextWidth, text: combinedText)
    }
    
    private func fontForTargetWidth(targetWidth: CGFloat, text: String) -> Font {
        let baseFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        let optimalWidth = calculateOptimalFontWidth(
            for: text,
            targetWidth: targetWidth,
            baseSize: baseFont.pointSize,
            weight: .black
        )
        return Font(UIFont.systemFont(
            ofSize: baseFont.pointSize,
            weight: .black,
            width: optimalWidth
        ))
    }
    
    private func calculateOptimalFontWidth(
        for text: String,
        targetWidth: CGFloat,
        baseSize: CGFloat,
        weight: UIFont.Weight
    ) -> UIFont.Width {
        var lowerBound: CGFloat = -1.0
        var upperBound: CGFloat = 1.0
        var currentWidth: CGFloat = 0.0
        let precisionThreshold: CGFloat = 0.2
        
        for _ in 0..<20 {
            currentWidth = (lowerBound + upperBound) / 2
            let testFont = UIFont.systemFont(
                ofSize: baseSize,
                weight: weight,
                width: UIFont.Width(currentWidth)
            )
            let measuredWidth = textWidth(for: text, font: testFont)
            
            if abs(measuredWidth - targetWidth) < precisionThreshold { break }
            
            if measuredWidth < targetWidth {
                lowerBound = currentWidth
            } else {
                upperBound = currentWidth
            }
        }
        return UIFont.Width(currentWidth)
    }
    
    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }
}
