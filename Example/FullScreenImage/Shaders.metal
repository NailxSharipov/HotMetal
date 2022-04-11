//
//  Shaders.metal
//  FullScreenImage
//
//  Created by Nail Sharipov on 11.04.2022.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;


struct VertexIn {
  float2 position [[attribute(0)]];
};

struct VertexOut {
    vector_float4 position [[position]];
};

vertex VertexOut vertexShader(const VertexIn vIn [[stage_in]]) {
    VertexOut vOut;
    float2 p = vIn.position;
    vOut.position = float4(p.x, p.y, 0, 1);
    return vOut;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]) {
    return vector_float4(1, 0, 0, 1);
}


