//
//  Rect.swift
//  ViewPort
//
//  Created by Nail Sharipov on 28.04.2022.
//

import simd
import HotMetal
import CoreGraphics

struct Rect: Equatable {

    static let zero = Rect(center: .zero, width: 0, height: 0)
    
    var size: Size {
        Size(width: width, height: height)
    }
    
    let width: Float
    let height: Float
    var center: Vector2

    init(center: Vector2, width: Float, height: Float) {
        self.center = center
        self.width = width
        self.height = height
    }
    
    init(x: Float, y: Float, width: Float, height: Float) {
        self.center = .init(x: x, y: y)
        self.width = width
        self.height = height
    }
}

extension Rect {
    
    init(rect: CGRect) {
        self.init(
            center: .init(x: Float(rect.midX), y: Float(rect.midY)),
            width: Float(rect.width),
            height: Float(rect.height)
        )
    }

}

extension Rect {
    
    var corners: [Corner] {
        let dx = 0.5 * width
        let dy = 0.5 * height
        
        return [
            Corner(layout: .bottomLeft, point: center + .init(x: -dx, y: -dy)),
            Corner(layout: .topLeft, point: center + .init(x: -dx, y: dy)),
            Corner(layout: .topRight, point: center + .init(x: dx, y: dy)),
            Corner(layout: .bottomRight, point: center + .init(x: dx, y: -dy))
        ]
    }

//
//    func rotate(angle: Float) -> Points {
//        let dx = 0.5 * width
//        let dy = 0.5 * height
//
//        let bottomLeft = Vector2(x: -dx, y: -dy)
//        let topLeft = Vector2(x: -dx, y:  dy)
//        let topRight = Vector2(x:  dx, y:  dy)
//        let bottomRight = Vector2(x:  dx, y: -dy)
//
//        let cs = cos(angle)
//        let sn = sin(angle)
//
//        let m = float2x2(
//            .init(cs, sn),
//            .init(-sn, cs)
//        )
//
//        return Points(
//            bottomLeft: simd_mul(m, bottomLeft) + center,
//            topLeft: simd_mul(m, topLeft) + center,
//            topRight: simd_mul(m, topRight) + center,
//            bottomRight: simd_mul(m, bottomRight) + center
//        )
//    }
//
    @inline(__always)
    func translate(size: Size) -> Rect {
        return Rect(
            center: .init(x: center.x + size.width, y: center.y + size.height),
            width: width,
            height: height
        )
    }
    
    func isContain(point: Vector2) -> Bool {
        let isX = abs(center.x - point.x) < 0.5 * width
        let isY = abs(center.y - point.y) < 0.5 * height
        
        return isX && isY
    }
}
