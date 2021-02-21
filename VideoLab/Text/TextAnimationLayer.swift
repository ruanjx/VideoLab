//
//  LettersAnimationLayer.swift
//  VideoLab
//
//  Created by Bear on 2020/8/11.
//  Copyright © 2020 Chocolate. All rights reserved.
//

import UIKit
import AVFoundation

public class TextAnimationLayer: CALayer, NSLayoutManagerDelegate {
    private let textStorage: NSTextStorage = NSTextStorage()
    private let layoutManager: NSLayoutManager = NSLayoutManager()
    private let textContainer: NSTextContainer = NSTextContainer()
    private var textSize: CGSize = CGSize.zero
    private var animationLayers: [CATextLayer] = []

    public var attributedText: NSAttributedString {
        get {
            return textStorage as NSAttributedString
        }
        set {
            textStorage.setAttributedString(newValue)
        }
    }
    
    public override var bounds: CGRect {
        get {
            super.bounds
        }
        set {
            textContainer.size = newValue.size
            super.bounds = newValue
        }
    }

    public override init() {
        super.init()
        setupTextkit()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        setupTextkit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    /// Add animations to the layers, subclasses need to override this method to customize animation
    /// - Parameter layers: Split letters or words corresponding layers
    func addAnimations(to layers: [CATextLayer]) {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 15.0
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.fillMode = .both
        animationGroup.isRemovedOnCompletion = false
        self.add(animationGroup, forKey: "animationGroup")
    }
    
    // MARK: - Private
    private func setupTextkit() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
        textContainer.size = CGSize.zero
    }

    private func updateAnimationLayers() {
        if textContainer.size.equalTo(CGSize.zero) || attributedText.length == 0 {
            return
        }

        // Remove old animation layers
        for layer in animationLayers {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
        self.removeAllAnimations()
        
        // Split letters or words to generate corresponding layers
        let string = attributedText.string
        string.enumerateSubstrings(in: string.startIndex..<string.endIndex, options: .byComposedCharacterSequences) { [weak self] (subString, substringRange, _, _) in
            guard let self = self else { return }
            
            let glyphRange = NSRange(substringRange, in: string)
            let textRect = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: self.textContainer)
            let textLayer = CATextLayer()
            textLayer.frame = textRect
            textLayer.string = self.attributedText.attributedSubstring(from: glyphRange)
            self.animationLayers.append(textLayer)
            self.addSublayer(textLayer)
        }
        
        // Add animations to the layers
        addAnimations(to: animationLayers)
    }
    
    // MARK: - NSLayoutManagerDelegate
    public func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if textContainer == nil {
            return
        }
        
        updateAnimationLayers()
    }
}
