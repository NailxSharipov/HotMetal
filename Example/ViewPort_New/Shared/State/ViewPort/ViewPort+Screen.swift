//
//  ViewPort+Screen.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import CoreGraphics
import HotMetal

extension ViewPort {

    var cropRect: CGRect {
        let size = viewSize
        let rect = cropView
        
        let x = 0.5 * (size.width - rect.width) + rect.center.x
        let y = 0.5 * (size.height - rect.height) - rect.center.y
        
        let newRect = CGRect(
            x: CGFloat(x),
            y: CGFloat(y),
            width: CGFloat(rect.width),
            height: CGFloat(rect.height)
        )
        
        return newRect
    }

}
