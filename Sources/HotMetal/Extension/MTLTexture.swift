//
//  File.swift
//  
//
//  Created by Nail Sharipov on 15.04.2022.
//

import Metal
import CoreImage
import CoreGraphics

public extension MTLTexture {
    
    func image() -> CGImage? {
//        assert(self.pixelFormat == .bgra8Unorm)

        guard let ciImage = CIImage(
            mtlTexture: self,
            options: [
                CIImageOption.applyOrientationProperty: true
            ]
        ) else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let size = CGSize(width: width, height: height)

        let ciCtx = CIContext()
        let image = ciCtx.createCGImage(
            ciImage,
            from: .init(origin: .zero, size: size),
            format: CIFormat.RGBA8,
            colorSpace: colorSpace
        )

        
        
        return image
    }

    /*
    func toImage() -> CGImage? {
        let p = self.bytes()
      
      let pColorSpace = CGColorSpaceCreateDeviceRGB()
      
      let rawBitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue // noneSkipFirst
      let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
      
      let size = self.width * self.height * 4
      let rowBytes = self.width * 4
      
      let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
          // https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
          // N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
          return
      }
      if let provider = CGDataProvider(dataInfo: nil, data: p, size: size, releaseData: releaseMaskImagePixelData) {

          let cgImageRef = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!
          p.deallocate() //this fixes the memory leak
          return cgImageRef
      }
      p.deallocate() //this fixes the memory leak, but the data provider is no longer available (you just deallocated it's backing store)
      return nil
    }
    
    func bytes() -> UnsafeMutableRawPointer {
        let width = self.width
        let height   = self.height
        let rowBytes = self.width * 4
        let p = malloc(width * height * 4)
        
        self.getBytes(p!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        return p!
    }
     */
}
