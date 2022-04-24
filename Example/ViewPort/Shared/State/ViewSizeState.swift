//
//  ViewSizeState.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI

final class ViewSizeState: ObservableObject {

    private (set) var viewSize: CGSize = .zero

    func onWillChange(size: CGSize) {
        if viewSize != size {
            viewSize = size
            self.objectWillChange.send()
        }
    }
    
}
