//
//  BrightnessAdjustment.swift
//  VideoLab
//
//  Created by Bear on 2020/8/21.
//  Copyright © 2020 Chocolate. All rights reserved.
//

public class BrightnessAdjustment: BasicOperation {
    public var brightness:Float = 0.0 {
        didSet {
            uniformSettings["brightness"] = brightness
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "brightnessFragment", numberOfInputs: 0)
        
        ({ brightness = 0.0 })()
    }
}
