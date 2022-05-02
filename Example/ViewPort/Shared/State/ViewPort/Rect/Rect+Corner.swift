//
//  Rect+Corner.swift
//  ViewPort
//
//  Created by Nail Sharipov on 01.05.2022.
//

import HotMetal

extension Rect {
    
    struct Corner {
        
        enum Layout {
            case topLeft
            case topRight
            case bottomLeft
            case bottomRight
        }

        let layout: Layout
        let point: Vector2
    }

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
    
    func corner(layout: Corner.Layout) -> Vector2 {
        let dx = 0.5 * width
        let dy = 0.5 * height

        let corner: Vector2
        switch layout {
        case .topLeft:
            corner = .init(x: -dx, y: dy)
        case .topRight:
            corner = .init(x: dx, y: dy)
        case .bottomLeft:
            corner = .init(x: -dx, y: -dy)
        case .bottomRight:
            corner = .init(x: dx, y: -dy)
        }

        return center + corner
    }
    
}
