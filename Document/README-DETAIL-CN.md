# VideoLab - 高性能且灵活的 iOS 视频剪辑与特效框架

## VideoLab 是什么？

VideoLab 是开源的，高性能且灵活的 iOS 视频剪辑与特效框架，提供了更 AE(Adobe After Effect)化的使用方式。框架核心基于 AVFoundation 与 Metal。目前已有的特性：

* 高性能实时剪辑与导出。
* 高自由度组合视频，图片，音频。
* 支持音频音高设置，音量调节。
* 支持 CALayer 矢量动画，可以支持复杂的文字动画。
* 支持关键帧动画。
* 支持类似于 After Effect 的预合成。
* 支持转场。
* 支持自定义各类特效，如 LUT 滤镜，zoom blur 等等（MSL 编写脚本）。

以下是一些特性的 gif（多图层、文字动画、关键帧动画、预合成及转场）：

<p align="left">
    <img src="./Resource/multiple-layer-demo.gif" width="240">
    <img src="./Resource/text-animation-demo.gif" width="240">
    <img src="./Resource/keyframe-animation-demo.gif" width="240">
    <img src="./Resource/pre-compose-demo.gif" width="240">
    <img src="./Resource/transition-demo.gif" width="240">
</p>

本文将和大家分享 AVFoundation 视频剪辑流程，以及 VideoLab 框架的设计与实现。

## AVFoundation 视频剪辑流程

在开始介绍之前，建议刚接触视频剪辑的同学可以先看下如下 WWDC 视频：

* [Advanced Editing with AV Foundation](https://developer.apple.com/videos/play/wwdc2013/612/)
* [Edit and play back HDR video with AVFoundation](https://developer.apple.com/videos/play/wwdc2020/10009/)


接下来让我们来看下 AVFoundation 视频剪辑的整体工作流程：

<img src="./Resource/VideoLab-Editing-with-AVFoundation-Workflow.png" width="600">

我们来拆解下步骤：

1. 创建一个或多个 `AVAsset`。
2. 创建 `AVComposition`、`AVVideoComposition` 及 `AVAudioMix`。其中 `AVComposition` 指定了音视频轨道的时间对齐，`AVVideoComposition` 指定了视频轨道在任何给定的时间点的几何变换与混合，`AVAudioMix` 管理音频轨道的混合参数。
3. 我们可以使用这三个对象来创建 `AVPlayerItem`，并从中创建一个 `AVPlayer` 来播放编辑效果。
4. 此外，我们也可以使用这三个对象来创建 AVAssetExportSession，用来将编辑结果写入文件。

### AVComposition

让我们先来看下 `AVComposition`，`AVComposition` 是一个或多个 `AVCompositionTrack` 音视频轨道的集合。其中 `AVCompositionTrack` 又可以包含来自多个 `AVAsset` 的 `AVAssetTrack`。

下图的例子，将两个 `AVAsset` 中的音视频 `AVAssetTrack` 组合到 `AVComposition` 的音视频 `AVCompositionTrack` 中。

<img src="./Resource/VideoLab-AVComposition.png" width="600">

### AVVideoComposition

下图所示的场景中， `AVComposition` 包含两个 `AVCompositionTrack`。我们在 T1 时间点需要混合两个 `AVCompositionTrack` 的图像，为了达到这个目的，我们需要使用 `AVVideoComposition`。

<img src="./Resource/VideoLab-AVComposition2.png" width="400">

`AVVideoComposition` 可以用来指定渲染大小和渲染缩放，以及帧率。此外，还存储了实现 `AVVideoCompositionInstructionProtocol` 协议的 Instruction 数组，这些 Instruction 存储了混合的参数。有了这些混合参数之后，`AVVideoComposition` 可以通过一个实现 `AVVideoCompositing` 协议的 Compositor 来混合对应的图像帧。

整体工作流如下图所示：

<img src="./Resource/VideoLab-AVVideoComposition.png" width="500">

让我们聚焦到 Compositor，我们有多个原始帧，需要处理并输出新的一帧。工作流程如下图所示：

<img src="./Resource/VideoLab-AVVideoCompositing.png" width="600">

流程可分解为：

1. `AVAsynchronousVideoCompositionRequest` 绑定了当前时间的一系列原始帧，以及当前时间所在的 Instruction。
2. 收到 `startVideoCompositionRequest:` 回调，并接收到这个 Request。
3. 根据原始帧及 Instruction 相关混合参数，渲染得到合成的帧。
4. 调用 `finishWithComposedVideoFrame:` 交付渲染后的帧。

### AVAudioMix

使用 `AVAudioMix`，你可以在 `AVComposition` 的音频轨道上处理音频。`AVAudioMix` 包含一组的 `AVAudioMixInputParameters`，每个 `AVAudioMixInputParameters` 对应一个音频的 `AVCompositionTrack`。如下图所示：

<img src="./Resource/VideoLab-AVAudioMix.png" width="400">

`AVAudioMixInputParameters` 包含一个 `MTAudioProcessingTap`，你可以使用它来实时处理音频。当然对于线性音量变化可以直接使用音量斜率接口。

此外 `AVAudioMixInputParameters` 还包含一个 `AVAudioTimePitchAlgorithm`，你可以使用它来设置音调。

## 从 AE 的角度设计框架

### 渲染

## 后续计划

## 逆向分享

## 总结

## 推荐资料

### AVFoundation

* [WWDC 2013 - Advanced Editing with AV Foundation](https://developer.apple.com/videos/play/wwdc2013/612/)
* [WWDC 2020 - Edit and play back HDR video with AVFoundation](https://developer.apple.com/videos/play/wwdc2020/10009/)
* [AVFoundation Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html)
* [Apple AVFoundation Collection](https://developer.apple.com/av-foundation/)
* [Apple Sample Code - AVCustomEdit](https://developer.apple.com/library/archive/samplecode/AVCustomEdit/Listings/AVCustomEdit_APLCustomVideoCompositor_m.html#//apple_ref/doc/uid/DTS40013411-AVCustomEdit_APLCustomVideoCompositor_m-DontLinkElementID_10)
* [Github - Cabbage](https://github.com/VideoFlint/Cabbage)

### 渲染

* [Learn OpenGL - Getting started](https://learnopengl.com/Introduction)
* [Apple Metal Collection](https://developer.apple.com/metal/)
* [Metal Best Practices Guide](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/index.html#//apple_ref/doc/uid/TP40016642-CH27-SW1)
* [Metal by Tutorials](https://www.raywenderlich.com/books/metal-by-tutorials/v2.0)
* [Metal by Example](https://metalbyexample.com/category/advanced/)
* [小专栏 - iOS 图像处理](https://xiaozhuanlan.com/u/4926220611)
* [Github - GPUImage3](https://github.com/BradLarson/GPUImage3)

## 作者

* 阮景雄，目前就职于 RingCentral，前美拍 iOS 负责人
* 邮件：ruanjingxiong@gmail.com



