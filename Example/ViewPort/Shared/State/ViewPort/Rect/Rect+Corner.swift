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
    
}
