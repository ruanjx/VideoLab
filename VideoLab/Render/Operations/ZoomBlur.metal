//
//  ZoomBlur.metal
//  VideoLab
//
//  Created by Bear on 2020/8/31.
//  Copyright © 2020 Chocolate. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "OperationShaderTypes.h"

fragment half4 zoomBlurFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<half> inputTexture [[texture(0)]],
                                constant float& size [[ buffer(1) ]],
                                constant float2& center [[ buffer(2) ]])
{
    float2 samplingOffset = 1.0/100.0 * (center - fragmentInput.textureCoordinate) * size;
    
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate) * 0.18;
    
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + (4.0h * samplingOffset)) * 0.05h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - samplingOffset) * 0.15h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (2.0h * samplingOffset)) *  0.12h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (3.0h * samplingOffset)) * 0.09h;
    color += inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - (4.0h * samplingOffset)) * 0.05h;

    return color;
}


