//
//  ContentView+ViewModel.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        let dragGestureState = DragGestureState()
        let viewSizeState = ViewSizeState()
        let viewPortState: ViewPortState
        
        let render: Render?
        private var scene: MainScene?
        private var receiverViewPort = Receiver<ViewPortState>()
        var posX: CGFloat = 0 {
            didSet {
                onUpdate()
            }
            
        }
        var posY: CGFloat = 0 {
            didSet {
                onUpdate()
            }
            
        }

        init() {
            viewPortState = ViewPortState(viewSizeState: viewSizeState, dragGestureState: dragGestureState)
            render = Render()
            render?.onViewReady = { [weak self] render, viewSize in
                guard
                    let self = self,
                    let scene = MainScene(render: render)
                else { return }
                self.scene = scene
                render.attach(scene: scene)
                
                let width = scene.node.image?.width ?? 0
                let height = scene.node.image?.height ?? 0
                
                self.viewPortState.set(
                    imageSize: CGSize(width: width, height: height),
                    viewSize: viewSize,
                    viewScale: render.scale
                )
            }
            receiverViewPort = .init(viewPortState) { [weak self] state in
                guard let self = self else { return }
                self.onUpdate(viewPort: state.viewPort)
            }
        }
        
        func animate() {
            viewPortState.animate()
        }
    }
}

extension ContentView.ViewModel {

    private func onUpdate(viewPort: ViewPort) {
        guard let scene = scene else { return }

        scene.vpCamera.update(viewPort: viewPort)
    }
    
    private func onUpdate() {
        guard let scene = scene else { return }
        let viewPort = viewPortState.viewPort

        scene.vpCamera.update(viewPort: viewPort, posX: posX, posY: posY)
    }

}
