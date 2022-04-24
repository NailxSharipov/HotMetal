//
//  ContentView+ViewModel.swift
//  Image
//
//  Created by Nail Sharipov on 13.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        let render: Render?
        private var scene: ImageScene?
        private var isDrag: Bool = false
        
        init() {
            self.render = Render()
            self.render?.onViewReady = { [weak self] render in
                guard
                    let self = self,
                    let scene = ImageScene(render: render)
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
    
    func normolize(render: Render) -> CGSize {
        let s = render.scale
        return CGSize(
            width: s * width,
            height: -s * height
        )
    }
}
