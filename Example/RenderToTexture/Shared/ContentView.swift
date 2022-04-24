//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 15.04.2022.
//

import SwiftUI
import HotMetal

struct ContentView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            HotMetalView(render: viewModel.render)
            VStack {
                HStack {
                    Slider(
                        value: $viewModel.front,
                        in: 0...1
                    ).accentColor(Color.red)
                    Slider(
                        value: $viewModel.rear,
                        in: 0...1
                    ).accentColor(Color.green)
                    Slider(
                        value: $viewModel.glow,
                        in: 0...0.2
                    ).accentColor(Color.blue)
                }
                Button("Save") {
                    viewModel.save()
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}
