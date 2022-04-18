//
//  CVPixelBuffer.swift
//  HotMetal
//
//  Created by Nail Sharipov on 15.04.2022.
//

import AVFoundation
import Metal

extension CVPixelBuffer {
    
    static func open(source: CGImageSource) -> CVPixelBuffer? {
        let cfAuxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(
            source,
            0,
            kCGImageAuxiliaryDataTypeDisparity
        )
        
        guard let auxDataInfo = cfAuxDataInfo as? [AnyHashable: Any] else {
            return nil
        }

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
        guard
            let properties = cfProperties as? [CFString: Any],
            let orientationValue = properties[kCGImagePropertyOrientation] as? UInt32,
            let orientation = CGImagePropertyOrientation(rawValue: orientationValue)
        else {
            return nil
        }

        guard var depthData = try? AVDepthData(fromDictionaryRepresentation: auxDataInfo) else { return nil }

        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        }

        return depthData.applyingExifOrientation(orientation).depthDataMap
    }
    
    func makeTexture(device: MTLDevice) -> MTLTexture {
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let length = height * width
        let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: length)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
        
        var i = 0
        var minValue: Float = .greatestFiniteMagnitude
        var maxValue: Float = 0

        while i < length {
            let pixel = floatBuffer[i]
            assert(pixel >= 0)

            if !pixel.isNaN {
                if pixel < minValue {
                    minValue = pixel
                }

                if pixel > maxValue {
                    maxValue = pixel
                }
            }
            i += 1
        }

        let delta = maxValue - minValue
        
        i = 0

        while i < length {
            let pixel = floatBuffer[i]

            if !pixel.isNaN && delta > 0 {
                let normal = (pixel - minValue) / delta
                buffer[i] = normal
            } else {
                buffer[i] = 0
            }
            i += 1
        }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .r16Float,
            width: width,
            height: height,
            mipmapped: false
        )

        let texture = device.makeTexture(descriptor: descriptor)!
        let data = buffer.float16(count: length)
        
        texture.replace(
            region: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0,
            withBytes: data,
            bytesPerRow: width * MemoryLayout<UInt16>.stride
        )

        return texture
    }
    
}
