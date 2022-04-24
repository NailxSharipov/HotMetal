//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 14.04.2022.
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
                        value: $viewModel.red,
                        in: 0...1
                    ).accentColor(Color.red)
                    Slider(
                        value: $viewModel.green,
                        in: 0...1
                    ).accentColor(Color.green)
                    Slider(
                        value: $viewModel.blue,
                        in: 0...1
                    ).accentColor(Color.blue)
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
