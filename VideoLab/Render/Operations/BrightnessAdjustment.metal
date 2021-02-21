//
//  BrightnessAdjustment.metal
//  VideoLab
//
//  Created by Bear on 2020/8/21.
//  Copyright © 2020 Chocolate. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "OperationShaderTypes.h"

fragment half4 brightnessFragment(PassthroughVertexIO fragmentInput [[stage_in]],
                                  half4 sourceColor [[color(0)]],
                                  constant float& brightness [[ buffer(1) ]])
{
    return half4(sourceColor.rgb + brightness, sourceColor.a);
}
