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
        
        func onAppear() {
            self.render = Render() { [weak self] render in
                guard let self = self else { return }
                self.scene = MainScene(render: render)
                render.scene = self.scene
            }
        }

    }
}

extension ContentView.ViewModel {

    func onDrag(translation: CGSize) {
        if !isDrag {
            isDrag = true
            scene?.onStartDrag()
        }
        scene?.onDrag(translation: translation.reverseY)
    }
 
    func onEnd(translation: CGSize) {
        scene?.onDrag(translation: translation.reverseY)
        isDrag = false
    }
}

extension CGSize {
    
    var reverseY: CGSize {
        var size = self
        size.height = -size.height
        return size
    }
    
}
