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

    static let zero = Rect(center: .zero, width: 0, height: 0, angle: 0)
    
    var size: Size {
        Size(width: width, height: height)
    }
    
    let width: Float
    let height: Float
    var angle: Float
    let center: Vector2

    init(center: Vector2, width: Float, height: Float, angle: Float = 0) {
        self.center = center
        self.width = width
        self.height = height
        self.angle = angle
    }
    
    init(x: Float, y: Float, width: Float, height: Float, angle: Float = 0) {
        self.center = .init(x: x, y: y)
        self.width = width
        self.height = height
        self.angle = angle
    }
}

extension Rect {
    
    init(rect: CGRect) {
        self.init(
            center: .init(x: Float(rect.midX), y: Float(rect.midY)),
            width: Float(rect.width),
            height: Float(rect.height),
            angle: 0
        )
    }

}

extension Rect {
    
    var points: [Vector2] {
        let dx = 0.5 * width
        let dy = 0.5 * height
        
        let vectors = [
            Vector2(x: -dx, y: -dy),
            Vector2(x: -dx, y:  dy),
            Vector2(x:  dx, y:  dy),
            Vector2(x:  dx, y: -dy)
        ]

        guard angle != 0 else {
            return vectors.map({ $0 + center })
        }
        
        let cs = cos(angle)
        let sn = sin(angle)
        
        let m = float2x2(
            .init(cs, sn),
            .init(-sn, cs)
        )

        return vectors.map({ simd_mul(m, $0) + center })
    }
    
    @inline(__always)
    func translate(size: Size) -> Rect {
        return Rect(
            center: .init(x: center.x + size.width, y: center.y + size.height),
            width: width,
            height: height,
            angle: 0
        )
    }
    
    func isContain(point: Vector2) -> Bool {
        guard angle != 0 else {
            let isX = abs(center.x - point.x) < 0.5 * width
            let isY = abs(center.y - point.y) < 0.5 * height
            
            return isX && isY
        }
        
        assertionFailure("Not implement")
        return false
    }

    #if DEBUG
    
    @inline(__always)
    func transform(matrix: float3x3) -> [CGPoint] {
        self.points.map({ CGPoint(simd_mul(matrix, Vector3($0.x, $0.y, 1))) })
    }
    
    #endif
}
