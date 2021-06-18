# VideoLab - 高性能且灵活的 iOS 视频剪辑与特效框架

## VideoLab 是什么？

VideoLab 是开源的，高性能且灵活的 iOS 视频剪辑与特效框架，提供了更 AE(Adobe After Effect)化的使用方式。框架核心基于 AVFoundation 与 Metal。目前已有的特性：

* 高性能实时剪辑与导出。
* 高自由度组合视频，图片，音频。
* 支持音频音高设置，音量调节。
* 支持 CALayer 矢量动画，可以支持复杂的文字动画。
* 支持关键帧动画。
* 支持类似于 AE 的预合成。
* 支持转场。
* 支持自定义各类特效，如 LUT 滤镜，Zoom Blur 等等（MSL 编写脚本）。

以下是一些特性的 gif（多图层、文字动画、关键帧动画、预合成及转场）：

<p align="left">
    <img src="./Resource/multiple-layer-demo.gif" width="240">
    <img src="./Resource/text-animation-demo.gif" width="240">
    <img src="./Resource/keyframe-animation-demo.gif" width="240">
    <img src="./Resource/pre-compose-demo.gif" width="240">
    <img src="./Resource/transition-demo.gif" width="240">
</p>

仓库地址：https://github.com/ruanjx/VideoLab

本文将和大家分享 AVFoundation 视频剪辑流程，以及 VideoLab 框架的设计与实现。

## AVFoundation 视频剪辑流程

在开始介绍之前，建议刚接触视频剪辑的同学可以先看下如下 WWDC 视频：

