//
//  Material+Library.swift
//  HotMetal
//
//  Created by Nail Sharipov on 13.04.2022.
//

import Metal

public extension Material {

    final class Library {

        public enum Resource {
            case framework(String)
            case local(String)
        }
        
        public enum Category: Int {
            case solid
            case color
            case texture
        }

        weak var render: Render?
        
        private var nextId: UInt = 0
        private var store: [UInt: Material] = [:]
        private let framework: MTLLibrary
        private let local: MTLLibrary?

        init(device: MTLDevice) {
            guard let framework = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
                fatalError("Framework library is not found!")
            }
            self.framework = framework
            self.local = device.makeDefaultLibrary()
        }
    }
}

public extension Material.Library {
    
    func load(_ resource: Resource) -> MTLFunction? {
        switch resource {
        case .framework(let name):
            return framework.makeFunction(name: name)
        case .local(let name):
            return local?.makeFunction(name: name)
        }
    }
    
    func get(id: UInt) -> Material? {
        store[id]
    }
    
    func register(category: Category, blendMode: Material.BlendMode) -> Material? {
        guard let render = self.render else { return nil }
        let id = nextId
        nextId += 1
        let pipelineState: MTLRenderPipelineState?
        
        switch category {
        case .solid:
            pipelineState = Material.solid(render: render, blendMode: blendMode)
        case .color:
            pipelineState = Material.color(render: render, blendMode: blendMode)
        case .texture:
            pipelineState = Material.texture(render: render, blendMode: blendMode)
        }

        guard let state = pipelineState else {
            return nil
        }
        
        let material = Material(id: id, state: state)
        
        store[id] = material
        
        return material
    }
    
    func register(state: MTLRenderPipelineState) -> Material {
        let id = nextId
        nextId += 1

        let material = Material(id: id, state: state)
        
        store[id] = material
        
        return material
    }
}
