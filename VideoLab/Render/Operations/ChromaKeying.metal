//
//  ChromaKeying.metal
//  VideoLab
//
//  Created by Bear on 2020/8/13.
//  Copyright © 2020 Chocolate. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "OperationShaderTypes.h"

fragment half4 ChromaKeyFragment(PassthroughVertexIO fragmentInput [[stage_in]],
                                 half4 sourceColor [[color(0)]],
                                 constant float& thresholdSensitivity [[ buffer(1) ]],
                                 constant float& smoothing [[ buffer(2) ]],
                                 constant float4& colorToReplace [[ buffer(3) ]])
{

    half maskY = 0.2989h * colorToReplace.r + 0.5866h * colorToReplace.g + 0.1145h * colorToReplace.b;
    half maskCr = 0.7132h * (colorToReplace.r - maskY);
    half maskCb = 0.5647h * (colorToReplace.b - maskY);
    
    half Y = 0.2989h * sourceColor.r + 0.5866h * sourceColor.g + 0.1145h * sourceColor.b;
    half Cr = 0.7132h * (sourceColor.r - Y);
    half Cb = 0.5647h * (sourceColor.b - Y);
    
    half blendValue = smoothstep(half(thresholdSensitivity),
                                 half(thresholdSensitivity + smoothing),
                                 distance(half2(Cr, Cb), half2(maskCr, maskCb)));
    
    return half4(sourceColor.rgb * blendValue, sourceColor.a * blendValue);
}

