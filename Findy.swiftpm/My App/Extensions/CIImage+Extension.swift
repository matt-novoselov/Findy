import CoreImage

extension CIImage {
    func toCGImage() -> CGImage? {
        let context = CIContext()
        return context.createCGImage(self, from: self.extent)
    }
}

// White color
extension CIImage {
    static var white: CIImage {
        let color = CIColor(red: 1, green: 1, blue: 1)
        return CIImage(color: color)
    }
}
