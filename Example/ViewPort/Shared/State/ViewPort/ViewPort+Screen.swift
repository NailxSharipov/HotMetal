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
        let center = transform.toScreen(point: cropView.center)

        let x = center.x - 0.5 * cropView.width
        let y = center.y - 0.5 * cropView.height

        return CGRect(
            origin: CGPoint(x: CGFloat(x), y: CGFloat(y)),
            size: CGSize(size: cropView.size)
        )
    }

}
