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
        
        @MainActor
        init() {
            self.render = Render()
            self.render?.onAttachScene = { [weak self] render, _ in
                guard let self = self else { return nil }
                let scene = MainScene(render: render)
                self.scene = scene
                scene?.front = Float(self.front)
                scene?.rear = Float(self.rear)
                scene?.glow = Float(self.glow)
                return scene
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
