//
//  ViewPort+Matrix.swift
//  ViewPort
//
//  Created by Nail Sharipov on 26.04.2022.
//

import HotMetal
import CoreGraphics

extension ViewPort {

    var scale: Float {
        let s: Float
        
        switch orient {
        case .fullSizeWidth:
            s = cropLocal.width / cropWorld.width
        case .fullSizeHeight, .square:
            s = cropLocal.height / cropWorld.height
        }

        return s
    }
    
//    
//    
//    func calcWorld(local a: CGRect, pos: CGPoint, angle: CGFloat) -> Matrix3 {
//        let orient = Orientation(outerRect: viewSize, innerRect: b.size)
//        let s = orient == .fullSizeWidth ? a.width / b.width :
//        let pos = cropWorld
//        
//    }
//    
    
}

