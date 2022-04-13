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
        
        @Published var render: Render?
        private var cubeScene: CubeScene?
        private var isDrag: Bool = false
        
        func onAppear() {
            self.render = Render() { [weak self] render in
                guard let self = self else { return }
                self.cubeScene = CubeScene(render: render)
                render.scene = self.cubeScene
            }
        }
    }
}

extension ContentView.ViewModel {

    func onDrag(translation: CGSize) {
        if !isDrag {
            isDrag = true
            cubeScene?.onStartDrag()
        }
        cubeScene?.onContinueDrag(translation: translation.reverseY)
    }
 
    func onEnd(translation: CGSize) {
        cubeScene?.onEndDrag(translation: translation.reverseY)
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
