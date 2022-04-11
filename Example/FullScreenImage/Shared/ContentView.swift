//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 11.04.2022.
//

import SwiftUI
import HotMetal

struct ContentView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Color.yellow
            HotMetalView(render: viewModel.render)
                .onAppear() {
                    viewModel.onAppear()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}
