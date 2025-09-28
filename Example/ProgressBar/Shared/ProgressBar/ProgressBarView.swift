//
//  ProgressBar+View.swift
//  ProgressBar
//
//  Created by Nail Sharipov on 17.05.2022.
//

import SwiftUI
import HotMetal

public struct ProgressBarView: View {
    
    public struct Line {
        let color: Color
        let width: CGFloat
    }
    
    @StateObject
    private var viewModel = ViewModel()

    @State
    public var progress: CGFloat = 0 {
        didSet {
            viewModel.set(progress: progress)
        }
    }
    
    @State
    public var first: Line = .init(color: .red, width: 5) {
        didSet {
            viewModel.set(progress: progress)
        }
    }

    @State
    public var second: Line = .init(color: .yellow, width: 5) {
        didSet {
            viewModel.set(progress: progress)
        }
    }
    
    @State
    public var animationSpeed: CGFloat = 1 {
        didSet {
            viewModel.set(animationSpeed: animationSpeed)
        }
    }
    
    public var body: some View {
        HotMetalView(render: viewModel.render).onAppear() { [weak viewModel] in
            guard let viewModel = viewModel else { return }
            viewModel.set(progress: progress)
            viewModel.set(first: first)
            viewModel.set(second: second)
            viewModel.set(animationSpeed: animationSpeed)
        }
    }
}
