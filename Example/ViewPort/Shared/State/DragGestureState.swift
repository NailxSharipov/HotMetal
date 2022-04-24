//
//  DragGestureState.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI

final class DragGestureState: ObservableObject {
    
    enum State {
        case blank
        case start
        case changed(DragGesture.Value)
        case end(DragGesture.Value)
    }

    private (set) var state: State = .blank

    func onChanged(data: DragGesture.Value) {
        switch state {
        case .blank:
            state = .start
            self.objectWillChange.send()
        default:
            state = .changed(data)
            self.objectWillChange.send()
        }
    }
    
    func onEnded(data: DragGesture.Value) {
        state = .end(data)
        self.objectWillChange.send()
        state = .blank
    }
    
}
