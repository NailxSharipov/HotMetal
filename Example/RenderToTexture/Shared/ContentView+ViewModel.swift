//
//  ContentView+ViewModel.swift
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
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
        
        @Published var glow: CGFloat = 0.05 {
            didSet {
                scene?.glow = Float(glow)
            }
        }
        
        @Published var render: Render?
        private var scene: MainScene?
        private var isDrag: Bool = false
        
        func onAppear() {
            self.render = Render() { [weak self] render in
                guard
                    let self = self,
                    let scene = MainScene(render: render)
                else { return }
                
                self.scene = scene
                render.scene = scene
                scene.front = Float(self.front)
                scene.rear = Float(self.rear)
                scene.glow = Float(self.glow)
            }
        }

        func save() {
            debugPrint("Save")
            let width = 3024
            let height = 4032
            guard
                let render = Render(pixelFormat: .bgra8Unorm_srgb, depthAttachmentPixelFormat: .invalid),
                let scene = OffScreenScene(render: render, width: width, height: height)
            else {
                return
            }

            render.scene = scene
            
            scene.front = Float(front)
            scene.rear = Float(rear)
            scene.glow = Float(glow)
            
            
            guard let texture = render.doShot(width: width, height: height) else {
                return
            }
            
            guard let image = texture.image() else {
                return
            }
            
            image.save()
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
