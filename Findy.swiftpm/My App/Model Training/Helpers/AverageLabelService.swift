import Foundation

struct AverageLabelService {
    static func computeAverageLabel(from labels: [String]) -> String? {
        guard !labels.isEmpty else { return nil }
        
        let frequencyDict = labels.reduce(into: [String: Int]()) { counts, label in
            counts[label, default: 0] += 1
        }
        
        guard let maxCount = frequencyDict.values.max() else { return nil }
        let mostFrequent = frequencyDict.filter { $0.value == maxCount }.map { $0.key }
        return mostFrequent.first
    }
}
