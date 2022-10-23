# VideoLab

高性能且灵活的视频剪辑与特效框架，基于 AVFoundation 与 Metal。

[框架设计与实现介绍](./Document/README-DETAIL-CN.md)

## 特性

- [x] 高性能实时剪辑与导出。
- [x] 高自由度组合视频，图片，音频
- [x] 支持音频音高设置，音量调节。
- [x] 支持 CALayer 矢量动画，可以支持复杂的文字动画。
- [x] 支持关键帧动画。
- [x] 支持类似于 After Effect 的预合成。
- [x] 支持转场。
- [x] 支持自定义各类特效，如 LUT 滤镜，zoom blur 等等（MSL 编写脚本）。

以下是一些特性的 gif（多图层、文字动画、关键帧动画、预合成及转场）
 
<p align="left">
    <img src="./Document/Resource/multiple-layer-demo.gif" width="240">
    <img src="./Document/Resource/text-animation-demo.gif" width="240">
    <img src="./Document/Resource/keyframe-animation-demo.gif" width="240">
    <img src="./Document/Resource/pre-compose-demo.gif" width="240">
    <img src="./Document/Resource/transition-demo.gif" width="240">
</p>

## 要求

* iOS 11.0+
* Swift 5.0+

## 安装

可以使用 [CocoaPods](https://cocoapods.org) 安装。只需指定如下语句到你的 `Podfile` 文件中。

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target>' do
  pod 'VideoLab'
end
```

## 使用

### 基础概念

#### RenderLayer

`RenderLayer` 是 `VideoLab` 框架中最基本的单元。一个视频、图片、音频都可以是一个 `RenderLayer`，甚至一个效果也可以是一个 `RenderLayer`。`RenderLayer` 类似于 After Effect 中图层的概念。

#### RenderComposition

`RenderComposition` 可以理解成一个视频作品，可以设置帧率、画布大小，包含多个 `RenderLayers`，可以设置 `CALayer` 支持矢量动画。


#### VideoLab

`VideoLab` 可以理解成一个实验室，基于 `RenderComposition` 生成 `AVPlayerItem`, `AVAssetExportSession`, `AVAssetImageGenerator`。

### 基础使用

```swift
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

// 4. Make playerItem
let playerItem = videoLab.makePlayerItem()
```

1. 创建 `RenderLayer`
2. 创建 `RenderComposition`，设置 `renderSize` 和 `layers`
3. 使用 `renderComposition` 创建 `VideoLab`
4. 生成 `AVPlayerItem` 或 `AVAssetExportSession`

### 更高级的使用

#### 变换

```swift
var center = CGPoint(x: 0.25, y: 0.25)
var transform = Transform(center: center, rotation: 0, scale: 0.5)
renderLayer1.transform = transform
```

1. 使用 `center`、`rotation` 和 `scale` 创建 `Transform`
2. `RenderLayer` 设置 `transform`

#### 音频设置

```swift
let audioConfiguration = AudioConfiguration()
let volumeRampTimeRange = CMTimeRange(start: CMTime.zero, duration: CMTime(seconds: 5, preferredTimescale: 600))
let volumeRamp1 = VolumeRamp(startVolume: 0.0, endVolume: 0.0, timeRange: volumeRampTimeRange)
audioConfiguration.volumeRamps = [volumeRamp1]
renderLayer2.audioConfiguration = audioConfiguration
```

1. 创建 `AudioConfiguration`
2. 使用 `startVolume`、`endVolume` 和 `timeRange` 创建
 `VolumeRamp` 
3. `AudioConfiguration`设置 `volumeRamps`
4. `RenderLayer` 设置 `audioConfiguration`

#### CALayer 动画

导出时，为 `RenderComposition` 设置自定义的 `CALayer`

```swift
composition.animationLayer = <Your customized CALayer>
```
播放时，添加 `AVSynchronizedLayer` 到你显示视图的 layer 上，更多细节参考 **Text Animation Demo**.

#### 关键帧动画

```swift
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
```

1. 使用 `keyPath`、`values`、`keyTimes` 和  `timingFunctions` 创建 `KeyframeAnimation`。
2. 为实现 `Animatable` 协议的结构体或者类设置 `animations`。

#### 预合成

```swift
let layerGroup = RenderLayerGroup(timeRange: timeRange)
layerGroup.layers = [renderLayer1, renderLayer2]
```

1. 使用 `timeRange` 创建 `RenderLayerGroup`
2. 为 `layerGroup` 设置子 `layers`。更多细节参考 **Layer Group Demo**

#### 转场

我们没有转场的 layer，但是你可以添加一个给每个 RenderLayer 添加一个 transform 或者 operations，以此来创建一个转场。更多细节参考 **Transition Demo**

#### 自定义特效

```swift
// Filter
var filter = LookupFilter()
filter.addTexture(lutTextures[0], at: 0)
renderLayer.operations = [filter]

// Zoom Blur
var zoomblur = ZoomBlur()
animation = KeyframeAnimation(keyPath: "blurSize",
                              values: [0.0, 3.0],
                              keyTimes: keyTimes, timingFunctions: [.quarticEaseOut])
zoomblur.animations = [animation]
layerGroup1.operations = [zoomblur]
```

1. 创建继承自 `BasicOperation` 的自定义 `Operation`。`BasicOperation` 同样实现 `Animatable` 协议。
2. 为 `RenderLayer` 设置 `operations`。

## 待办

* 支持 Open GL 渲染
* `RenderLayer` 增加速度控制
* 提供更便捷的方式使用转场，可能是提供 `TransitionLayer`
* 增加日志系统
* 增加界面交互的 demo

## 作者

阮景雄, ruanjingxiong@gmail.com
员凯, kayyyuan@gmail.com

## 许可证

VideoLab 使用 MIT 许可，详情请参考 [LICENSE](./LICENSE) 。

