---
title: Flutter 在鸿蒙上使用 LTPO 屏幕动态帧率
date: 2026-08-07 15:00:00
tags:
  - Flutter
  - HarmonyOS
  - 鸿蒙
  - LTPO
  - 性能优化
categories:
  - Flutter
author: 少湖
---

![cover](/images/2026/08/flutter_ltpo_harmonyos_cover.png)

LTPO（Low-Temperature Polycrystalline Oxide）屏幕已经成为高端智能手机的标配，华为 Mate 60 系列、Pura 70 系列等鸿蒙设备均搭载了 LTPO 面板，支持从 1Hz 到 120Hz 的动态刷新率调节。然而 Flutter 应用在鸿蒙平台上能否充分利用 LTPO 的能力，却是一个容易被忽视的问题。

本文将从 Flutter 的渲染机制出发，分析鸿蒙 LTPO 屏幕的特性，探讨 Flutter 应用如何适配动态帧率，在流畅度与功耗之间找到平衡。

<!-- more -->

## 1. LTPO 屏幕与动态帧率

LTPO 的全称是 Low-Temperature Polycrystalline Oxide（低温多晶氧化物），它结合了 LTPS（低温多晶硅）的高迁移率特性和 IGZO（铟镓锌氧化物）的低漏电流特性，使得屏幕面板可以在极低刷新率（1Hz）下稳定工作，同时又能无缝切换到高刷新率（120Hz）。

对于用户而言，LTPO 带来的直观体验是：

- **滑动/动画时**：120Hz 满帧运行，画面丝滑流畅
- **静态内容阅读**：自动降至 10Hz~30Hz，减少不必要的刷新
- **AOD（息屏显示）**：可低至 1Hz，大幅降低功耗

但这对应用层提出了一个隐含要求：**应用需要根据内容场景动态调整帧率**，而不是简单地以最大帧率恒定渲染。如果应用始终以 120fps 渲染，LTPO 屏幕的功耗优势就会被浪费。

## 2. Flutter 的渲染与帧率调度

Flutter 的渲染管线由 `SchedulerBinding` 驱动，通过 `Ticker` 与平台 vsync 信号同步。每次 vsync 信号到来时，Flutter 执行一轮构建 → 布局 → 绘制 → 合成 → 提交的渲染流水线。

### 2.1 默认行为

在 Flutter 中，帧率由两部分决定：

- **平台 vsync 信号频率**：由底层引擎监听屏幕的刷新率，Android 上通过 `Choreographer` 获取，HarmonyOS 上则通过对应的 vsync 服务接口
- **应用是否需要渲染新帧**：如果没有任何动画或变化，Flutter 不会主动请求帧

```dart
// 通过 Ticker 驱动动画
class MyAnimation extends StatefulWidget {
  @override
  State<MyAnimation> createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // 绑定 vsync
      duration: Duration(seconds: 2),
    )..forward();
  }
}
```

当没有任何 `Ticker` 活跃时，Flutter 不会产生渲染帧，这本身已经实现了"按需渲染"——终端以最低刷新率运行即可。

### 2.2 FlutterEngine 的帧率控制

FlutterEngine 在 Android 上通过 `Choreographer` 注册帧回调，`Choreographer` 的帧间隔取决于当前显示器的刷新率。在 HarmonyOS 上，Flutter 的鸿蒙适配层（OpenHarmony Flutter 引擎）通过 `Vsync` 接口来获取帧同步信号。

```dart
// 获取当前屏幕刷新率
import 'dart:ui' as ui;

double getCurrentRefreshRate() {
  final display = ui.PlatformDispatcher.instance.views.first.display;
  return display.refreshRate; // 返回 FPS，如 60.0、120.0
}
```

## 3. 鸿蒙上 LTPO 的现状

### 3.1 硬件支持

华为搭载 LTPO 屏幕的机型（如 Mate 60、Pura 70、Mate X 系列）均支持 1Hz~120Hz 的动态调节。在 HarmonyOS 4.x 及 HarmonyOS NEXT 5.0 上，系统会根据当前显示内容自动调节刷新率。

### 3.2 系统级调度

HarmonyOS 的图形栈（ArkGraphics 和 Render Service）对刷新率的管理方式是：

