//
//  ChromaKeying.swift
//  VideoLab
//
//  Created by Bear on 2020/8/13.
//  Copyright © 2020 Chocolate. All rights reserved.
//

public class ChromaKeying: BasicOperation {
    public var thresholdSensitivity: Float = 0.4 {
        didSet {
            uniformSettings["thresholdSensitivity"] = thresholdSensitivity
        }
    }
    
    public var smoothing: Float = 0.1 {
        didSet {
            uniformSettings["smoothing"] = smoothing
        }
    }
    
    public var colorToReplace: Color = Color.green {
        didSet {
            uniformSettings["colorToReplace"] = colorToReplace
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "ChromaKeyFragment", numberOfInputs: 0)
        
        ({ thresholdSensitivity = 0.4 })()
        ({ smoothing = 0.1 })()
        ({ colorToReplace = Color.green })()
    }
}
