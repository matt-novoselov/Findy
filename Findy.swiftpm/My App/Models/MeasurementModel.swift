import Foundation

struct SceneMeasurement: Equatable {
    let meterDistance: Float
    let rotationDegrees: Float
    
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
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter.minimumFractionDigits = 2
        formatter.unitStyle = .short
        return formatter.string(from: convertedMeasurement)
    }
}
