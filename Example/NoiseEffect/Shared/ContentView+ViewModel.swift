//
//  ContentView+ViewModel.swift
//  NoiseEffect
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var size: CGFloat = 100 {
            didSet {
                scene?.size = Float(size)
            }
        }

        
        @Published var render: Render?
        private var scene: MainScene?
        private var isDrag: Bool = false
        
        @MainActor
        init() {
            self.render = Render()
            self.render?.onAttachScene = { [weak self] render, _ in
                guard let self = self else { return nil }
                let scene = MainScene(render: render)
                self.scene = scene
                return scene
            }
        }

    }
}


extension CGSize {
    
    var reverseY: CGSize {
        var size = self
        size.height = -size.height
        return size
    }
    
}
