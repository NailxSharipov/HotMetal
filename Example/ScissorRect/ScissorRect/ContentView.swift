//
//  ContentView.swift
//  ScissorRect
//
//  Created by Nail Sharipov on 29.09.2025.
//

import SwiftUI
import HotMetal

struct ContentView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        HotMetalView(render: viewModel.render)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.black)
    }
}
