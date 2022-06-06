//
//  VLEDemoViewController.swift
//  VideoLab_Example
//
//  Created by codeyuan on 2022/6/6.
//  Copyright © 2022 Chocolate. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import VideoLab

class VLEDemoViewController : UITableViewController{
    var lutTextures: [Texture] = []
    var animationLayer: CALayer?
    let cellIdentifierStr = "VLEFeaturesCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lutTextures = makeLutTextures()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoLab: VideoLab = {
            if indexPath.row == 1 {
                return multiLayerDemo()
            } else if indexPath.row == 2 {
                return audioVolumeRampDemo()
            } else if indexPath.row == 3 {
                return textAnimationDemo()
            } else if indexPath.row == 4 {
                return keyframeAnimationDemo()
            } else if indexPath.row == 5 {
                return layerGroupDemo()
            } else if indexPath.row == 6 {
                return transition2Demo()
            }
            
            return simpleDemo()
        }()
        
        let playerItem = videoLab.makePlayerItem()
        playerItem.seekingWaitsForVideoCompositionRendering = true
        let controller = VLEPlayerViewController(videoLab: videoLab)
        controller.player = AVPlayer(playerItem: playerItem)
        
        if let synchronizedLayer = makeSynchronizedLayer(playerItem: playerItem, videoLab: videoLab) {
            controller.view.layer.addSublayer(synchronizedLayer)
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifierStr)
        if cell == nil{
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifierStr)
        }
        
        let cellTextLabel: String = {
            if indexPath.row == 0 {
                return "Simple Demo"
            } else if indexPath.row == 1 {
                return "Mutil Layer Demo"
            } else if indexPath.row == 2 {
                return "Audio Volume Ramp Demo"
            } else if indexPath.row == 3 {
                return "Text Animation Demo"
            } else if indexPath.row == 4 {
                return "Keyframe Animation Demo"
            } else if indexPath.row == 5 {
                return "Layer Group Demo"
            } else if indexPath.row == 6 {
                return "Transition Demo"
            } else {
                return "Simple Demo"
            }
        }()
        
        cell!.textLabel?.text = cellTextLabel
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    // MARK: - Demo
    func simpleDemo() -> VideoLab {
        // 1. Layer 1
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 1. Layer 2
        url = Bundle.main.url(forResource: "video2", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        timeRange.start = CMTimeRangeGetEnd(renderLayer1.timeRange)
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1, renderLayer2]

        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }

    func multiLayerDemo() -> VideoLab {
        // 1. Layer 1
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        var center = CGPoint(x: 0.25, y: 0.25)
        var transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLayer1.transform = transform
        
        // 1. Layer 2
        let image = UIImage(named: "image1.JPG")
        let imageSource = ImageSource(cgImage: image?.cgImage)
        imageSource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 15, preferredTimescale: 600))
        timeRange = imageSource.selectedTimeRange
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: imageSource)

        var filter = LookupFilter()
        filter.addTexture(lutTextures[0], at: 0)
        renderLayer2.operations = [filter]

        center = CGPoint(x: 0.75, y: 0.25)
        transform = Transform(center: center, rotation: 0, scale: 1.0 / 8)
        renderLayer2.transform = transform
        
        // 1. Layer 3
        url = Bundle.main.url(forResource: "video3", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        let renderLayer3 = RenderLayer(timeRange: timeRange, source: source)
        
        filter = LookupFilter()
        filter.addTexture(lutTextures[1], at: 0)
        renderLayer3.operations = [filter]

        center = CGPoint(x: 0.25, y: 0.75)
        transform = Transform(center: center, rotation: 0, scale: 1/3.0)
        renderLayer3.transform = transform
        
        // 1. Layer 4
        url = Bundle.main.url(forResource: "video4", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        let renderLayer4 = RenderLayer(timeRange: timeRange, source: source)
        
        filter = LookupFilter()
        filter.addTexture(lutTextures[3], at: 0)
        renderLayer4.operations = [filter]

        center = CGPoint(x: 0.75, y: 0.75)
        transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLayer4.transform = transform
        
        // 1. Operation Layer 5
        let renderLayer5 = RenderLayer(timeRange: timeRange)
        let operation = BrightnessAdjustment()
        operation.brightness = 0.5
        renderLayer5.operations = [operation]

        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1, renderLayer2, renderLayer3, renderLayer4]
        composition.backgroundColor = Color(red: 0, green: 0, blue: 0)
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func audioVolumeRampDemo() -> VideoLab {
        // 1. Layer 1
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 1. Layer 1 audio configuration
        var audioConfiguration = AudioConfiguration()
        var volumeRampTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 3, preferredTimescale: 600))
        var volumeRamp1 = VolumeRamp(startVolume: 0.0, endVolume: 1.0, timeRange: volumeRampTimeRange)
        volumeRampTimeRange = CMTimeRange(start: CMTimeRangeGetEnd(volumeRampTimeRange), duration: CMTime(seconds: 5, preferredTimescale: 600))
        let volumeRamp2 = VolumeRamp(startVolume: 0.0, endVolume: 0.5, timeRange: volumeRampTimeRange)
        audioConfiguration.volumeRamps = [volumeRamp1, volumeRamp2]
        renderLayer1.audioConfiguration = audioConfiguration
        
        // 1. Layer 2
        url = Bundle.main.url(forResource: "video2", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        timeRange = source.selectedTimeRange
        timeRange.start = CMTimeRangeGetEnd(renderLayer1.timeRange)
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        // 1. Layer 2 audio configuration
        audioConfiguration = AudioConfiguration()
        volumeRampTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 5, preferredTimescale: 600))
        volumeRamp1 = VolumeRamp(startVolume: 0.0, endVolume: 0.0, timeRange: volumeRampTimeRange)
        audioConfiguration.volumeRamps = [volumeRamp1]
        renderLayer2.audioConfiguration = audioConfiguration

        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1, renderLayer2]
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func textAnimationDemo() -> VideoLab {
        // 1. RenderLayer
        let url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        let asset = AVAsset(url: url!)
        let source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)

        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1]
        composition.animationLayer = makeTextAnimationLayer()
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func keyframeAnimationDemo() -> VideoLab {
        // 1. RenderLayer
        let url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        let asset = AVAsset(url: url!)
        let source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 1. Keyframe animation
        let keyTimes = [CMTime(seconds: 2, preferredTimescale: 600),
                        CMTime(seconds: 4, preferredTimescale: 600),
                        CMTime(seconds: 6, preferredTimescale: 600)]
        let animation = KeyframeAnimation(keyPath: "blendOpacity",
                                          values: [1.0, 0.2, 1.0],
                                          keyTimes: keyTimes, timingFunctions: [.linear, .linear])
        renderLayer1.animations = [animation]
        
        var transform = Transform.identity
        let animation1 = KeyframeAnimation(keyPath: "scale",
                                           values: [1.0, 1.3, 1.0],
                                           keyTimes: keyTimes, timingFunctions: [.quadraticEaseInOut, .quadraticEaseInOut])
        let animation2 = KeyframeAnimation(keyPath: "rotation",
                                           values: [0, Float.pi / 2.0, 0],
                                           keyTimes: keyTimes, timingFunctions: [.quadraticEaseInOut, .quadraticEaseInOut])
        transform.animations = [animation1, animation2]
        renderLayer1.transform = transform
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [renderLayer1]

        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func layerGroupDemo() -> VideoLab {
        // 1. LayerGroup
        var timeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 6, preferredTimescale: 600))
        let layerGroup = RenderLayerGroup(timeRange: timeRange)
        
        let keyTimes = [CMTime(seconds: 0, preferredTimescale: 600),
                        CMTime(seconds: 2, preferredTimescale: 600),
                        CMTime(seconds: 4, preferredTimescale: 600)]
        let animation1 = KeyframeAnimation(keyPath: "rotation",
                                           values: [0, Float.pi / 2.0, 0],
                                           keyTimes: keyTimes, timingFunctions: [.quadraticEaseInOut, .quadraticEaseInOut])
        var transform = Transform.identity
        transform.animations = [animation1]
        layerGroup.transform = transform
        
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 5, preferredTimescale: 600))
        timeRange = source.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: source)
        
        // 2. SubLayerGroup
        timeRange = CMTimeRange(start: CMTime(seconds: 1, preferredTimescale: 600), duration: CMTime(seconds: 5, preferredTimescale: 600))
        let subLayerGroup = RenderLayerGroup(timeRange: timeRange)
        subLayerGroup.blendOpacity = 0.5
        
        url = Bundle.main.url(forResource: "video2", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 4, preferredTimescale: 600))
        timeRange = source.selectedTimeRange
        timeRange.start = CMTime(seconds: 1, preferredTimescale: 600)
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        var center = CGPoint(x: 0.25, y: 0.25)
        transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLayer2.transform = transform
        
        url = Bundle.main.url(forResource: "video3", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 4, preferredTimescale: 600))
        timeRange = source.selectedTimeRange
        timeRange.start = CMTime(seconds: 1, preferredTimescale: 600)
        let renderLayer3 = RenderLayer(timeRange: timeRange, source: source)
        
        center = CGPoint(x: 0.75, y: 0.25)
        transform = Transform(center: center, rotation: 0, scale: 1/3.0)
        renderLayer3.transform = transform
        
        subLayerGroup.layers = [renderLayer2, renderLayer3]
        layerGroup.layers = [renderLayer1, subLayerGroup]
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [layerGroup]
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func transitionDemo() -> VideoLab {
        // 1.1 LayerGroup1
        var timeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 5, preferredTimescale: 600))
        let layerGroup1 = RenderLayerGroup(timeRange: timeRange)
        let transitionDuration = CMTime(seconds: 2.5, preferredTimescale: 600)
        var audioConfiguration = AudioConfiguration()
        var volumeRampTimeRange = CMTimeRange(start: layerGroup1.timeRange.end - transitionDuration, duration: transitionDuration)
        var volumeRamp = VolumeRamp(startVolume: 1.0, endVolume: 0.0, timeRange: volumeRampTimeRange)
        audioConfiguration.volumeRamps = [volumeRamp]
        layerGroup1.audioConfiguration = audioConfiguration
        
        // Add sub-renderLayer1
        var image = UIImage(named: "image1.JPG")
        var imageSource = ImageSource(cgImage: image?.cgImage)
        imageSource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = imageSource.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: imageSource)

        var center = CGPoint(x: 0.5, y: 0.5)
        var transform = Transform(center: center, rotation: 0, scale: 0.35)
        renderLayer1.transform = transform
        
        // Add sub-renderLayer2
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = source.selectedTimeRange
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        center = CGPoint(x: 0.25, y: 0.25)
        transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLayer2.transform = transform
        
        // Sets the layer array for the layer group
        layerGroup1.layers = [renderLayer1, renderLayer2]

        // 1.2 LayerGroup2
        timeRange.start = layerGroup1.timeRange.end - transitionDuration
        let layerGroup2 = RenderLayerGroup(timeRange: timeRange)
        audioConfiguration = AudioConfiguration()
        volumeRampTimeRange = CMTimeRange(start: CMTime.zero, duration: transitionDuration)
        volumeRamp = VolumeRamp(startVolume: 0.0, endVolume: 1.0, timeRange: volumeRampTimeRange)
        audioConfiguration.volumeRamps = [volumeRamp]
        layerGroup2.audioConfiguration = audioConfiguration

        // Add sub-renderLayer3
        url = Bundle.main.url(forResource: "video2", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = source.selectedTimeRange
        let renderLayer3 = RenderLayer(timeRange: timeRange, source: source)

        // Add sub-renderLayer4
        image = UIImage(named: "image2.HEIC")
        imageSource = ImageSource(cgImage: image?.cgImage)
        imageSource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = imageSource.selectedTimeRange
        let renderLayer4 = RenderLayer(timeRange: timeRange, source: imageSource)
        
        center = CGPoint(x: 0.75, y: 0.75)
        transform = Transform(center: center, rotation: 0, scale: 0.16)
        renderLayer4.transform = transform

        // Set the layer array for the layer group
        layerGroup2.layers = [renderLayer3, renderLayer4]
        
        // Set transition
        transform = Transform.identity
        let keyTimes = [CMTime.zero, transitionDuration]
        let animation = KeyframeAnimation(keyPath: "center.x",
                                          values: [1.5, 0.5],
                                          keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
        transform.animations = [animation]
        layerGroup2.transform = transform

        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [layerGroup1, layerGroup2]
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    func transition2Demo() -> VideoLab {
        // 1.1 LayerGroup1
        var timeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 5, preferredTimescale: 600))
        let layerGroup1 = RenderLayerGroup(timeRange: timeRange)

        // Add sub-renderLayer1
        var image = UIImage(named: "image1.JPG")
        var imageSource = ImageSource(cgImage: image?.cgImage)
        imageSource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = imageSource.selectedTimeRange
        let renderLayer1 = RenderLayer(timeRange: timeRange, source: imageSource)
        
        var center = CGPoint(x: 0.5, y: 0.5)
        var transform = Transform(center: center, rotation: 0, scale: 0.35)
        renderLayer1.transform = transform
        
        // Add sub-renderLayer2
        var url = Bundle.main.url(forResource: "video1", withExtension: "MOV")
        var asset = AVAsset(url: url!)
        var source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = source.selectedTimeRange
        let renderLayer2 = RenderLayer(timeRange: timeRange, source: source)
        
        center = CGPoint(x: 0.25, y: 0.25)
        transform = Transform(center: center, rotation: 0, scale: 0.5)
        renderLayer2.transform = transform
        
        // Sets the layer array for the layer group
        layerGroup1.layers = [renderLayer1, renderLayer2]
        
        // Add layerGroup1 transition
        // Scale transition
        let transitionDuration = CMTime(seconds: 0.25, preferredTimescale: 600)
        transform = Transform.identity
        var keyTimes = [layerGroup1.timeRange.duration - transitionDuration, layerGroup1.timeRange.duration]
        var animation = KeyframeAnimation(keyPath: "scale",
                                          values: [1.0, 5.0],
                                          keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
        transform.animations = [animation]
        layerGroup1.transform = transform
        
        // Zoomblur transition
        var zoomblur = ZoomBlur()
        animation = KeyframeAnimation(keyPath: "blurSize",
                                      values: [0.0, 3.0],
                                      keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
        zoomblur.animations = [animation]
        layerGroup1.operations = [zoomblur]
        
        // 1.2 LayerGroup2
        timeRange.start = layerGroup1.timeRange.end
        let layerGroup2 = RenderLayerGroup(timeRange: timeRange)

        // Add sub-renderLayer3
        url = Bundle.main.url(forResource: "video2", withExtension: "MOV")
        asset = AVAsset(url: url!)
        source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = source.selectedTimeRange
        let renderLayer3 = RenderLayer(timeRange: timeRange, source: source)
        
        // Add sub-renderLayer4
        image = UIImage(named: "image2.HEIC")
        imageSource = ImageSource(cgImage: image?.cgImage)
        imageSource.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: timeRange.duration)
        timeRange = imageSource.selectedTimeRange
        let renderLayer4 = RenderLayer(timeRange: timeRange, source: imageSource)
        
        center = CGPoint(x: 0.75, y: 0.75)
        transform = Transform(center: center, rotation: 0, scale: 0.16)
        renderLayer4.transform = transform
        
        // Set the layer array for the layer group
        layerGroup2.layers = [renderLayer3, renderLayer4]
        
        // Add layerGroup2 transition
        // Scale transition
        transform = Transform.identity
        keyTimes = [CMTime.zero, transitionDuration]
        animation = KeyframeAnimation(keyPath: "scale",
                                          values: [5.0, 1.0],
                                          keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
        transform.animations = [animation]
        layerGroup2.transform = transform
        
        // Zoomblur transition
        zoomblur = ZoomBlur()
        animation = KeyframeAnimation(keyPath: "blurSize",
                                      values: [3.0, 0.0],
                                      keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
        zoomblur.animations = [animation]
        layerGroup2.operations = [zoomblur]
        
        // 2. Composition
        let composition = RenderComposition()
        composition.renderSize = CGSize(width: 1280, height: 720)
        composition.layers = [layerGroup1, layerGroup2]
        
        // 3. VideoLab
        let videoLab = VideoLab(renderComposition: composition)
        
        return videoLab
    }
    
    // MARK: - Private
    func makeLutTextures() -> [Texture] {
        let lutImageNames = ["LUT_M01", "LUT_M02", "LUT_M03", "LUT_M07", "LUT_M06", "LUT_M12", "LUT_M11", "LUT_M05", "LUT_M08", "LUT_M09"]
        var textures: [Texture] = []
        for imageName in lutImageNames {
            guard let image = UIImage(named: imageName) else {
                continue
            }
            
            guard let cgImage = image.cgImage else {
                continue
            }
            
            guard let texture = Texture.makeTexture(cgImage: cgImage) else {
                continue
            }
            
            textures.append(texture)
        }
        return textures
    }
    
    func makeTextAnimationLayer() -> TextOpacityAnimationLayer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 120),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: "Think Big, Start Small, Learn Fast.", attributes: attributes)
        let size = attributedString.boundingRect(with: CGSize(width: 800, height: 720),
                                                 options: .usesLineFragmentOrigin,
                                                 context: nil).size
        let layer = TextOpacityAnimationLayer()
        layer.attributedText = attributedString
        layer.position = CGPoint(x: 640, y: 360)
        layer.bounds = CGRect(origin: CGPoint.zero, size: size)

        return layer
    }

    func makeSynchronizedLayer(playerItem: AVPlayerItem, videoLab: VideoLab) -> CALayer? {
        guard let animationLayer = videoLab.renderComposition.animationLayer else {
            return nil
        }

        let synchronizedLayer = AVSynchronizedLayer(playerItem: playerItem)
        synchronizedLayer.addSublayer(animationLayer)
        synchronizedLayer.zPosition = 999
        let videoSize = videoLab.renderComposition.renderSize
        synchronizedLayer.frame = CGRect(origin: CGPoint.zero, size: videoSize)
        
        let screenSize = UIScreen.main.bounds.size
        let videoRect = AVMakeRect(aspectRatio: videoSize, insideRect: CGRect(origin: CGPoint.zero, size: screenSize))
        synchronizedLayer.position = CGPoint(x: videoRect.midX, y: videoRect.midY)
        let scale = fminf(Float(screenSize.width / videoSize.width), Float(screenSize.height / videoSize.height))
        synchronizedLayer.setAffineTransform(CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))
        return synchronizedLayer
    }
}
