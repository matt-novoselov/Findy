import Foundation

struct SceneMeasurement {
    let meterDistance: Float
    let rotationDegrees: (yaw: Float, pitch: Float, roll: Float)
    
    // Private computed property to represent the distance in meters.
    private var baseMeasurement: Measurement<UnitLength> {
        Measurement(value: Double(meterDistance), unit: .meters)
    }
    
    // Private computed property to convert the distance to the user's preferred unit.
    private var convertedMeasurement: Measurement<UnitLength> {
        if Locale.current.measurementSystem == .metric {
            // If the user uses the metric system, return meters or centimeters.
            return meterDistance >= 1 ? baseMeasurement : baseMeasurement.converted(to: .centimeters)
        } else {
            // If the user uses the imperial system, return feet or inches.
            let inFeet = baseMeasurement.converted(to: .feet)
            return inFeet.value >= 1 ? inFeet : baseMeasurement.converted(to: .inches)
        }
    }
    
    // MARK: - Public Interface
    // Computed property to get the numeric value of the converted measurement.
    var numericValue: Double {
        convertedMeasurement.value
    }
    
    // Computed property to get the unit symbol of the converted measurement.
    var unitSymbol: String {
        convertedMeasurement.unit.symbol
    }
    
    // Computed property to get the formatted value of the measurement (short style).
    var formattedValue: String {
        formattedValue(with: .short)
    }
    
    // Computed property to get the formatted value of the measurement (long style).
    var formattedValueFull: String {
        formattedValue(with: .long)
    }

    // Formats the measurement value with the specified unit style.
    func formattedValue(with style: MeasurementFormatter.UnitStyle) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter.minimumFractionDigits = 2
        formatter.unitStyle = style
        return formatter.string(from: convertedMeasurement)
    }
    
    // Function to calculate the direction
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
        
        // Helper function to normalize the degrees to be within 0-360 range.
        func normalizedDegrees(_ degrees: Double) -> Double {
            let modDegrees = degrees.truncatingRemainder(dividingBy: 360)
            return modDegrees >= 0 ? modDegrees : modDegrees + 360
        }
    }
}
