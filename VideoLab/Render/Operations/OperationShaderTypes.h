//
//  OperationShaderTypes.h
//  Pods
//
//  Created by Bear on 2020/8/21.
//  Copyright © 2020 Chocolate. All rights reserved.
//

#ifndef OperationShaderTypes_h
#define OperationShaderTypes_h

// It may be a bug in Xcode, maybe it will be fixed later
// If you do not add this line, #include <metal_stdlib> will have an error
// https://github.com/CocoaPods/CocoaPods/issues/7073
#if __METAL_MACOS__ || __METAL_IOS__

#include <metal_stdlib>
using namespace metal;

struct PassthroughVertexIO
{
    float4 position [[position]];
};

struct SingleInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
};

struct TwoInputVertexIO
{
    float4 position [[position]];
    float2 textureCoordinate [[user(texturecoord)]];
    float2 textureCoordinate2 [[user(texturecoord2)]];
};

#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#endif /* OperationShaderTypes_h */
