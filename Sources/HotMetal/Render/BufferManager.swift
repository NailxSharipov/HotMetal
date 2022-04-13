//
//  BufferManager.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Metal

final class BufferManager {

    private let buffers: [MTLBuffer]
    private var index: Int

    init(device: MTLDevice, length: Int, size: Int) {
        var buffers = [MTLBuffer]()
        buffers.reserveCapacity(size)
        for _ in 0..<size {
            let buffer = device.makeBuffer(length: length, options: [])!
            buffers.append(buffer)
        }
        index = buffers.count - 1
        self.buffers = buffers
    }
    
    func getNext(device: MTLDevice) -> MTLBuffer {
        assert(Thread.isMainThread)
        index = (index + 1) % buffers.count
        return buffers[index]
    }

}
