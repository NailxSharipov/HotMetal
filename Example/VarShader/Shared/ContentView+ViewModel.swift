//
//  ContentView+ViewModel.swift
//  VarShader
//
//  Created by Nail Sharipov on 14.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var red: CGFloat = 0 {
            didSet {
                scene?.red = Float(red)
            }
        }
        
        @Published var green: CGFloat = 0 {
            didSet {
                scene?.green = Float(green)
            }
        }
        
        @Published var blue: CGFloat = 0 {
            didSet {
                scene?.blue = Float(blue)
            }
        }
        
        @Published var render: Render?
        private var scene: MainScene?
        private var isDrag: Bool = false
        
        init() {
            self.render = Render()
            self.render?.onViewReady = { [weak self] render, _ in
                guard
                    let self = self,
                    let scene = MainScene(render: render)
                else { return }
                
                self.scene = scene
                render.attach(scene: scene)
            }
        }

    }
}


extension CGSize {
    
    var reverseY: CGSize {
        var size = self
        size.height = -size.height
        return size
    }
    
}
