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
        let magnGestureState = MagnGestureState()
        let viewSizeState = ViewSizeState()
        let viewPortState: ViewPortState
        
        let render: Render?
        private var scene: MainScene?
        private var receiverViewPort = Receiver<ViewPortState>()
        var angle: Float = 0 {
            didSet {
                onUpdate()
            }
        }

        init() {
            viewPortState = ViewPortState(viewSizeState: viewSizeState, dragGestureState: dragGestureState, magnGestureState: magnGestureState)
            render = Render()
            render?.onAttachScene = { [weak self] render, viewSize in
                guard
                    let self = self,
                    let scene = MainScene(render: render)
                else { return nil }
                self.scene = scene
                
                let width = scene.node.image?.width ?? 0
                let height = scene.node.image?.height ?? 0
                
                self.viewPortState.set(
                    imageSize: CGSize(width: width, height: height),
                    viewSize: viewSize
                )
                return scene
            }
            receiverViewPort = .init(viewPortState) { [weak self] state in
                guard let self = self else { return }
                self.onUpdate(viewPort: state.viewPort)
            }
        }

    }
}

extension ContentView.ViewModel {

    private func onUpdate(viewPort: ViewPort) {
        guard let scene = scene else { return }

        scene.vpCamera.update(viewPort: viewPort)
        render?.redraw()
    }
    
    private func onUpdate() {
        viewPortState.set(angle: angle)
    }

}