1. **应用主动请求帧**：当应用有内容更新时，向 vsync 服务注册回调
2. **系统仲裁**：Render Service 根据当前所有窗口的帧请求情况，决定是否降低刷新率
3. **硬件适配**：屏幕驱动层根据系统仲裁结果，动态调整面板刷新率

这意味着，如果 Flutter 应用持续以 120fps 渲染（即使画面没有变化），系统会被迫维持高刷新率，导致功耗增加。

### 3.3 Flutter 的鸿蒙适配对帧率的影响

Flutter 的鸿蒙引擎适配（`ohos_flutter` 或 Flutter 官方 OHOS 支持）在 vsync 处理上存在一些差异：

| 平台 | vsync 提供方 | 帧率获取方式 | 动态帧率支持 |
|------|-------------|-------------|-------------|
| Android | Choreographer | Display.getRefreshRate() | 依赖系统自动管理 |
| iOS | CADisplayLink | preferredFramesPerSecond | 可手动设置 |
| HarmonyOS | vsync service | 需通过 Native API 获取 | 需适配 |

HarmonyOS 的 vsync 服务提供的回调频率与当前系统判定的刷新率一致，但 Flutter 引擎需要正确处理空闲状态下的帧请求取消，才能让系统有机会降低刷新率。

## 4. Flutter 应用适配 LTPO 的实践方案

### 4.1 停止不必要的帧请求

这是最基础也最重要的优化。当应用没有动画或用户交互时，确保所有 `Ticker` 和 `AnimationController` 都处于停止状态。

```dart
class UsageAwareWidget extends StatefulWidget {
  @override
  State<UsageAwareWidget> createState() => _UsageAwareWidgetState();
}

class _UsageAwareWidgetState extends State<UsageAwareWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // 应用不可见时，停止所有动画
      // AnimationController 会自动暂停
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

### 4.2 使用 `TickerMode` 控制子树帧率

Flutter 提供了 `TickerMode` widget，可以批量控制子树中所有 `Ticker` 的启停：

```dart
// 当用户没有操作时，暂停所有动画
TickerMode(
  enabled: _isUserInteracting,
  child: YourAnimatedContent(),
)
```

### 4.3 检测当前刷新率并动态调整

根据当前设备的刷新率，动态调整动画的精细度或帧率：

```dart
class AdaptiveRefreshWidget extends StatefulWidget {
  @override
  State<AdaptiveRefreshWidget> createState() => _AdaptiveRefreshWidgetState();
}

