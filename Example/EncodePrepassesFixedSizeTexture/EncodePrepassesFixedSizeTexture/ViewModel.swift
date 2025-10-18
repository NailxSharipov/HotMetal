//
//  ViewModel.swift
//  EncodePrepassesFixedSizeTexture
//
//  Created by Nail Sharipov on 29.09.2025.
//

import SwiftUI
import HotMetal
import Combine

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        let render: Render?
        
        init() {
            self.render = Render()
            self.render?.onAttachScene = { render, size in
                MainScene(render: render, drawableSize: size)
            }
        }
    }
}
