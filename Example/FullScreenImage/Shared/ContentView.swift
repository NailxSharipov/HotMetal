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
//MetalView(image: UIImage(named: "Tailand")!.cgImage!)
//#elseif os(macOS)
//struct ContentView: View {
//    var body: some View {
//        ZStack {
//            Color.yellow
//            MetalView(image: NSImage(named: "Tailand")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
//        }
//    }
//}
//#endif


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}