class _AdaptiveRefreshWidgetState extends State<AdaptiveRefreshWidget> {
  double _refreshRate = 60.0;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _refreshRate = _getRefreshRate();
    _ticker = createTicker(_onTick)..start();
  }

  double _getRefreshRate() {
    final display = ui.PlatformDispatcher.instance.views.first.display;
    return display.refreshRate;
  }

  void _onTick(Duration elapsed) {
    // 根据刷新率调整动画参数
    // 例如：在高刷屏上使用更精细的插值
    setState(() {
      // 更新动画状态
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
```

### 4.4 帧率自适应渲染策略

在实际项目中，可以实施以下策略来充分利用 LTPO：

```dart
enum RefreshStrategy {
  /// 始终以最大帧率渲染，追求极致流畅
  maxPerformance,
  /// 仅在用户交互时使用高帧率
  adaptive,
  /// 固定为 60fps，最省电
  batterySaver,
}

class LTPOManager {
  static final LTPOManager _instance = LTPOManager._();
  factory LTPOManager() => _instance;
  LTPOManager._();

  RefreshStrategy _strategy = RefreshStrategy.adaptive;

  RefreshStrategy get strategy => _strategy;

  void setStrategy(RefreshStrategy strategy) {
    _strategy = strategy;
  }

  /// 获取建议的帧间隔
  Duration getSuggestedFrameInterval(double refreshRate) {
    switch (_strategy) {
      case RefreshStrategy.maxPerformance:
        return Duration(microseconds: (1000000 / refreshRate).round());
      case RefreshStrategy.adaptive:
        // 自适应模式：根据场景动态调整
        return _isUserInteracting.value
            ? Duration(microseconds: (1000000 / refreshRate).round())
            : Duration(milliseconds: 16); // ~60fps 空闲
      case RefreshStrategy.batterySaver:
        return Duration(milliseconds: 16); // 固定 60fps
    }
  }
}
```

### 4.5 通过 Platform Channel 与鸿蒙原生交互

在鸿蒙平台上，可以通过 Flutter 的 Platform Channel 与原生层交互，获取更精确的刷新率信息和 vsync 控制：

```dart
// Dart 端
class HarmonyOSDisplay {
  static const _channel = MethodChannel('com.example/display');

  static Future<double> getRefreshRate() async {
    try {
      final rate = await _channel.invokeMethod<double>('getRefreshRate');
      return rate ?? 60.0;
    } on MissingPluginException {
      return 60.0;
    }
  }

  static Future<void> setPreferredRefreshRate(double fps) async {
    try {
      await _channel.invokeMethod('setPreferredRefreshRate', {'fps': fps});
    } on MissingPluginException {
      // 降级处理
    }
  }
}
```

对应的鸿蒙原生端（ArkTS）：

```typescript
// ArkTS 端
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

class DisplayPlugin {
  getRefreshRate(): number {
    const defaultDisplay = display.getDefaultDisplaySync();
    return defaultDisplay?.refreshRate ?? 60;
  }

  setPreferredRefreshRate(fps: number): void {
    // 鸿蒙的 DisplayManager 暂不直接支持设置帧率
    // 但可以通过配置 vsync 参数间接影响
    console.info(`Preferred refresh rate: ${fps}fps`);
  }
}
```

## 5. LTPO 适配的注意事项与局限

### 5.1 系统级策略优先

需要明确的是，LTPO 刷新率的调节是一个**系统级行为**。HarmonyOS 的 Render Service 会综合所有窗口的渲染需求来决定最终刷新率，单个应用的影响是有限的。应用层面能做的，主要是**不要制造不必要的帧请求**，让系统有机会降频。

### 5.2 帧率切换的视觉卡顿

LTPO 屏幕在刷新率切换时（如从 120Hz 降到 10Hz），可能会产生可感知的短暂卡顿。这是 LTPO 面板的物理特性——不同刷新率下的像素充电时间不同，面板需要一定的稳定时间。

对于 Flutter 应用，如果帧率频繁切换（例如每隔几秒就切换一次），反而会带来更差的用户体验。建议的策略是：

- **保持稳定帧率区间**：不要频繁切换
- **仅在明显场景切换时调整**：如从滚动状态切换到阅读状态

### 5.3 Flutter 引擎的鸿蒙适配尚未成熟

截至 2026 年中，Flutter 的官方鸿蒙支持仍在完善中。虽然社区版本（如 `ohos_flutter`）已经实现了基本渲染能力，但在 vsync 处理、帧率反馈等底层细节上，与 Android 原生支持仍有差距。这意味着：

- `display.refreshRate` 可能返回不准确的值
- vsync 回调的稳定性可能不如原生平台
- 部分高级帧率控制 API 可能尚未实现

## 6. 总结

LTPO 屏幕为 Flutter 应用在鸿蒙设备上提供了优化功耗的潜力，但真正发挥其价值需要从多个层面入手：

1. **基础层面**：确保应用在空闲时停止帧请求，不浪费无谓的渲染
2. **策略层面**：根据用户交互状态动态调整动画精细度
3. **平台适配**：通过 Platform Channel 获取鸿蒙原生刷新率信息
4. **认知边界**：理解 LTPO 是系统级特性，应用层的影响有限，合理预期

最重要的是，不要为了"适配 LTPO"而过度设计。Flutter 默认的按需渲染机制已经能自动适应大部分场景。真正需要关注的反而是那些**不必要但持续运行的动画**——比如后台的循环动画、未正确 dispose 的 `AnimationController`、以及不必要的 `setState` 导致的重复渲染。

与其追求"动态帧率"，不如先确保应用在帧率管理上不出错。

---

## 参考资料

- [Flutter Display class - API Reference](https://api.flutter.dev/flutter/dart-ui/Display-class.html)
- [Flutter Rendering Performance](https://docs.flutter.dev/perf/rendering)
- [OpenHarmony DisplayManager](https://gitee.com/openharmony/interface_sdk-js/blob/master/api/@ohos.display.d.ts)
- [HarmonyOS Display 开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/display-arkts)
- [LTPO Display Technology - Samsung Display](https://www.samsungdisplay.com/tech/ltpo)
- [Flutter Engine - Vsync Waiter](https://github.com/flutter/engine/tree/main/shell/common/vsync_waiter)