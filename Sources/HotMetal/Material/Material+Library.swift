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
            case sprite
        }

        unowned var render: Render!
        
        private var customIndexId: Int = 100
        private var store: [Int: Material] = [:]
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
    
    func get(id: Int) -> Material? {
        if let material = store[id] {
            return material
        }

        guard let category = Category(rawValue: id) else {
            return nil
        }
        
        return self.get(category: category)
    }
    
    func get(category: Category) -> Material {
        let id = category.rawValue
        if let stored = store[id] {
            return stored
        }
        
        let material: Material
        
        switch category {
        case .solid:
            material = Material.solid(render: render)
        case .color:
            material = Material.color(render: render)
        case .sprite:
            material = Material.sprite2d(render: render)
        }

        store[id] = material
        
        return material
    }
    
    func register(state: MTLRenderPipelineState) -> Material {
        let id = customIndexId
        customIndexId += 1

        let material = Material(id: id, state: state)
        
        store[id] = material
        
        return material
    }
}
