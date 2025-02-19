import Foundation

struct SceneMeasurement {
    let meterDistance: Float
    let rotationDegrees: (yaw: Float, pitch: Float, roll: Float)
    
    private var baseMeasurement: Measurement<UnitLength> {
        Measurement(value: Double(meterDistance), unit: .meters)
    }
    
    private var convertedMeasurement: Measurement<UnitLength> {
        if Locale.current.measurementSystem == .metric {
            return meterDistance >= 1 ? baseMeasurement : baseMeasurement.converted(to: .centimeters)
        } else {
            let inFeet = baseMeasurement.converted(to: .feet)
            return inFeet.value >= 1 ? inFeet : baseMeasurement.converted(to: .inches)
        }
    }
    
    // MARK: - Public Interface
    var numericValue: Double {
        convertedMeasurement.value
    }
    
    var unitSymbol: String {
        convertedMeasurement.unit.symbol
    }
    
    var formattedValue: String {
        formattedValue(with: .short)
    }
    
    var formattedValueFull: String {
        formattedValue(with: .long)
    }

    func formattedValue(with style: MeasurementFormatter.UnitStyle) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter.minimumFractionDigits = 2
        formatter.unitStyle = style
        return formatter.string(from: convertedMeasurement)
    }
    
    // Add this function to calculate the direction
    var getDirection: (String, String) {
        let normalizedDegrees = normalizedDegrees(Double(self.rotationDegrees.yaw))
        let angle = normalizedDegrees
        if (0...25).contains(angle) || (335...360).contains(angle) {
            return ("In front", "In front of you")
        } else if (225...335).contains(angle) {
            return ("To the right", "To your right")
        } else if (135...225).contains(angle) {
            return ("Behind", "Behind you")
        } else {
            return ("To the left", "To your left")
        }
        
        func normalizedDegrees(_ degrees: Double) -> Double {
            let modDegrees = degrees.truncatingRemainder(dividingBy: 360)
            return modDegrees >= 0 ? modDegrees : modDegrees + 360
        }
    }
}
