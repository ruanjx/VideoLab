//
//  YUVToRGBConversion.swift
//  VideoLab
//
//  Created by Bear on 2020/8/23.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import simd

public class YUVToRGBConversion: BasicOperation {
    // BT.601, which is the standard for SDTV.
    public static let colorConversionMatrixVideoRange = float4x4(
        [1.164384, 1.164384, 1.164384, 0.000000],
        [0.000000, -0.213249, 2.111719, 0.000000],
        [1.792741, -0.532909, 0.000000, 0.000000],
        [-0.973015, 0.301512, -1.133142, 1.000000]
    )

    public static let colorConversionMatrixFullRange = float4x4(
        [1.000000, 1.000000, 1.000000, 0.000000],
        [0.000000, -0.187324, 1.855000, 0.000000],
        [1.574800, -0.468124, 0.000000, 0.000000],
        [-0.790550, 0.329035, -0.931210, 1.000000]
    )

    public var colorConversionMatrix: float4x4 = YUVToRGBConversion.colorConversionMatrixVideoRange {
        didSet {
            uniformSettings["colorConversionMatrix"] = colorConversionMatrix
        }
    }
    
    public var orientation: float4x4 = float4x4.identity() {
        didSet {
            uniformSettings["orientation"] = orientation
        }
    }
    
    public init () {
        super.init(vertexFunctionName: "yuvConversionVertex", fragmentFunctionName: "yuvConversionFragment", numberOfInputs: 2)
        enableOutputTextureRead = false
        
        ({ colorConversionMatrix = YUVToRGBConversion.colorConversionMatrixVideoRange })()
    }
}
