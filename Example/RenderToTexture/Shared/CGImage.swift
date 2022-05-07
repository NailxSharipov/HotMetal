//
//  CGImage.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 17.04.2022.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

extension CGImage {
  
    
    ///https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
    func pngData() -> Data? {
        let cfdata: CFMutableData = CFDataCreateMutable(nil, 0)
        if let destination = CGImageDestinationCreateWithData(cfdata, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, self, nil)
            if CGImageDestinationFinalize(destination) {
                return cfdata as Data
            }
        }

        return nil
    }
    
    func save() {
        guard let userDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("user don't have self folder")
        }
        guard let data = pngData() else {
            fatalError("can not create png")
        }
        
        let fileName = "\(UUID().uuidString).png"
        let filePath = userDirectoryURL.appendingPathComponent(fileName, isDirectory: false).path
        
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        
        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
        debugPrint("create png: \(filePath)")
    }
}
