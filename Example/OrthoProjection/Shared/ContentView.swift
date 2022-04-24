//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 23.04.2022.
//

import SwiftUI
import HotMetal

struct ContentView: View {
    
    private let button: CGSize = .init(width: 64, height: 64)
    
    @StateObject
    private var viewModel = ViewModel()
    
    private var onPress: (XYCamera.Anchor) -> () {{ anchor in
        self.viewModel.anchor = anchor
    }}
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HotMetalView(render: viewModel.render)
                    .gesture(DragGesture()
                    .onChanged { data in
                        print(data.translation.width)
                        viewModel.onDrag(translation: data.translation)
                    }
                    .onEnded { data in
                        viewModel.onEnd(translation: data.translation)
                    })
                    VStack {
                        HStack {
                            Spacer()
                            CameraButton(anchor: .leftTop, isActive: viewModel.anchor == .leftTop, onPress: onPress)
                                .frame(width: button.width, height: button.height)
                            CameraButton(anchor: .rightTop, isActive: viewModel.anchor == .rightTop, onPress: onPress)
                                .frame(width: button.width, height: button.height)
                            CameraButton(anchor: .center, isActive: viewModel.anchor == .center, onPress: onPress)
                                .frame(width: button.width, height: button.height)
                            CameraButton(anchor: .leftBottom, isActive: viewModel.anchor == .leftBottom, onPress: onPress)
                                .frame(width: button.width, height: button.height)
                            CameraButton(anchor: .rightBottom, isActive: viewModel.anchor == .rightBottom, onPress: onPress)
                                .frame(width: button.width, height: button.height)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Slider(
                                value: $viewModel.angle,
                                in: -0.5 * Float.pi...0.5 * Float.pi
                            ).frame(width: proxy.size.width * 0.5)
                            Spacer()
                        }
                    }
                }
            }
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().background(.brown)
    }
}
