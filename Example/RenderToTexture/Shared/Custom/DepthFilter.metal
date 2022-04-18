//
//  DepthFilter.metal
//  RenderToTexture
//
//  Created by Nail Sharipov on 15.04.2022.
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

struct VarData {
    float3 value;
};

vertex VertexOut vertexDepthFilter(
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

fragment FragmentOut fragmentDepthFilter(
                                         VertexOut interpolated [[stage_in]],
                                         texture2d<float, access::sample> mainTexture [[texture(0)]],
                                         sampler mainSampler [[sampler(0)]],
                                         texture2d<float, access::sample> depthTexture [[texture(1)]],
                                         sampler depthSampler [[sampler(1)]],
                                         const device VarData& varData [[ buffer(3) ]]
) {
    

    float4 depthTex = depthTexture.sample(depthSampler, interpolated.tex).rgba;
    
    float x = depthTex.r;
    float a = varData.value.x;
    float b = varData.value.y;
    float r = varData.value.z;

    float a0 = a - r;
    float b0 = b + r;

    FragmentOut out;
    
    if (a0 < x || x < b0) {
        float k = 1;
        if (a > x) {
            float dx = (a - x) / r;
            k = 1 - dx * dx * dx;
            
        } else if (b < x) {
            float dx = (x - b) / r;
            k = 1 - dx * dx * dx;
        }
        float4 mainTex = mainTexture.sample(mainSampler, interpolated.tex).rgba;
        out.color0 = k * mainTex;
    } else {
        out.color0 = float4(0, 0, 0, 0);
    }
    
    return out;
}
