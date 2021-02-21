//
//  Passthrough.swift
//  VideoLab
//
//  Created by Bear on 2020/8/12.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import Foundation

public class Passthrough: BasicOperation {
    public init () {
        super.init(fragmentFunctionName: "oneInputPassthroughFragment", numberOfInputs: 1)
        enableOutputTextureRead = false
    }
}

