//
//  ContentView+ViewModel.swift
//  FullScreenImage
//
//  Created by Nail Sharipov on 11.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var render: Render?
        
        func onAppear() {
            self.render = Render() { render in
                let scene = ImageScene()
                let image = CGImage.load(name: "TwoSea")
                scene.set(render: render, image: image)
                render.scene = scene
            }
        }
    }
}

private extension CGImage {
    
    static func load(name: String) -> CGImage {
#if os(iOS)
        return UIImage(named: name)!.cgImage!
#elseif os(macOS)
        return NSImage(named: name)!.cgImage(forProposedRect: nil, context: nil, hints: nil)!
#endif
    }

}
