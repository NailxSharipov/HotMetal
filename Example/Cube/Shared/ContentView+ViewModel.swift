//
//  ContentView+ViewModel.swift
//  Cube
//
//  Created by Nail Sharipov on 12.04.2022.
//

import SwiftUI
import HotMetal

extension ContentView {
    
    final class ViewModel: ObservableObject {
        
        @Published var render: Render?
        
        func onAppear() {
            self.render = Render() { render in
                render.scene = CubeScene(render: render)
            }
        }
    }
}
