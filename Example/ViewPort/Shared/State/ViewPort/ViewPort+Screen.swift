//
//  ViewPort+Screen.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import CoreGraphics
import HotMetal
import simd

extension ViewPort {

    var cropRect: CGRect {
        guard !transform.isEmpty else { return .zero}
        
        let center = transform.localToScreen(point: frameLocal.center)

        let x = center.x - 0.5 * frameLocal.width
        let y = center.y - 0.5 * frameLocal.height

        return CGRect(
            origin: CGPoint(x: CGFloat(x), y: CGFloat(y)),
            size: CGSize(size: frameLocal.size)
        )
    }

}
