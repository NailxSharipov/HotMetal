//
//  ContentView+ViewModel.swift
//  OrthoProjection
//
//  Created by Nail Sharipov on 23.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var anchor: XYCamera.Anchor = .center {
            didSet {
                scene?.update(anchor: anchor)
            }
        }
        
        var angle: Float = 0 {
            didSet {
                scene?.rotate(angle: angle)
            }
        }
        
        let render: Render?
        private var scene: MainScene?
        private var isDrag: Bool = false
        
        init() {
            self.render = Render()
            self.render?.onViewReady = { [weak self] render in
                guard
                    let self = self,
                    let scene = MainScene(render: render, anchor: self.anchor)
                else { return }
                self.scene = scene
                render.attach(scene: scene)
            }
        }
    }
}

extension ContentView.ViewModel {

    func onDrag(translation: CGSize) {
        guard
            let render = render,
            let scene = scene
        else { return }

        if !isDrag {
            isDrag = true
            scene.onStartDrag()
        }
        scene.onDrag(translation: translation.normolize(render: render))
    }
 
    func onEnd(translation: CGSize) {
        guard
            let render = render,
            let scene = scene
        else { return }
        
        scene.onDrag(translation: translation.normolize(render: render))
        isDrag = false
    }
    
}

private extension CGSize {
    
    func normalize(render: Render) -> CGSize {
        let s = render.scale
        return CGSize(
            width: s * width,
            height: -s * height
        )
    }
}
