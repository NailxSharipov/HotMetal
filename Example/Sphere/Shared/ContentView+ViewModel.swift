//
//  ContentView+ViewModel.swift
//  Sphere
//
//  Created by Nail Sharipov on 29.08.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var z: CGFloat = 0 {
            didSet {
                scene?.z = Float(z)
            }
        }
        
        @Published var render: Render?
        private var scene: SphereScene?
        private var isDrag: Bool = false
        
        init() {
            self.render = Render()
            self.render?.onAttachScene = { [weak self] render, _ in
                guard let self = self else { return nil }
                let scene = SphereScene(render: render)
                self.scene = scene
                return scene
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
        scene?.onContinueDrag(translation: translation.reverseY)
    }
 
    func onEnd(translation: CGSize) {
        scene?.onEndDrag(translation: translation.reverseY)
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
