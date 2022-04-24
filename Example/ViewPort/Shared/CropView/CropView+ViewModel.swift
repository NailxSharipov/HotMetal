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
        
        private (set) var viewCorners: ViewCorners?
        private (set) var border: Border?
        private (set) var net: Net?
        private (set) var background: Background?

        private var receiverViewPort = Receiver<ViewPortState>()
        private var receiverViewSize = Receiver<ViewSizeState>()
        private var receiverDragGesture = Receiver<DragGestureState>()

    }
    
}

extension CropView.ViewModel {
    
    func onAppear(viewPortState: ViewPortState, viewSizeState: ViewSizeState, dragGestureState: DragGestureState) {
        receiverViewPort = .init(viewPortState) { [weak self] state in
            guard let self = self else { return }
            self.onUpdateViewPort(state: state)
        }

        receiverDragGesture = .init(dragGestureState) { [weak self] state in
            guard let self = self else { return }
            self.onUpdateDragGesture(state: state)
        }
    }
    
    private func onUpdateViewPort(state: ViewPortState) {
        self.updateCropView(rect: state.viewPort.localRect)
    }

    private func onUpdateDragGesture(state: DragGestureState) {
        debugPrint("dragGestureState: \(state.state)")
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

        self.objectWillChange.send()
    }
    
}
