//
//  BlendOperation.metal
//  VideoLab
//
//  Created by Bear on 2020/8/5.
//  Copyright © 2020 Chocolate. All rights reserved.
//

#include <metal_stdlib>
#include "OperationShaderTypes.h"
#include "BlendModeConstants.h"

using namespace metal;

vertex SingleInputVertexIO blendOperationVertex(const device packed_float2 *position [[ buffer(0) ]],
                                                const device packed_float2 *texturecoord [[ buffer(1) ]],
                                                constant float4x4& modelView [[ buffer(2) ]],
                                                constant float4x4& projection [[ buffer(3) ]],
                                                uint vid [[vertex_id]])
{
    SingleInputVertexIO outputVertices;
    
    outputVertices.position = projection * modelView * float4(position[vid], 0, 1.0);
    outputVertices.textureCoordinate = texturecoord[vid];
    
    return outputVertices;
}

half4 normalBlend(half3 Sca, half3 Dca, half Sa, half Da) {
    half4 blendColor;
    blendColor.rgb = Sca + Dca * (1.0 - Sa);
    blendColor.a = Sa + Da - Sa * Da;
    return blendColor;
}

half4 darken(half3 Sca, half3 Dca, half Sa, half Da) {
    half4 blendColor;
    blendColor.rgb = min(Sca * Da, Dca * Sa) + Sca * (1.0 - Da) + Dca * (1.0 - Sa);
    blendColor.a = Sa + Da - Sa * Da;
    return blendColor;
}

half4 multiply(half3 Sca, half3 Dca, half Sa, half Da) {
    half4 blendColor;
    blendColor.rgb = Sca * Dca + Sca * (1.0 - Da) + Dca * (1.0 - Sa);
    blendColor.a = Sa + Da - Sa * Da;
    return blendColor;
}

fragment half4 blendOperationFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<half> inputTexture [[texture(0)]],
                                      half4 backColor [[color(0)]],
                                      constant int& blendMode [[ buffer(1) ]],
                                      constant float& blendOpacity [[ buffer(2) ]])
{
    constexpr sampler quadSampler;
    half4 sourceColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    
    half3 Sca = sourceColor.rgb;
    half3 Dca = backColor.rgb;
    half Sa = sourceColor.a;
    half Da = backColor.a;
    
    half4 blendColor;
    if (blendMode == BlendModeNormal) {
        blendColor = normalBlend(Sca, Dca, Sa, Da);
    } else if (blendMode == BlendModeDarken) {
        blendColor = darken(Sca, Dca, Sa, Da);
    } else if (blendMode == BlendModeMultiply) {
        blendColor = multiply(Sca, Dca, Sa, Da);
    } else {
        blendColor = half4(0.0, 0.0, 0.0, 1.0);
    }

    return mix(backColor, blendColor, blendOpacity);
}
