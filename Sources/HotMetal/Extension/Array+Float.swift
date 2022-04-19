//
//  Array+Float.swift
//  HotMetal
//
//  Created by Nail Sharipov on 15.04.2022.
//

import Accelerate

public extension UnsafeMutableBufferPointer where Element == Float {
    
    func float16(count: Int) -> UnsafeMutablePointer<UInt16>? {
        let result = UnsafeMutableBufferPointer<UInt16>.allocate(capacity: count)
        
        let width = vImagePixelCount(count)
        
        var sourceBuffer = vImage_Buffer(data: self.baseAddress, height: 1, width: width, rowBytes: MemoryLayout<Float>.size * count)
        var destinationBuffer = vImage_Buffer(data: result.baseAddress, height: 1, width: width, rowBytes: MemoryLayout<UInt16>.size * count)
        
        vImageConvert_PlanarFtoPlanar16F(&sourceBuffer, &destinationBuffer, 0)
        
        return result.baseAddress
    }
}
