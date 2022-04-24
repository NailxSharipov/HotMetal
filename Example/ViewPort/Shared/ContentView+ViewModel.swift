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

        init() {
            viewPortState = ViewPortState(viewSizeState: viewSizeState)
            render = Render()
            render?.onViewReady = { [weak self] render in
                guard
                    let self = self,
                    let scene = MainScene(render: render)
                else { return }
                self.scene = scene
                render.attach(scene: scene)
                
                let width = scene.node.image?.width ?? 0
                let height = scene.node.image?.height ?? 0
                
                self.viewPortState.setImage(width: width, height: height)
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
        guard let render = render, let scene = scene else { return }

        let cameraData = viewPort.camera()
        
        scene.camera.update(
            projection: .ortographic(cameraData.size),
            aspectRatio: cameraData.ratio
        )
        scene.camera.update(position: cameraData.pos)

        let buffer = viewPort.getVertices()
        scene.node.set(render: render, buffer: buffer)
        debugPrint(buffer)
    }

}
