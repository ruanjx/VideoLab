#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

vertex TwoInputVertexIO yuvConversionVertex(const device packed_float2 *position [[buffer(0)]],
                                            const device packed_float2 *texturecoord [[buffer(1)]],
                                            const device packed_float2 *texturecoord2 [[buffer(2)]],
                                            constant float4x4& orientation [[ buffer(3) ]],
                                            uint vid [[vertex_id]])
{
    TwoInputVertexIO outputVertices;
    
    outputVertices.position = float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = (orientation * float4(texturecoord[vid], 0, 1.0)).xy;
    outputVertices.textureCoordinate2 = (orientation * float4(texturecoord2[vid], 0, 1.0)).xy;

    return outputVertices;
}

fragment half4 yuvConversionFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                     texture2d<half> inputTexture [[texture(0)]],
                                     texture2d<half> inputTexture2 [[texture(1)]],
                                     constant float4x4& colorConversionMatrix [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    half y = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r;
    half2 uv = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate).rg;
    half4 ycc = half4(y, uv, 1.0);
    half4 color = half4((half4x4(colorConversionMatrix) * ycc).rgb, 1.0);
    
    return clamp(color, 0.0, 1.0);
}
