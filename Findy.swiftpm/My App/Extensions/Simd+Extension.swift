import simd

extension float4x4 {
    // Computed property to extract the position (translation) from a 4x4 matrix.
    var position: SIMD3<Float> {
        // The position is in the last column of the matrix.
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
