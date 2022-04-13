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
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
    float2 tex [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 tex;
};

struct FragmentOut {
    float4 color0 [[color(0)]];
};

struct Uniforms {
    float time;
    float4x4 view;
    float4x4 inverseView;
    float4x4 viewProjection;
};

struct ModelTransform {
    float4x4 modelMatrix;
    float4x4 inverseModelMatrix;
};

vertex VertexOut vertexTexture(
                             const VertexIn vIn [[ stage_in ]],
                             const device Uniforms& uniforms [[ buffer(0) ]],
                             const device ModelTransform& transform [[ buffer(1) ]])
{
    VertexOut vOut;
    vOut.position = uniforms.viewProjection * transform.modelMatrix * float4(vIn.position, 1.0);
    vOut.color = vIn.color;
    vOut.tex = vIn.tex;
    
    return vOut;
}

fragment FragmentOut fragmentTexture(
                                    VertexOut interpolated [[stage_in]],
                                    texture2d<float, access::sample> diffuseTexture [[texture(0)]],
                                    sampler diffuseSampler [[sampler(0)]])
{
    FragmentOut out;
    float4 tex = diffuseTexture.sample(diffuseSampler, interpolated.tex).rgba;
    out.color0 = interpolated.color * tex;
        
    return out;
}
