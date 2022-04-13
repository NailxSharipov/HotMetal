//
//  MaterialLibrary.swift
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

        unowned var render: Render!
        
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
    
    func load(_ resource: Resource) -> MTLFunction {
        switch resource {
        case .framework(let name):
            return framework.makeFunction(name: name)!
        case .local(let name):
            return local!.makeFunction(name: name)!
        }
    }
    
    func get(id: UInt) -> Material? {
        store[id]
    }
    
    func register(category: Category, blendMode: Material.BlendMode) -> Material {
        let id = nextId
        nextId += 1
        let state: MTLRenderPipelineState
        
        switch category {
        case .solid:
            state = Material.solid(render: render, blendMode: blendMode)
        case .color:
            state = Material.color(render: render, blendMode: blendMode)
        case .texture:
            state = Material.texture(render: render, blendMode: blendMode)
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
