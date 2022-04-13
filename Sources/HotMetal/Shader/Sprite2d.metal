//
//  Shaders.metal
//  FullScreenImage
//
//  Created by Nail Sharipov on 11.04.2022.
//
/*
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 tex [[attribute(1)]];
};

struct VertexOut {
    vector_float4 position [[position]];
    float2 tex;
};

struct FragmentOut {
    float4 color0 [[color(0)]];
};

vertex VertexOut vertexSprite2d(const VertexIn vIn [[stage_in]]) {
    VertexOut vOut;
    
    float2 p = vIn.position;
    vOut.position = float4(p.x, p.y, 0, 1);
    vOut.tex = vIn.tex;
    
    return vOut;
}

fragment FragmentOut fragmentSprite2d(
                                    VertexOut interpolated [[stage_in]],
                                    texture2d<float, access::sample> diffuseTexture [[texture(0)]],
                                    sampler diffuseSampler [[sampler(0)]])
{
    FragmentOut out;
    out.color0 = diffuseTexture.sample(diffuseSampler, interpolated.tex).rgba;
        
    return out;
}

*/
