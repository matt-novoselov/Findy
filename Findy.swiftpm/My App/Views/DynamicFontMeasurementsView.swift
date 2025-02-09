//
//  SwiftUIView.swift
//  Findy
//
//  Created by Matt Novoselov on 09/02/25.
//

import SwiftUI

struct DynamicFontMeasurementsView: View {
    @State private var text2Width: CGFloat = 0
    @State private var text1Width: CGFloat = 0
    
    var numberValue: Double
    var measurementString: String

    var body: some View {
        HStack(spacing: 0){
            let formattedText = String(format: "%.2f", numberValue)
            let fullText = "\(formattedText) \(measurementString)"
            Text(formattedText)
                .font(text2Width > 0 ? Font(customFont(targetWidth: text2Width, text: fullText)) : .largeTitle)
                .contentTransition(.numericText(value: numberValue))
                .animation(.spring, value: numberValue)
            
            Text(" \(measurementString)")
                .font(text2Width > 0 ? Font(customFont(targetWidth: text2Width, text: fullText)) : .largeTitle)
                .foregroundStyle(.secondary)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
             proxy.size
         } action: {
             self.text1Width = $0.width
         }

        Text("to your right")
            .font(.title)
            .fontWeight(.bold)
            .onGeometryChange(for: CGSize.self) { proxy in
                 proxy.size
             } action: {
                 self.text2Width = $0.width
             }
    }

    // Compute a UIFont with a width parameter that makes "4.2 m" roughly match the target width.
    func customFont(targetWidth: CGFloat, text: String) -> UIFont {
        let fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        let weight = UIFont.Weight.black
        let adjustedWidth = findWidthParameter(for: text, targetWidth: targetWidth, fontSize: fontSize, weight: weight)
        print(adjustedWidth)
        return UIFont.systemFont(ofSize: fontSize, weight: weight, width: adjustedWidth)
    }

    // Measures the width of a given text with the provided font.
    func measureTextWidth(_ text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }
    
    // Use binary search to find a UIFont.Width value that brings the measured width close to targetWidth.
    func findWidthParameter(for text: String, targetWidth: CGFloat, fontSize: CGFloat, weight: UIFont.Weight) -> UIFont.Width {
        var lower: CGFloat = -1.0
        var upper: CGFloat = 1.0
        var mid: CGFloat = 0.0
        let tolerance: CGFloat = 0.2  // Adjust tolerance as needed
        
        for _ in 0..<20 {
            mid = (lower + upper) / 2
            let font = UIFont.systemFont(ofSize: fontSize, weight: weight, width: UIFont.Width(mid))
            let measured = measureTextWidth(text, font: font)
            if abs(measured - targetWidth) < tolerance { break }
            if measured < targetWidth { lower = mid } else { upper = mid }
        }
        return UIFont.Width(mid)
    }
}
