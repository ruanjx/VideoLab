//
//  VLETimeLineStateModel.swift
//  VideoLab_Example
//
//  Created by Kay on 2022/9/23.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import Foundation
import UIKit
import VideoLab
import CoreMedia

class VLETimeLineStateModel {
    
    var renderSize: CGSize
    var totalSeconds: Float = 0
    var totalDuration: CMTime = CMTime.zero
    var currentSelectedItemModel: VLETimeLineItemModel?
    var currentSelectedIndex: Int?
    var isHaveRenderTrack: Bool {
        if renderTrackItemModelArray.isEmpty && separateRenderTrackItemModelArray.isEmpty{
            return false
        } else {
            return true
        }
    }
    private var _renderTrackItemModelArray: [VLETimeLineItemModel] = []
    private var _separateRenderTrackItemModelArray: [VLETimeLineItemModel] = []
    public var renderTrackItemModelArray: [VLETimeLineItemModel] {
        get {
            return _renderTrackItemModelArray
        }
        set {
            _renderTrackItemModelArray = newValue
            if _renderTrackItemModelArray.isEmpty && _separateRenderTrackItemModelArray.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsEmptyNotification), object: self)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsNonemptyNotification), object: self)
            }
        }
    }
    public var separateRenderTrackItemModelArray: [VLETimeLineItemModel] {
        get {
            return _separateRenderTrackItemModelArray
        }
        set {
            _separateRenderTrackItemModelArray = newValue
            if _renderTrackItemModelArray.isEmpty && _separateRenderTrackItemModelArray.isEmpty {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsEmptyNotification), object: self)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: VLEConstants.VLETimeLineAssetDidIsNonemptyNotification), object: self)
            }
        }
    }
    init() {
        self.renderSize = CGSize.init(width: 1280, height: 720)
    }

    public func fetchScaleSpaceWidth() -> CGFloat {
        return CGFloat.init(VLETimeLineConfig.framesPerSpace) * VLETimeLineConfig.ptPerFrames
    }
    
    public func fetchScaleViewWidth() -> CGFloat {
        return calculateScaleWidth()
    }

    public func fetchScaleFrontMargin() -> CGFloat {
        return VLETimeLineConfig.frontMargin
    }
    
    public func fetchScaleBackMargin() -> CGFloat {
        return VLETimeLineConfig.backMargin
    }

    private func calculateScaleWidth() -> CGFloat {
        return CGFloat.init(totalSeconds*VLETimeLineConfig.framesPerSecond) * VLETimeLineConfig.ptPerFrames
    }
    
    public func renderTrackItemModelConvertToSeparate(at selectIndex: Int, startTime: CMTime) {
        let selectedModel = renderTrackItemModelArray.remove(at: selectIndex)
        selectedModel.globalStartTime = startTime
        selectedModel.isSeparateRenderTrack = true
        selectedModel.renderLayer.timeRange.start = startTime
        let randomX = CGFloat.random(in: 0.25...0.75)
        let randomY = CGFloat.random(in: 0.25...0.75)
        let center = CGPoint(x: randomX, y: randomY)
        let transform = Transform(center: center, rotation: 0, scale: 0.5)
        selectedModel.renderLayer.transform = transform
        separateRenderTrackItemModelArray.append(selectedModel)
    }
    
    public func clipSeparateRenderTrackItemModelAtCurrentIndex(clipRate rate: Float, completion: @escaping (NSError?, VLETimeLineItemModel?) -> Void) {
        guard let itemModel = currentSelectedItemModel else {
            return
        }
        let selectedDuration = self.calculateSelectedTime(at: Float(rate), sourceTime: itemModel.source.selectedTimeRange.duration)
        let newItemModel = VLETimeLineItemModel.init(with: itemModel.source, type: itemModel.type)
        newItemModel.isSeparateRenderTrack = true
        newItemModel.source = itemModel.source.copy()
        newItemModel.source.load { error in
            if error == nil {
                newItemModel.globalStartTime = CMTimeAdd(itemModel.globalStartTime, selectedDuration)
                newItemModel.source.selectedTimeRange.start = CMTimeAdd(itemModel.source.selectedTimeRange.start, selectedDuration)
                newItemModel.source.selectedTimeRange.duration = CMTimeSubtract(itemModel.source.selectedTimeRange.duration, selectedDuration)
                newItemModel.renderLayer.timeRange = CMTimeRange.init(start: newItemModel.globalStartTime, duration: newItemModel.source.selectedTimeRange.duration)
                itemModel.source.selectedTimeRange.duration = selectedDuration
                newItemModel.generateThumbnails(with: 1) { _ in}
                self.separateRenderTrackItemModelArray.insert(newItemModel, at: self.currentSelectedIndex!+1)
                completion(nil, newItemModel)
            } else {
                completion(NSError.init(), nil)
            }
        }
    }

    public func calculateSelectedTime(at rate: Float, sourceTime: CMTime) -> CMTime{
        let value = sourceTime.value * Int64(rate * 100) / 100
        let timescale = sourceTime.timescale
        return CMTime.init(value: value, timescale: timescale)
    }

    public func clipRenderTrackItemModelAtCurrentIndex(clipRate rate: Float, completion: @escaping (NSError?) -> Void){
        guard let itemModel = currentSelectedItemModel else {
            return
        }
        let selectedDuration = calculateSelectedTime(at: Float(rate), sourceTime: itemModel.source.selectedTimeRange.duration)
        let newItemModel = VLETimeLineItemModel.init(with: itemModel.source, type: itemModel.type)
        newItemModel.isSeparateRenderTrack = false
        newItemModel.source = itemModel.source.copy()
        newItemModel.source.load { error in
            if error == nil {
                newItemModel.globalStartTime = CMTimeAdd(itemModel.globalStartTime, selectedDuration)
                newItemModel.source.selectedTimeRange.start = CMTimeAdd(itemModel.source.selectedTimeRange.start, selectedDuration)
                newItemModel.source.selectedTimeRange.duration = CMTimeSubtract(itemModel.source.selectedTimeRange.duration, selectedDuration)
                newItemModel.renderLayer.timeRange = CMTimeRange.init(start: newItemModel.globalStartTime, duration: newItemModel.source.selectedTimeRange.duration)
                itemModel.source.selectedTimeRange.duration = selectedDuration
                newItemModel.generateThumbnails(with: 1) { _ in}
                self.renderTrackItemModelArray.insert(newItemModel, at: self.currentSelectedIndex!+1)
                completion(nil)
            } else {
                completion(NSError.init())
            }
        }
    }

    public func refreshItemTime() {
        var sum: CMTime = CMTime.zero
        for item in renderTrackItemModelArray {
            item.globalStartTime = sum
            item.renderLayer.timeRange = CMTimeRange.init(start: sum, duration: item.source.selectedTimeRange.duration)
            sum = CMTimeAdd(sum, item.source.selectedTimeRange.duration)
        }
        for item in separateRenderTrackItemModelArray {
            let endTime = CMTimeAdd(item.globalStartTime, item.source.selectedTimeRange.duration)
            sum = CMTimeMaximum(sum, endTime)
        }
        self.totalDuration = sum
        self.totalSeconds = VLETimeLineConfig.convertToSecond(value: sum)
    }

    public func swapItemForRenderTrack(selectedIndex: Int, targetIndex: Int) {
        let selectedModel = renderTrackItemModelArray.remove(at: selectedIndex)
        renderTrackItemModelArray.insert(selectedModel, at: targetIndex)
    }
}
