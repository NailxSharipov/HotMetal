//
//  ViewPort+Orientation.swift
//  ViewPort
//
//  Created by Nail Sharipov on 25.04.2022.
//

extension ViewPort {
    
    enum Orientation {
        
        case fullSizeWidth
        case fullSizeHeight
        case square
        
        init(outerRect: Size, innerRect: Size) {
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
}
