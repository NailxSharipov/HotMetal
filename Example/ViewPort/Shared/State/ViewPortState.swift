//
//  ViewPortState.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI

final class ViewPortState: ObservableObject {
    
    enum State {
        case blank
        case editing
    }

    private (set) var state: State = .blank {
        didSet {
            switch state {
            case .blank:
                isEditing = false
            case .editing:
                assert(oldValue == .blank)
                isEditing = true
            }
            self.objectWillChange.send()
        }
    }
    
    private (set) var isEditing: Bool = false
    private var imageSize: CGSize?
    private (set) var viewPort: ViewPort = ViewPort(imageSize: .zero, viewSize: .zero)
    private var sizeStateReceiver = Receiver<ViewSizeState>()
    private var dragStateReceiver = Receiver<DragGestureState>()
    private let sqrRadius: CGFloat = 25.magnitudeSquared
    private var activeCorner: Rect.Corner.Layout?
    private var activeBody: Bool = false

    init(viewSizeState: ViewSizeState, dragGestureState: DragGestureState) {
        sizeStateReceiver = Receiver(viewSizeState) { [weak self] sizeState in
            self?.update(viewSize: sizeState.viewSize)
        }
        
        dragStateReceiver = Receiver(dragGestureState) { [weak self] dragState in
            self?.drag(state: dragState.state)
        }
    }
    
}

extension ViewPortState {
    
    func set(imageSize: CGSize, viewSize: CGSize, viewScale: CGFloat) {
        self.viewPort = ViewPort(imageSize: imageSize, viewSize: viewSize)
        self.objectWillChange.send()
    }

    private func update(viewSize: CGSize) {
        self.viewPort.set(viewSize: viewSize)
        self.objectWillChange.send()
    }

    func drag(state: DragGestureState.State) {
        switch state {
        case .blank:
            break
        case .start(let data):
            if let corner = viewPort.isCorner(point: data.startLocation, sqrRadius: sqrRadius) {
                activeCorner = corner
            } else if viewPort.isInside(point: data.startLocation) {
                activeBody = true
            }
        case .changed(let data):
            if let corner = activeCorner {
                viewPort.move(corner: corner, translation: data.translation)
                self.objectWillChange.send()
            } else if activeBody {
                viewPort.move(translation: data.translation)
                self.objectWillChange.send()
            }
            
        case .end(let data):
            if let corner = activeCorner {
                viewPort.endMove(corner: corner, translation: data.translation)
                self.objectWillChange.send()
            } else if activeBody {
                viewPort.endMove(translation: data.translation)
                self.objectWillChange.send()
            }
            activeBody = false
            activeCorner = nil
        }
    }
    
    func animate() {
        self.viewPort.animate()
        self.objectWillChange.send()
    }
 
    func set(angle: Float) {
        viewPort.set(angle: angle)
        self.objectWillChange.send()
    }
    
}
