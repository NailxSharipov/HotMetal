//
//  VarColor.metal
//  NoiseEffect
//
//  Created by Nail Sharipov on 12.05.2022.
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
    float4 color [[color(0)]];
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

struct VarData {
    float size;
};

vertex VertexOut vertexVarColor(
                               const VertexIn vIn [[ stage_in ]],
                               const device Uniforms& uniforms [[ buffer(0) ]],
                               const device ModelTransform& transform [[ buffer(1) ]]
                               ) {
    VertexOut vOut;
    vOut.position = uniforms.viewProjection * transform.modelMatrix * float4(vIn.position, 1.0);
    vOut.color = vIn.color;
    vOut.tex = vIn.tex;
    
    return vOut;
}

fragment FragmentOut fragmentVarColor(
                                      VertexOut interpolated [[stage_in]],
                                      texture2d<float, access::sample> diffuseTexture [[texture(0)]],
                                      sampler diffuseSampler [[sampler(0)]],
                                      const device VarData& varData [[ buffer(3) ]]
) {
    FragmentOut out;

    float ix = trunc(interpolated.tex.x * varData.size);
    float iy = trunc(interpolated.tex.y * varData.size);
           
    float dx = ix / varData.size;
    
    
    float x = ix / varData.size;
    float y = iy / varData.size;
    
    float4 tex = diffuseTexture.sample(diffuseSampler, float2(x, y)).rgba;

    out.color = tex;
        
    return out;
}


