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

    struct Shape {
        let points: [CGPoint]
        let color: Color
        let lineWidth: CGFloat
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

    init(viewPortState: ViewPortState) {
        self.viewPortState = viewPortState
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
            if let world = viewModel.world {
                Path { path in
                    path.addLines(world.points)
                    path.closeSubpath()
                }
                .stroke(lineWidth: world.lineWidth)
                .foregroundColor(world.color)
            }
            if let view = viewModel.view {
                Path { path in
                    path.addLines(view.points)
                    path.closeSubpath()
                }
                .stroke(lineWidth: view.lineWidth)
                .foregroundColor(view.color)
            }
            if let camera = viewModel.camera {
                Path { path in
                    path.addLines(camera.points)
                    path.closeSubpath()
                }
                .stroke(lineWidth: camera.lineWidth)
                .foregroundColor(camera.color)
            }
        }.onAppear() {
            viewModel.onAppear(viewPortState: viewPortState)
        }
    }
    
}
