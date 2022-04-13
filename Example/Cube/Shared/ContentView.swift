//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 12.04.2022.
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
        }.gesture(DragGesture()
            .onChanged { data in
                viewModel.onDrag(translation: data.translation)
            }
            .onEnded { data in
                viewModel.onEnd(translation: data.translation)
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}

