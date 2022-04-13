//
//  Quaternion.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//


import simd

public typealias Quaternion = simd_quatf

extension Quaternion {
    
    public static let identity = simd_quatf(angle: 0, axis: [1, 0, 0])

}
