//
//  LookupFilter.swift
//  VideoLab
//
//  Created by Bear on 2020/8/10.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Foundation

public class LookupFilter: BasicOperation {
    public var intensity: Float = 1.0 {
        didSet {
            uniformSettings["intensity"] = intensity
        }
    }

    public init() {
        super.init(fragmentFunctionName: "lookupFragment", numberOfInputs: 1)
        
        ({ intensity = 1.0 })()
    }
}
