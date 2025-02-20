import Foundation

struct AverageLabelService {
    // Computes the most frequent label from a list of labels.
    static func computeAverageLabel(from labels: [String]) -> String? {
        // Return nil if the input array is empty.
        guard !labels.isEmpty else { return nil }
        
        // Create a dictionary to store the frequency of each label.
        let frequencyDict = labels.reduce(into: [String: Int]()) { counts, label in
            counts[label, default: 0] += 1
        }
        
        // Find the maximum count of any label.
        guard let maxCount = frequencyDict.values.max() else { return nil }
        
        // Filter the dictionary to find labels with the maximum count.
        let mostFrequent = frequencyDict.filter { $0.value == maxCount }.map { $0.key }
        
        // Return the first most frequent label.
        return mostFrequent.first
    }
}
