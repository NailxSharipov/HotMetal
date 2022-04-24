//
//  ViewPort.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import CoreGraphics
import HotMetal
import simd

struct ViewPort: Equatable {

    struct Vertex {
        let pos: Vector3
        let uv: Vector2
    }
    
    struct Camera {
        let pos: Vector3
        let ratio: Float
        let size: Float
    }
    
    
    private let minSize: CGFloat = 16
    
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    enum Ratio {
        case free
        case square
        case w4h3
        case w3h4
    }
    
    private (set) var viewRect: CGRect = .zero  // in world pixels
    private (set) var worldRect: CGRect = .zero // in world pixels
    private (set) var localRect: CGRect = .zero // in screan pixels
    private (set) var imageSize: CGSize = .zero
    private (set) var ratio: Ratio = .free
    
    private (set) var cameraRatio: Float = 1
    private (set) var cameraAngle: Float = 0
    private (set) var cameraSize: Float = 0
    
    private (set) var insetRatio: CGFloat = 0
 
    mutating func setImage(width: CGFloat, height: CGFloat, insetRatio: CGFloat = 0.05) {
        self.imageSize = CGSize(width: width, height: height)
        self.worldRect = CGRect(origin: .zero, size: imageSize)
        self.localRect = worldRect
        self.insetRatio = insetRatio
    }
    
    mutating func setView(size: CGSize) {
        cameraSize = Float(size.height)
        cameraRatio = Float(size.width / size.height)
        
        let wRatio = size.width / localRect.width
        let hRatio = size.height / localRect.height

        let inset = self.inset(viewSize: size)
        let newRect: CGRect
        if wRatio < hRatio {
            // width is more

            let width = size.width - 2 * inset
            let height = width * worldRect.height / worldRect.width

            newRect = CGRect(
                x: inset,
                y: 0.5 * (size.height - height),
                width: width,
                height: height
            )
        } else {
            // height is more
            let height = size.height - 2 * inset
            let width = height * worldRect.width / worldRect.height
            
            newRect = CGRect(
                x: 0.5 * (size.width - width),
                y: inset,
                width: width,
                height: height
            )
        }
        
        localRect = newRect
    }
    
    
    func move(corner: ViewPort.Corner, screenPos: CGPoint) -> CGPoint {
//
//
//        let pos = localToWorld * screenPos
//
//        let x: CGFloat
//        let y: CGFloat
//
//        switch corner {
//        case .topLeft:
//            x = min(pos.x, round(world.maxX - minSize))
//            y = min(pos.y, round(world.maxY - minSize))
//        case .topRight:
//            x = max(pos.x, round(world.minX + minSize))
//            y = min(pos.y, round(world.maxY - minSize))
//        case .bottomLeft:
//            x = min(pos.x, round(world.maxX - minSize))
//            y = max(pos.y, round(world.minY + minSize))
//        case .bottomRight:
//            x = max(pos.x, round(world.minX + minSize))
//            y = max(pos.y, round(world.minY + minSize))
//        }
//
//        return CGPoint(x: x, y: y) / localToWorld
        return .zero
    }
    
    func getVertices() -> [Vertex] {
        let cx = Float(worldRect.midX)
        let cy = Float(worldRect.midY)

        let sx = Float(1 / imageSize.width)
        let sy = Float(1 / imageSize.height)
        
        let sMat = Matrix3.scale(sx: sx, sy: sy)
        let rMat = Matrix3.rotate(angle: cameraAngle)
        let tMat = Matrix3.translate(x: cx, y: cy)
        
        let transform = sMat// * rMat * tMat
        
        let p0 = Vector3(worldRect.minX, worldRect.maxY)    // leftBottom
        let p1 = Vector3(worldRect.minX, worldRect.minY)    // leftTop
        let p2 = Vector3(worldRect.maxX, worldRect.minY)    // rightTop
        let p3 = Vector3(worldRect.maxX, worldRect.maxY)    // rightBottom
        
        let uv0 = transform * p0
        let uv1 = transform * p1
        let uv2 = transform * p2
        let uv3 = transform * p3
        
        let buffer = [
            Vertex(pos: p0, uv: uv0),
            Vertex(pos: p1, uv: uv1),
            Vertex(pos: p2, uv: uv2),
            Vertex(pos: p3, uv: uv3)
        ]
        
        return buffer
    }
    
    func camera() -> Camera {
        let x = Float(worldRect.midX)
        let y = Float(worldRect.midY)

        return Camera(
            pos: Vector3(x, y, -1),
            ratio: cameraRatio,
            size: cameraSize
        )
    }

    @inline(__always)
    private func inset(viewSize: CGSize) -> CGFloat {
        ceil(insetRatio * min(viewSize.width, viewSize.height))
    }
    
}

private extension Vector3 {
    
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: Float(x), y: Float(y), z: 0)
    }
}

private extension Vector2 {
    
    init(_ v: Vector3) {
        self.init(x: v.x, y: v.y)
    }
}

private extension ViewPort.Vertex {
    
    init(pos: Vector3, uv: Vector3) {
        self.pos = pos
        self.uv = Vector2(uv)
    }
}

extension ViewPort.Vertex: CustomStringConvertible {
    
    var description: String {
        let x = String(format: "%.1f", pos.x)
        let y = String(format: "%.1f", pos.y)
        let u = String(format: "%.1f", uv.x)
        let v = String(format: "%.1f", uv.x)
        return "x: \(x), y: \(y), u: \(u), v: \(v)"
    }
}
