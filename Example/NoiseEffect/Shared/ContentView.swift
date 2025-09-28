//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 12.05.2022.
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
                        value: $viewModel.size,
                        in: 10...100
                    ).accentColor(Color.red)
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
