//
//  BlendOperation.swift
//  VideoLab
//
//  Created by Bear on 2020/8/5.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Foundation
import simd

public class BlendOperation: BasicOperation {
    public var modelView: float4x4 = float4x4.identity() {
        didSet {
            uniformSettings["modelView"] = modelView
        }
    }
    
    public var projection: float4x4 = float4x4.identity() {
        didSet {
            uniformSettings["projection"] = projection
        }
    }
    
    public var blendMode: BlendMode = BlendModeNormal {
        didSet {
            uniformSettings["blendMode"] = blendMode
        }
    }
    
    public var blendOpacity: Float = 1.0 {
        didSet {
            uniformSettings["blendOpacity"] = blendOpacity
        }
    }
    
    public init() {
        super.init(vertexFunctionName: "blendOperationVertex", fragmentFunctionName: "blendOperationFragment", numberOfInputs: 1)
        
        ({ blendMode = BlendModeNormal })()
        ({ blendOpacity = 1.0 })()
    }
}
