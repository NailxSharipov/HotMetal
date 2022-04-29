//
//  CropView+ViewModel.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI
import Combine

extension CropView {

    final class ViewModel: ObservableObject {
        
        private (set) var world: Shape?
        private (set) var camera: Shape?
        private (set) var viewCorners: ViewCorners?
        private (set) var border: Border?
        private (set) var net: Net?
        private (set) var background: Background?

        private var receiverViewPort = Receiver<ViewPortState>()
    }
    
}

extension CropView.ViewModel {
    
    func onAppear(viewPortState: ViewPortState) {
        receiverViewPort = .init(viewPortState) { [weak self] state in
            guard let self = self else { return }
            self.onUpdateViewPort(state: state)
        }
    }
    
    private func onUpdateViewPort(state: ViewPortState) {
        self.updateCropView(rect: state.viewPort.cropView)
        self.updateDebug(world: state.viewPort.debugWorldView, camera: state.viewPort.debugCameraView)
        self.objectWillChange.send()
    }
    
    private func updateCropView(rect: CGRect) {
        let p0 = CGPoint(x: rect.minX, y: rect.maxY)    // leftBottom
        let p1 = CGPoint(x: rect.minX, y: rect.minY)    // leftTop
        let p2 = CGPoint(x: rect.maxX, y: rect.minY)    // rightTop
        let p3 = CGPoint(x: rect.maxX, y: rect.maxY)    // rightBottom
        
        let d: CGFloat = 24
        
        viewCorners = CropView.ViewCorners(
            corners: [
                .init(  // leftBottom
                    a: .init(x: p0.x + d, y: p0.y),
                    b: p0,
                    c: .init(x: p0.x, y: p0.y - d)
                ),
                .init(  // leftTop
                    a: .init(x: p1.x, y: p1.y + d),
                    b: p1,
                    c: .init(x: p1.x + d, y: p1.y)
                ),
                .init(  // rightTop
                    a: .init(x: p2.x - d, y: p2.y),
                    b: p2,
                    c: .init(x: p2.x, y: p2.y + d)
                ),
                .init(  // rightBottom
                    a: .init(x: p3.x - d, y: p3.y),
                    b: p3,
                    c: .init(x: p3.x, y: p3.y - d)
                )
            ],
            color: .white,
            lineWidth: 4
        )
        
        border = CropView.Border(
            rect: rect,
            color: .white,
            lineWidth: 1
        )
    }
    
    private func updateDebug(world: [CGPoint], camera: [CGPoint]) {
        self.world = CropView.Shape(
            points: world,
            color: .green,
            lineWidth: 4
        )
        
        self.camera = CropView.Shape(
            points: camera,
            color: .red,
            lineWidth: 2
        )
    }
    
}
