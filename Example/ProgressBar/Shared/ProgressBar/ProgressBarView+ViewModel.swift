//
//  ProgressBarView+ViewModel.swift
//  ProgressBar
//
//  Created by Nail Sharipov on 17.05.2022.
//

import SwiftUI
import HotMetal

extension ProgressBarView {
    
    final class ViewModel: ObservableObject {

        func set(progress: CGFloat) {
            scene?.set(progress: progress)
        }

        func set(first: Line) {
            scene?.set(first: first)
        }
        
        func set(second: Line) {
            scene?.set(second: second)
        }
        
        func set(animationSpeed: CGFloat) {
            scene?.set(animationSpeed: animationSpeed)
        }
        
        let render = Render()
        private var scene: ProgressBarScene?
        
        
        init() {
            self.render?.onAttachScene = { [weak self] render, _ in
                guard let self = self else { return nil }
                let scene = ProgressBarScene(render: render)
                self.scene = scene
                return scene
            }
        }
    }
}
