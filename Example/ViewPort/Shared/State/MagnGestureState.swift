//
//  MagnGestureState.swift
//  ViewPort
//
//  Created by Nail Sharipov on 11.05.2022.
//

import SwiftUI

final class MagnGestureState: ObservableObject {
    
    enum State {
        case blank
        case start(MagnificationGesture.Value)
        case changed(MagnificationGesture.Value)
        case end(MagnificationGesture.Value)
    }

    private (set) var state: State = .blank

    func onChanged(data: MagnificationGesture.Value) {
        switch state {
        case .blank:
            state = .start(data)
            self.objectWillChange.send()
        default:
            state = .changed(data)
            self.objectWillChange.send()
        }
    }
    
    func onEnded(data: MagnificationGesture.Value) {
        state = .end(data)
        self.objectWillChange.send()
        state = .blank
    }
    
}
