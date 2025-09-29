//
//  BufferManager.swift
//  HotMetal
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal
import Foundation

public final class BufferManager {

    private var buffers: [MTLBuffer] = []
    private let device: MTLDevice
    private let length: Int

    init(device: MTLDevice, length: Int) {
        self.device = device
        self.length = length
    }
    
    public func getNext() -> MTLBuffer? {
        assert(Thread.isMainThread)
        guard !buffers.isEmpty else {
            let buffer = device.makeBuffer(length: length, options: [])
            return buffer
        }

        return buffers.removeLast()
    }

    public func release(buffer: MTLBuffer) {
        if Thread.isMainThread {
            buffers.append(buffer)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.buffers.append(buffer)
            }
        }
    }
    
}
