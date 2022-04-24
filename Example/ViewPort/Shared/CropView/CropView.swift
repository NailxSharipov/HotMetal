//
//  CropView.swift
//  ViewPort
//
//  Created by Nail Sharipov on 21.04.2022.
//

import SwiftUI

struct CropView: View {

    struct Background {
        let areas: [CGRect]
        let color: Color
    }
    
    struct Net {
        struct Line {
            let a: CGPoint
            let b: CGPoint
        }
        let lines: [Line]
        let color: Color
        let lineWidth: CGFloat
    }
    
    struct Border {
        let rect: CGRect
        let color: Color
        let lineWidth: CGFloat
    }
    
    struct ViewCorners {
        struct Corner {
            let a: CGPoint
            let b: CGPoint
            let c: CGPoint
        }
        let corners: [Corner]
        let color: Color
        let lineWidth: CGFloat
    }

    @StateObject
    private var viewModel = ViewModel()
    
    private let viewPortState: ViewPortState
    private let viewSizeState: ViewSizeState
    private let dragGestureState: DragGestureState

    init(
        viewPortState: ViewPortState,
        viewSizeState: ViewSizeState,
        dragGestureState: DragGestureState
    ) {
        self.viewPortState = viewPortState
        self.viewSizeState = viewSizeState
        self.dragGestureState = dragGestureState
    }
    
    var body: some View {
        ZStack {
            if let background = viewModel.background {
                Path { path in
                    for rect in background.areas {
                        path.addRect(rect)
                    }
                }
                .fill(background.color)
            }

            if let net = viewModel.net {
                Path { path in
                    for line in net.lines {
                        path.move(to: line.a)
                        path.addLine(to: line.b)
                    }
                }
                .stroke(lineWidth: net.lineWidth)
                .foregroundColor(net.color)
            }
            
            if let border = viewModel.border {
                Path { path in
                    path.addRect(border.rect)
                }
                .stroke(lineWidth: border.lineWidth)
                .foregroundColor(border.color)
            }
            
            if let viewCorners = viewModel.viewCorners {
                Path { path in
                    for corner in viewCorners.corners {
                        path.move(to: corner.a)
                        path.addLine(to: corner.b)
                        path.addLine(to: corner.c)
                    }
                }
                .stroke(lineWidth: viewCorners.lineWidth)
                .foregroundColor(viewCorners.color)
            }
        }.onAppear() {
            viewModel.onAppear(viewPortState: viewPortState, viewSizeState: viewSizeState, dragGestureState: dragGestureState)
        }
    }
    
}
