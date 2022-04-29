//
//  ViewPort+Data.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

import CoreGraphics
import HotMetal

extension ViewPort {
    
    enum Orientation {
        
        case fullSizeWidth
        case fullSizeHeight
        case square
        
        init(outerRect: CGSize, innerRect: CGSize) {
            let wr = outerRect.width / innerRect.width
            let hr = outerRect.height / innerRect.height
            
            if hr > wr {
                self = .fullSizeWidth
            } else if wr > hr {
                self = .fullSizeHeight
            } else {
                self = .square
            }
        }
    }
    
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
    
    struct Vertex {
        let pos: Vector3
        let uv: Vector2
        
        init(pos: Vector3, uv: Vector3) {
            self.pos = pos
            self.uv = Vector2(uv)
        }
    }
}

#if DEBUG
extension ViewPort.Vertex: CustomStringConvertible {
    
    var description: String {
        let x = String(format: "%.1f", pos.x)
        let y = String(format: "%.1f", pos.y)
        let u = String(format: "%.1f", uv.x)
        let v = String(format: "%.1f", uv.x)
        return "x: \(x), y: \(y), u: \(u), v: \(v)"
    }
}
#endif
