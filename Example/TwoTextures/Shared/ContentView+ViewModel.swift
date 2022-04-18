//
//  ContentView+ViewModel.swift
//  TwoTextures
//
//  Created by Nail Sharipov on 14.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var front: CGFloat = 0 {
            didSet {
                if front > rear {
                    rear = front
                }
                scene?.front = Float(front)
            }
        }
        
        @Published var rear: CGFloat = 1 {
            didSet {
                if rear < front {
                    front = rear
                }
                scene?.rear = Float(rear)
            }
        }
        
        @Published var glow: CGFloat = 0 {
            didSet {
                scene?.glow = Float(glow)
            }
        }
        
        @Published var render: Render?
        private var scene: MainScene?
        private var isDrag: Bool = false
        
        func onAppear() {
            self.render = Render() { [weak self] render in
                guard let self = self else { return }
                self.scene = MainScene(render: render)
                self.scene?.front = Float(self.front)
                self.scene?.rear = Float(self.rear)
                self.scene?.glow = Float(self.glow)
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
