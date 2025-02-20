import SwiftUI

// This struct is responsible for displaying the value and unit and the reference text.
struct DynamicFontMeasurementsView: View {
    //
    // The code below is responsible for measuring the width of the text and it's used to calculate the optimal font size.
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Distance to the object: \(numericValue) \(unitSymbol) \(referenceText)")
    }
    
    // This is the display for the value and unit
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
        }
        
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: {
            self.primaryTextWidth = $0.width
        }
    }
    
    // This is the display for the reference text
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
    
    // This function resolves the font for the value
    private func resolvedValueFont(combinedText: String) -> Font {
        fontForTargetWidth(targetWidth: secondaryTextWidth, text: combinedText)
    }
    
    // This function resolves the font for the unit
    private func resolvedUnitFont(combinedText: String) -> Font {
        fontForTargetWidth(targetWidth: secondaryTextWidth, text: combinedText)
    }
    
    // This function calculates the font for the target width
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
    
    // This function calculates the optimal font width
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
    
    // This function calculates the width of the text
    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }
}
