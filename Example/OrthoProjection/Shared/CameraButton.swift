//
//  CameraButton.swift
//  OrthoProjection
//
//  Created by Nail Sharipov on 23.04.2022.
//

import SwiftUI
import HotMetal

struct CameraButton: View {
    
    private let anchor: XYCamera.Anchor
    private let color: Color
    private let onPress: (XYCamera.Anchor) -> ()
    
    init(anchor: XYCamera.Anchor, isActive: Bool, onPress: @escaping (XYCamera.Anchor) -> ()) {
        self.anchor = anchor
        self.color = isActive ? .orange : .gray
        self.onPress = onPress
    }
    
    var body: some View {
        GeometryReader { proxy in
            Path { path in

                let dx = 0.25 * proxy.size.width
                let dy = 0.25 * proxy.size.height
                
                switch anchor {
                case .leftTop:
                    path.move(to: .init(x: dx, y: 3 * dy))
                    path.addLine(to: .init(x: dx, y: dy))
                    path.addLine(to: .init(x: 3 * dx, y: dy))
                case .rightTop:
                    path.move(to: .init(x: dx, y: dy))
                    path.addLine(to: .init(x: 3 * dx, y: dy))
                    path.addLine(to: .init(x: 3 * dx, y: 3 * dy))
                case .leftBottom:
                    path.move(to: .init(x: dx, y: dy))
                    path.addLine(to: .init(x: dx, y: 3 * dy))
                    path.addLine(to: .init(x: 3 * dx, y: 3 * dy))
                case .rightBottom:
                    path.move(to: .init(x: dx, y: 3 * dy))
                    path.addLine(to: .init(x: 3 * dx, y: 3 * dy))
                    path.addLine(to: .init(x: 3 * dx, y: dy))
                case .center:
                    path.move(to: .init(x: 2 * dx, y: dy))
                    path.addLine(to: .init(x: 2 * dx, y: 3 * dy))
                    path.move(to: .init(x: dx, y: 2 * dy))
                    path.addLine(to: .init(x: 3 * dx, y: 2 * dy))
                }
            }
            .stroke(style: .init(lineWidth: 4, lineCap: .round))
            .foregroundColor(color)
        }
        .background(Color(white: 1, opacity: 0.1))
        .cornerRadius(8)
        .onTapGesture() {
            self.onPress(anchor)
        }
    }
    
}
