//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI
import HotMetal

struct ContentView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            content(size: proxy.size)
        }.gesture(DragGesture()
            .onChanged { data in
                viewModel.dragGestureState.onChanged(data: data)
                
            }
            .onEnded { data in
                viewModel.dragGestureState.onEnded(data: data)
            }
        )
    }
    
    private func content(size: CGSize) -> some View {
        viewModel.viewSizeState.onWillChange(size: size)
        return ZStack {
            HotMetalView(render: viewModel.render)
            CropView(
                viewPortState: viewModel.viewPortState,
                viewSizeState: viewModel.viewSizeState,
                dragGestureState: viewModel.dragGestureState
            )
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}
