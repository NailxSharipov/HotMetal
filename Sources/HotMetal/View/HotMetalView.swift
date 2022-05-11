//
//  HotMetalView.swift
//  
//
//  Created by Nail Sharipov on 11.04.2022.
//

import SwiftUI
import MetalKit

#if os(iOS)
public struct HotMetalView: UIViewRepresentable {
    
    public typealias UIViewType = MTKView
    private var render: Render?
    
    public init(render: Render?) {
        self.render = render
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: UIViewRepresentableContext<HotMetalView>) -> MTKView {
        let view = MTKView()
        view.drawableSize = view.bounds.size
        return view
    }
    
    public func updateUIView(_ view: MTKView, context: UIViewRepresentableContext<HotMetalView>) {
        if let render = self.render {
            render.attach(view: view)
        }
    }

}
#elseif os(macOS)
public struct HotMetalView: NSViewRepresentable {
    
    private var render: Render?
    
    public init(render: Render?) {
        self.render = render
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeNSView(context: NSViewRepresentableContext<HotMetalView>) -> MTKView {
        let view = MTKView()
        view.drawableSize = view.bounds.size
        return view
    }
    
    public func updateNSView(_ view: MTKView, context: NSViewRepresentableContext<HotMetalView>) {
        if let render = self.render {
            render.attach(view: view)
        }
    }
}
#endif

public final class Coordinator {

    let parent: HotMetalView
    
    init(_ parent: HotMetalView) {
        self.parent = parent
    }
}

extension MTKView {
    var scale: CGFloat {
#if os(iOS)
        self.window?.screen.scale ?? 1
#elseif os(macOS)
        self.window?.screen?.backingScaleFactor ?? 1
#else
        return 1
#endif
    }
}
