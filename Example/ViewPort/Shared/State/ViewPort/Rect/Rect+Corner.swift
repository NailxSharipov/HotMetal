//
//  Rect+Corner.swift
//  ViewPort
//
//  Created by Nail Sharipov on 01.05.2022.
//

import HotMetal

private let cornerList: [Rect.Corner.Layout] = [.bottomLeft, .topLeft, .topRight, .bottomRight]

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
        cornerList.map { Corner(layout: $0, point: self.cornerPoint(layout: $0)) }
    }

    func opossite(layout: Corner.Layout) -> Corner.Layout {
        let n = cornerList.count
        let index = cornerList.firstIndex(where: { $0 == layout }) ?? 0
        return cornerList[(index + 2) % n]
    }
    
    func clockWise(layout: Corner.Layout) -> Corner.Layout {
        let n = cornerList.count
        let index = cornerList.firstIndex(where: { $0 == layout }) ?? 0
        return cornerList[(index + 1) % n]
    }

    func counterClockWise(layout: Corner.Layout) -> Corner.Layout {
        let n = cornerList.count
        let index = cornerList.firstIndex(where: { $0 == layout }) ?? 0
        return cornerList[(index + 3) % n]
    }
    
    func cornerPoint(layout: Corner.Layout) -> Vector2 {
        let dx = 0.5 * width
        let dy = 0.5 * height

        let corner: Vector2
        switch layout {
        case .bottomLeft:
            corner = .init(x: -dx, y: -dy)
        case .topLeft:
            corner = .init(x: -dx, y: dy)
        case .topRight:
            corner = .init(x: dx, y: dy)
        case .bottomRight:
            corner = .init(x: dx, y: -dy)
        }

        return center + corner
    }
    
    func corner(layout: Corner.Layout) -> Corner {
        Corner(layout: layout, point: self.cornerPoint(layout: layout))
    }
    
}
