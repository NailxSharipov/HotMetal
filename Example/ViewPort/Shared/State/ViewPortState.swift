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
    private (set) var viewPort = ViewPort()
    private var sizeStateReceiver = Receiver<ViewSizeState>()

    init(viewSizeState: ViewSizeState) {
        sizeStateReceiver = Receiver(viewSizeState) { [weak self] sizeState in
            self?.update(viewSize: sizeState.viewSize)
        }
    }
    
}

extension ViewPortState {
    
    func setImage(width: Int, height: Int) {
        viewPort.setImage(width: CGFloat(width), height: CGFloat(height))
        self.objectWillChange.send()
    }

    private func update(viewSize: CGSize) {
        viewPort.setView(size: viewSize)
        self.objectWillChange.send()
    }
    
}
