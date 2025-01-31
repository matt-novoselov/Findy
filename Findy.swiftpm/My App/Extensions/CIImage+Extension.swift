//
//  CiImage+Extension.swift
//  Findy
//
//  Created by Matt Novoselov on 27/01/25.
//

import CoreImage

extension CIImage {
    func toCGImage() -> CGImage? {
        let context = CIContext()
        return context.createCGImage(self, from: self.extent)
    }
}
