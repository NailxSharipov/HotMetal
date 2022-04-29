//
//  CGSize+Transformation.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import CoreGraphics

extension CGSize {
    
    func scale(_ s: CGFloat) -> CGSize {
        CGSize(width: s * width, height: s * height)
    }
    
}