* [Advanced Editing with AV Foundation](https://developer.apple.com/videos/play/wwdc2013/612/)
* [Edit and play back HDR video with AVFoundation](https://developer.apple.com/videos/play/wwdc2020/10009/)


让我们来看下 AVFoundation 视频剪辑的整体工作流程：

<img src="./Resource/VideoLab-Editing-with-AVFoundation-Workflow.png" width="700">

我们来拆解下步骤：

1. 创建一个或多个 `AVAsset`。
2. 创建 `AVComposition`、`AVVideoComposition` 及 `AVAudioMix`。其中 `AVComposition` 指定了音视频轨道的时间对齐，`AVVideoComposition` 指定了视频轨道在任何给定时间点的几何变换与混合，`AVAudioMix` 管理音频轨道的混合参数。
3. 我们可以使用这三个对象来创建 `AVPlayerItem`，并从中创建一个 `AVPlayer` 来播放编辑效果。
4. 此外，我们也可以使用这三个对象来创建 `AVAssetExportSession`，用来将编辑结果写入文件。

### AVComposition

让我们先来看下 `AVComposition`，`AVComposition` 是一个或多个 `AVCompositionTrack` 音视频轨道的集合。其中 `AVCompositionTrack` 又可以包含来自多个 `AVAsset` 的 `AVAssetTrack`。

下图的例子，将两个 `AVAsset` 中的音视频 `AVAssetTrack` 组合到 `AVComposition` 的音视频 `AVCompositionTrack` 中。

<img src="./Resource/VideoLab-AVComposition.png" width="600">

### AVVideoComposition

设想下图所示的场景， `AVComposition` 包含两个 `AVCompositionTrack`。我们在 T1 时间点需要混合两个 `AVCompositionTrack` 的图像。为了达到这个目的，我们需要使用 `AVVideoComposition`。

<img src="./Resource/VideoLab-AVComposition2.png" width="500">

`AVVideoComposition` 可以用来指定渲染大小和渲染缩放，以及帧率。此外，还存储了实现 `AVVideoCompositionInstructionProtocol` 协议的 Instruction（指令）数组，这些 Instruction 存储了混合的参数。有了这些混合参数之后，`AVVideoComposition` 可以通过一个实现 `AVVideoCompositing` 协议的 Compositor（混合器） 来混合对应的图像帧。

整体工作流如下图所示：

<img src="./Resource/VideoLab-AVVideoComposition.png" width="500">

让我们聚焦到 Compositor，我们有多个原始帧，需要处理并输出新的一帧。工作流程如下图所示：

<img src="./Resource/VideoLab-AVVideoCompositing.png" width="500">

流程可分解为：

1. `AVAsynchronousVideoCompositionRequest` 绑定了当前时间的一系列原始帧，以及当前时间所在的 Instruction。
2. 收到 `startVideoCompositionRequest:` 回调，并接收到这个 Request。
3. 根据原始帧及 Instruction 相关混合参数，渲染得到合成的帧。
4. 调用 `finishWithComposedVideoFrame:` 交付渲染后的帧。

### AVAudioMix

使用 `AVAudioMix`，你可以在 `AVComposition` 的音频轨道上处理音频。`AVAudioMix` 包含一组的 `AVAudioMixInputParameters`，每个 `AVAudioMixInputParameters` 对应一个音频的 `AVCompositionTrack`。如下图所示：

<img src="./Resource/VideoLab-AVAudioMix.png" width="500">

`AVAudioMixInputParameters` 包含一个 `MTAudioProcessingTap`，你可以使用它来实时处理音频。当然，对于线性音量变化可以直接使用音量斜率接口 `setVolumeRampFromStartVolume:toEndVolume:timeRange:`

此外，`AVAudioMixInputParameters` 还包含一个 `AVAudioTimePitchAlgorithm`，你可以使用它来设置音高。

## 框架的设计

前面我们介绍了 AVFoundation 视频剪辑流程，接下来我们介绍下 VideoLab 框架的设计。

先简要介绍下 AE(Adobe After Effect)，AE 是特效设计师常用的动态图形和视觉效果软件（更多介绍参见[AE官网](https://www.adobe.com/cn/products/aftereffects.html)）。AE 通过”层“控制视频、音频及静态图片的合成，每个媒体（视频、音频及静态图片）对象都有自己独立的轨道。

下图是在 AE 中合成两个视频的示例。

<img src="./Resource/After-Effects.jpg" width="700">

我们来分解下这张示例图：

* 在 Project 区域内，有名为 Comp1 类型为 Composition 的一个合成。在 AE 中合成可以认为是一个作品，可以播放导出一个视频。一个合成可以设置宽高值、帧率、背景色等参数。
* 在 Timeline Control 区域内，包含了两个图层，源分别为 video1.MOV 与 video2.MOV。我们可以自由的设置图层参数，如 Transform（示例还针对 Scale 做了关键帧动画），Audio，也可以在右边区域自由的移动图层的时间区间。此外，我们可以给每个图层添加一组特效。

基于对 AE 的分析，我们可以设计相似的描述方式：

<img src="./Resource/VideoLab-RenderComposition.png" width="600">

* `RenderComposition`，对应 AE 中的合成（Composition）。包含一组 `RenderLayer`（对应 AE 中的层）。此外，`RenderComposition` 还包含 `BackgroundColor`、`FrameDuration`、`RenderSize`，分别对应背景色、帧率及渲染大小等剪辑相关参数。
* `RenderLayer`，对应 AE 中的层（Layer）。包含了 `Source`、`TimeRange`、`Transform`、`AudioConfiguration`、`Operations`，分别对应素材来源、在时间轴的时间区间、变换（位置、旋转、缩放）、音频配置及特效操作组。 
* `RenderLayerGroup`，对应 AE 的预合成。`RenderLayerGroup` 继承自 `RenderLayer`，包含一组 `RenderLayer`。
* `KeyframeAnimation`，对应 AE 的关键帧动画。包含了 `KeyPath`、`Values`、`KeyTimes`、`TimingFunctions`，分别对应关键路径、数值数组、关键时间数组、缓动函数数组。

以上介绍了 `RenderComposition`、`RenderLayer`、`RenderLayerGroup` 以及 `KeyframeAnimation`。从前面的 AVFoundation 介绍可知，我们需要生成 `AVPlayerItem` 与 `AVAssetExportSession` 用于播放与导出。因此，我们需要有一个对象可以解析这几个描述对象，并用 AVFoundation 的方法生成 `AVPlayerItem` 与 `AVAssetExportSession`。框架将这个对象命名为 `VideoLab`，可以理解成这是一个实验室。

整体的工作流程如下：

<img src="./Resource/VideoLab-VideoLab-Workflow.png" width="700">

我们来拆解下步骤：

1. 创建一个或多个 `RenderLayer`。
2. 创建 `RenderComposition`，设置其 `BackgroundColor`、`FrameDuration`、`RenderSize`，以及 `RenderLayer` 数组。
3. 使用创建的 `RenderComposition` 创建 `VideoLab`。
4. 使用创建的 `VideoLab` 生成 `AVPlayerItem` 或 `AVAssetExportSession`。

这个章节主要介绍了框架的设计思路。设计思路总的来说，希望框架是类 AE 化灵活的方式设计。

## 框架的实现

### Source

从前面的介绍，我们知道一个 `RenderLayer` 可能包含一个素材来源。素材来源可以是视频、音频及静态图片等。框架抽象了 `Source` 协议，以下是 `Source` 协议的核心代码：

```swift
public protocol Source {
    var selectedTimeRange: CMTimeRange { get set }
    
    func tracks(for type: AVMediaType) -> [AVAssetTrack]
    func texture(at time: CMTime) -> Texture?
}
```

* `selectedTimeRange` 是素材本身的选择时间区间，如一段长 2 分钟的视频，我们选择 60s-70s 的区间作为编辑素材，那么 `selectedTimeRange` 就是 [60s-70s)（实际代码使用 `CMTime`）。
* `tracks(for:)` 方法，用于根据 `AVMediaType` 获取 `AVAssetTrack`。
* `texture(at:)` 方法，用于根据时间获取 `Texture`（纹理）。

框架提供了 4 种内置的源，分别为：1. `AVAssetSource`，`AVAsset`；2. `ImageSource`，静态图片；3. `PHAssetVideoSource`，相册视频；4. `PHAssetImageSource`，相册图片。我们也可以实现 `Source` 协议，提供自定义的素材来源。

### AVComposition

到目前为止我们已经知道了 `RenderComposition`、`RenderLayer`、`RenderLayerGroup`、`KeyframeAnimation`、`Source`，接下来将介绍 `VideoLab` 类如何利用这些对象创建 `AVComposition`、`AVVideoComposition` 以及 `AVAudioMix`。

让我们先来看下 `AVComposition`，我们需要给 `AVComposition` 分别添加视频轨道与音频轨道。

让我们结合一个示例来说明这个过程，如下图所示，这个 `RenderComposition` 有 RenderLayer1（包含视频/音频）、RenderLayer2(仅视频）、RenderLayer3（图片）、RenderLayer4（仅特效操作组）以及一个 `RenderLayerGroup`（包含 RenderLayer5、RenderLayer6，均包含视频/音频）。

<img src="./Resource/VideoLab-AVComposition-RenderComposition.png" width="500">

让我们先聊下添加视频轨道，添加视频轨道包含以下步骤：

**1. 将 RenderLayer 转换为 VideoRenderLayer**

`VideoRenderLayer` 是框架内部对象，包含一个 `RenderLayer`，主要负责将 `RenderLayer` 的视频轨道添加到 `AVComposition` 中。可转换为 `VideoRenderLayer` 的 `RenderLayer` 包含以下几类：1. `Source` 包含视频轨道；2. `Source` 为图片类型；3. 特效操作组不为空（`Operations`）。

`VideoRenderLayerGroup` 是 `RenderLayerGroup` 对应视频的框架内部对象，包含一个 `RenderLayerGroup`。可转换为 `VideoRenderLayerGroup` 的 `RenderLayerGroup` 只需满足一个条件：包含的 `RenderLayer` 组有一个可以转化为 `VideoRenderLayer`。

转换 `VideoRenderLayer` 之后如下图所示：

<img src="./Resource/VideoLab-AVComposition-VideoRenderLayer.png" width="500">

**2. 将 VideoRenderLayer 视频轨道添加到 AVComposition 中**

对于 `RenderLayer` 的 `Source` 包含视频轨道的 `VideoRenderLayer`，从 `Source` 中获取视频 `AVAssetTrack`，添加到 `AVComposition`。

对于 `RenderLayer` 的 `Source` 为图片类型或仅有特效操作组类型（`Source` 为空）的 `VideoRenderLayer`，使用空视频添加一个新的视频轨道（这里的空视频是指视频轨道是黑帧且不包含音频轨道的视频）

添加完之后 `AVComposition` 的视频轨道如下图所示：

<img src="./Resource/VideoLab-AVComposition-VideoTrack.png" width="600">

如图所示，VideoRenderLayer1 与 VideoRenderLayer5 共用了一个视频轨道。这是由于苹果对视频轨道数量有限制，我们需要尽量的重用视频轨道（每条视频轨道对应一个解码器，当解码器数量超出系统限制时，会出现无法解码的错误）。

框架视频轨道重用的原则是，**如果要放入的 VideoRenderLayer 与之前视频轨道的 VideoRenderLayer 在时间上没有交集，则可以重用这个视频轨道，所有视频轨道都重用不了则新增一个视频轨道。**

让我们接着聊下添加音频轨道，添加音频轨道包含以下步骤：

**1. 将 RenderLayer 转换为 AudioRenderLayer**

`AudioRenderLayer` 是框架内部对象，包含一个 `RenderLayer`，主要负责将 `RenderLayer` 的音频轨道添加到 `AVComposition` 中。可转换为 `AudioRenderLayer` 的 `RenderLayer` 只需满足一个条件：`Source` 包含音频轨道。

`AudioRenderLayerGroup` 是 `RenderLayerGroup` 对应音频的框架内部对象，包含一个 `RenderLayerGroup`。可转换为 `AudioRenderLayerGroup` 的 `RenderLayerGroup` 只需满足一个条件：包含的 `RenderLayer` 组有一个可以转化为 `AudioRenderLayer`。

转换 `AudioRenderLayer` 之后如下图所示：

<img src="./Resource/VideoLab-AVComposition-AudioRenderLayer.png" width="500">

**2. 将 AudioRenderLayer 音频轨道添加到 AVComposition 中**

对于 `RenderLayer` 的 `Source` 包含音频轨道的 AudioRenderLayer，从 `Source` 中获取音频 AVAssetTrack，添加到 AVComposition。

添加完之后 `AVComposition` 的音频轨道如下图所示：

<img src="./Resource/VideoLab-AVComposition-AudioTrack.png" width="600">

如图所示，不同于视频轨道的重用，音频的每个 `AudioRenderLayer` 都对应一个音频轨道。这是由于一个 `AVAudioMixInputParameters` 与一个音频的轨道一一对应，而其音高设置（`audioTimePitchAlgorithm`）作用于整个音频轨道。如果重用的话，会存在一个音频轨道有多个 `AudioRenderLayer` 的情况，这样会导致所有的 `AudioRenderLayer` 都要配置同样的音高，这显然是不合理的。。

### AVVideoComposition

从前面的 AVFoundation 介绍可知，`AVVideoComposition` 可以用来指定渲染大小和渲染缩放，以及帧率。此外，还有一组存储了混合参数的 Instruction（指令）。有了这些混合参数之后，`AVVideoComposition` 可以通过自定义 Compositor（混合器） 来混合对应的图像帧。

这个章节将主要介绍如何生成这组 Instruction（指令），以及创建 `AVVideoComposition`。我们将使用上个章节生成的 `VideoRenderLayer`，生成这组 Instruction（指令）。

让我们结合一个简单示例来说明这个过程，如下图所示，这个 `AVComposition` 有 VideoRenderLayer1、VideoRenderLayer2、VideoRenderLayer3 三个 `VideoRenderLayer`。转换过程包含以下步骤：

* 在时间轴上记录每个 `VideoRenderLayer` 的起始时间点与结束时间点（如下图 T1-T6）。
* 为每个时间间隔创建一个 Instruction，与时间间隔有交集的 `VideoRenderLayer`，都作为 Instruction 的混合参数（如下图 Instruction1-Instruction5）。

<img src="./Resource/VideoLab-AVVideoComposition-Instruction.png" width="500">

接着我们创建 `AVVideoComposition`，并设置帧率、渲染大小、Instruction 组以及自定义的 Compositor。核心代码如下：

```swift
let videoComposition = AVMutableVideoComposition()
videoComposition.frameDuration = renderComposition.frameDuration
videoComposition.renderSize = renderComposition.renderSize
videoComposition.instructions = instructions
videoComposition.customVideoCompositorClass = VideoCompositor.self
```

到目前为止，我们已经有了渲染所需的 Instruction 组与混合参数，我们继续介绍如何利用它们在 Compositor 中绘制帧画面。我们对前面的 Compositor 工作流程做一个更新，将混合参数更新为与 Instruction 有交集的 `VideoRenderLayer` 组。

<img src="./Resource/VideoLab-AVVideoComposition-Render.png" width="500">

我们同样以一个示例来说明视频混合的规则，如下图所示，在 T1 时间点，我们想要混合这几个 `VideoRenderLayer` 的画面。

<img src="./Resource/VideoLab-AVVideoComposition-Render2.png" width="500">

我们的渲染混合规则如下：

* 排序 `VideoRenderLayer` 组，依据其所包含的 `RenderLayer` 的 `layerLevel`。如上图所示在纵向从高到低的排序。
* 遍历 `VideoRenderLayer` 组，对每个 `VideoRenderLayer` 分为以下三种混合方式：
    * 当前 `VideoRenderLayer` 是 `VideoRenderLayerGroup`，即为预合成方式。遍历处理完自己内部的 `VideoRenderLayer` 组，生成一张纹理，混合到前面的纹理。
    * 当前 `VideoRenderLayer` 的 `Source` 包含视频轨道或 `Source` 为图片类型，拿到纹理处理自己的特效操作组（Operations），接着混合到前面的纹理。
    * 当前 `VideoRenderLayer` 仅特效操作组，所有的操作作用于前面混合的纹理。

渲染混合规则总结来说，**按层级渲染，从下往上。如当前层级有纹理则先处理自己的纹理，再混合进前面的纹理。如当前层级没有纹理，则操作直接作用于前面的纹理。**

让我们将规则用在上图的示例中，假设我们最后输出的纹理为 Output Texture：

1. 处理最底层的 VideoRenderLayerGroup 生成 Texture1，将 Texture1 混合进 Output Texture。
2. 处理 VideoRenderLayer2 生成 Texture 2，将 Texture2 混合进 Output Texture。
3. 处理 VideoRenderLayer3 生成 Texture 3，将 Texture3 混合进 Output Texture。
4. 处理 VideoRenderLayer4 的特效操作组，作用于 Output Texture。

### AVAudioMix

从前面的 AVFoundation 介绍可知，`AVAudioMix` 用于处理音频。`AVAudioMix` 包含一组的 `AVAudioMixInputParameters`，可以设置 `MTAudioProcessingTap` 实时处理音频，设置 `AVAudioTimePitchAlgorithm` 指定音高算法。

这个章节将主要介绍如何生成这组 `AVAudioMixInputParameters`，以及创建 `AVAudioMix`。我们将使用 AVComposition 章节生成的 `AudioRenderLayer`，生成这组 `AVAudioMixInputParameters`。

让我们结合一个简单示例来说明这个过程，如下图所示，这个 `AVComposition` 有 AudioRenderLayer1、AudioRenderLayer2、AudioRenderLayer3 三个 `AudioRenderLayer`。转换过程包含以下步骤：

* 为每个 `AudioRenderLayer` 创建了一个 `AVAudioMixInputParameters`
* 为每个 `AVAudioMixInputParameters` 设置一个 `MTAudioProcessingTap`。`MTAudioProcessingTap` 用于实时处理音频，从 `RenderLayer` 的 `AudioConfiguration` 获取音频配置，实时计算当前时间点的音量。
* 为每个 `AVAudioMixInputParameters` 设置 `AVAudioTimePitchAlgorithm`。`AVAudioTimePitchAlgorithm` 用于设置音高算法，从 `RenderLayer` 的 `AudioConfiguration` 获取音高算法配置。

<img src="./Resource/VideoLab-AVAudioMix-AVAudioMixInputParameters.png" width="500">

接着我们创建 `AVAudioMix`，并设置 `AVAudioMixInputParameters` 组。代码如下：

```swift
let audioMix = AVMutableAudioMix()
audioMix.inputParameters = inputParameters
```

以上几个章节从大的维度介绍了框架的实现，对于 Metal 部分的介绍，后续会考虑再起一篇文章介绍。接下来的几个章节，介绍下框架的后续计划、开发框架过程逆向其他应用的一些分享以及推荐的学习资料。

## 框架后续计划

* 支持 Open GL 渲染（使用方决定渲染引擎使用 Metal 或 Open GL）。
* 特性持续补充，如变速、更便捷的转场使用方式（可能是提供 TransitionLayer）等。
* 提供界面交互的 Demo。

## 逆向分享

笔者在开发框架过程中，逆向了国内外一众视频编辑器。在比较各自的方案之后，选用了 AVFoundation 加 Metal 的方案作为框架核心。这里简要分享下逆向 Videoleap 的一些亮点：

* 尽量少的 Draw Call，尽量将一个层的操作都放在一个 Shader 脚本中（如 Videoleap 中对一个视频片段的 YUV 转 RGB、滤镜、变换等都在一个 Shader 内）。
* 使用 IOSurface 生成纹理性能更优（需要系统大于等于 iOS 11）。
    * Metal 对应方法 `makeTexture(descriptor:iosurface:plane:)`
    * Open GL 对应方法 `texImageIOSurface(_:target:internalFormat:width:height:format:type:plane:)`
* 尽量多的使用 Framebuffer Fetch（如果 fragment 只是像素点本身的颜色变化可以使用，如果有参考临近像素点则无法使用）
    * [Metal 参考资料](https://stackoverflow.com/questions/40968576/read-framebuffer-in-metal-shader)，框架中的 Metal 脚本对应的 [[color(0)]]
    * [Open GL 参考资料](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/BestPracticesforShaders/BestPracticesforShaders.html#//apple_ref/doc/uid/TP40008793-CH7-SW23#Fetch%20Framebuffer%20Data%20for%20Programmable%20Blending)，搜索 GL_EXT_shader_framebuffer_fetch

## 推荐资料

### AVFoundation

* [WWDC 2012 - Real-Time Media Effects and Processing during Playback](https://developer.apple.com/videos/play/wwdc2012/517/)
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



