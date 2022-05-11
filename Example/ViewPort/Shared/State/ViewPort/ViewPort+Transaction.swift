//
//  ViewPort+Transaction.swift
//  ViewPort
//
//  Created by Nail Sharipov on 11.05.2022.
//

import HotMetal

extension ViewPort {
    
    struct Transaction {
        
        let startLocalFrame: Rect
        let startWorldFrame: Rect
        let startViewPoint: Vector2

        init(worldFrame: Rect, viewPoint: Vector2) {
            startLocalFrame = .zero
            startWorldFrame = worldFrame
            startViewPoint = viewPoint
        }

        init(localFrame: Rect) {
            startLocalFrame = localFrame
            startWorldFrame = .zero
            startViewPoint = .zero
        }
    }
}
