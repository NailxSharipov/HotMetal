//
//  ContentView+ViewModel.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
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
        private var scene: CubeScene?
        private var isDrag: Bool = false
        
        @MainActor
        init() {
            self.render = Render()
            self.render?.onAttachScene = { [weak self] render, _ in
                guard let self = self else { return nil }
                let scene = CubeScene(render: render)
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
