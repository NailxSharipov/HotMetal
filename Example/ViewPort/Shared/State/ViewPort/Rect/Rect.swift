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

    init(center: Vector2, size: Size) {
        self.center = center
        self.width = size.width
        self.height = size.height
    }
    
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
    
    init(a: Vector2, b: Vector2) {
        let ab = a - b
        let size = Size(width: abs(ab.x), height: abs(ab.y))
        let center = 0.5 * (a + b)
        
        self.init(center: center, size: size)
    }

}

extension Rect {

    @inline(__always)
    func translate(size: Size) -> Rect {
        Rect(
            center: center + size,
            width: width,
            height: height
        )
    }
    
    func isContain(point: Vector2) -> Bool {
        let isX = abs(center.x - point.x) < 0.5 * width
        let isY = abs(center.y - point.y) < 0.5 * height
        
        return isX && isY
    }
    
    var rounded: Rect {
        let x = center.x.rounded
        let y = center.y.rounded
        let width = width.rounded
        let height = height.rounded
        
        return Rect(x: x, y: y, width: width, height: height)
    }
}


private extension Float {
   
    var rounded: Float {
        0.5 * (self * 2).rounded(.toNearestOrAwayFromZero)
    }
}
