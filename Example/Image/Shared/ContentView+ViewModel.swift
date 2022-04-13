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
        
        @Published var render: Render?
        private var scene: ImageScene?
        private var isDrag: Bool = false
        
        func onAppear() {
            self.render = Render() { [weak self] render in
                guard let self = self else { return }
                self.scene = ImageScene(render: render)
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
