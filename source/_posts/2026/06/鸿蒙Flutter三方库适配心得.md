---
title: 鸿蒙Flutter三方库适配心得
date: 2026-06-03 20:00:00
tags: [HarmonyOS,Flutter,鸿蒙Flutter实战,三方库适配]
author: 少湖
---

随着鸿蒙生态的逐步发展和完善，越来越多的 Flutter 开发者开始将自己的应用移植到鸿蒙平台。然而，Flutter 生态中的大量第三方插件并不原生支持鸿蒙。在实际开发中，我们需要对这些插件进行鸿蒙化适配。

本文将系统性地总结 Flutter 三方插件鸿蒙化的**四种适配思路**，并针对每种思路给出真实案例加以说明，重点阐述每种思路的架构思想和决策逻辑。

## 前置知识：Flutter 插件的消息路由机制

在讨论适配之前，先理解一个核心机制。

一个 Flutter 插件的本质是 Dart 层与原生层的通信通道，这套通信通过 **MethodChannel** 来实现。Dart 端通过一个字符串名称（channel name）发起调用，引擎将其路由到当前平台注册的处理器：

```
Flutter App (Dart)
    │
    └─ MethodChannel('channel_name')
           │
           ▼
    原生平台层 ─┬─ Android (Java/Kotlin)
               ├─ iOS (Objective-C/Swift)
               └─ OHOS (HarmonyOS 还需要实现)
```

**Channel name 是路由的唯一凭据**。无论使用哪个平台，只要 channel name 一致，Dart 端发起的调用就能到达正确的原生处理器。HarmonyOS 的 Flutter SDK（`flutter_ohos`）完全兼容这套机制，只是原生层使用 ArkTS 语言。

---

## 四种适配思路概览

| 适配思路 | 本质策略 | 维护成本 | 典型案例 |
|---------|---------|---------|---------|
| 思路一：独立仓库 | 完全重写，与原插件无关系或没有原插件 | 高 | [holding](https://pub-web.flutter-io.cn/packages/holding) |
| 思路二：Fork 修改 | 在原仓库中新增 ohos 目录 | 中 | [flutter_packages](https://gitcode.com/openharmony-tpc/flutter_packages) |
| 思路三：联合插件 | 原已是联合架构，新增平台实现包 | 低 | 已整合：[screen_brightness_ohos](https://pub-web.flutter-io.cn/packages/screen_brightness_ohos)<br>未整合：[wakelock_plus_ohos](https://pub-web.flutter-io.cn/packages/wakelock_plus_ohos) |
| 思路四：联合插件理念 | 普通插件按联合思路拆出 ohos 包 | 低 | [app_set_id_ohos](https://pub-web.flutter-io.cn/packages/app_set_id_ohos) |

---

## 思路一：独立仓库

### 架构思想

完全脱离原插件，创建一个全新 Flutter 插件工程。Dart API 由自己定义，MethodChannel 由自己创建，ArkTS 原生代码自己实现，**与原插件没有任何依赖关系**。

### 典型案例：[holding](https://pub-web.flutter-io.cn/packages/holding)

`holding` 是一个 Flutter 握持手感知插件，支持 HarmonyOS/OpenHarmony，用于订阅握持手状态变化（未握持 / 左手 / 右手 / 双手 / 未识别）。

查看其发布信息：

| 项目 | 内容 |
|------|------|
| 版本号 | 0.0.1 |
| 原生平台 | 仅 ohos |
| 源码组织 | 独立仓库，从头开发 |

该插件为鸿蒙场景**从零构建**，没有参考或依赖任何现有的 Flutter 社区插件。其 `pubspec.yaml` 中只声明了 ohos 平台：

```yaml
flutter:
  plugin:
    platforms:
      ohos:
        pluginClass: HoldingPlugin
```

这意味着它没有任何 Android、iOS、Web 等平台的实现 —— 这是一个只服务于鸿蒙设备的专有插件。

### 适用场景

- 原插件已废弃或不存在（鸿蒙独有功能，社区没有对应的 Flutter 插件）
- 插件功能是鸿蒙/OpenHarmony 特有的（如握持手感知、分布式能力等）
- 需要完全掌控 API 设计
- 插件实现简单，重写成本低

### 决策逻辑

```
业务功能在 Flutter 社区是否有对应插件？
    ├─ 否（鸿蒙独有功能）→ 思路一
    └─ 是 → 继续看其他思路
```

---

## 思路二：Fork 原仓库，添加 ohos 目录

### 架构思想

Fork 原插件的仓库，在仓库中新增 `ohos/` 目录并编写 ArkTS 代码，同时在 `pubspec.yaml` 中添加 ohos 平台声明。Dart 层代码不修改。

```
原仓库 (Fork)
    ├─ lib/       ← 不动，完全保留原插件的 Dart API
    ├─ android/   ← 不动
    ├─ ios/       ← 不动
    └─ ohos/      ← 新增，写 ArkTS 原生代码
```

关键在于 Dart 层中原有的 MethodChannel 名称保持不变。引擎在 ohos 平台运行时会自动路由到新增的 ArkTS 处理器，用户代码零修改。

### 典型案例：[OpenHarmony-tpc/flutter_packages](https://gitcode.com/openharmony-tpc/flutter_packages)

OpenHarmony 社区维护了一系列 Flutter 社区插件的 Fork 适配。该项目基于 Flutter 社区插件库进行 OpenHarmony 兼容适配，采用的就是**在原仓库中添加 ohos 目录**的模式。

其工作方式如下：

```
flutter_packages (Fork 仓库)
    ├─ packages/
    │   ├─ shared_preferences/
    │   │   ├─ lib/         ← 原样保留
    │   │   ├─ android/     ← 原样保留
    │   │   ├─ ohos/        ← 新增：ArkTS 实现
    │   │   └─ pubspec.yaml ← 新增 ohos 平台声明
    │   ├─ connectivity_plus/
    │   │   ├─ lib/
    │   │   ├── ohos/       ← 新增
    │   │   └─ ...
    │   └─ ... (众多插件)
```

使用者通过 git 依赖引入：

```yaml
dependencies:
  shared_preferences:
    git:
      url: https://gitcode.com/openharmony-tpc/flutter_packages.git
      path: packages/shared_preferences
```

这种模式的优势是一次性 Fork 整个 [flutter/packages](https://github.com/flutter/packages) 仓库，可以同时对多个社区插件做适配，形成"一站式"的鸿蒙插件解决方案。

### 适用场景

- 原插件活跃维护、质量良好
- 需要在多个插件上同时开展适配工作
- 乐于接受通过 git 依赖引入（而非 pub.dev）

### 核心局限

Fork 分支与上游存在长期同步压力。原插件发布新版本时，Fork 分支需要手动合并，期间可能产生冲突，维护成本随时间递增。

### 决策逻辑

```
是否有能力长期维护 Fork 分支与上游的同步？
    ├─ 是，且有多个插件需要一次性适配 → 思路二
    └─ 否，或只适配少数插件 → 思路三或四
```

---

## 思路三：联合插件

### 架构思想

联合插件（Federated plugins）是 Flutter 官方推荐的插件架构，将一个插件拆为三类独立包：

```
xxx_plugin/                    ← 面向应用的接口（用户直接使用）
xxx_platform_interface/        ← 抽象接口定义
xxx_android/                   ← Android 实现
xxx_ios/                       ← iOS 实现
xxx_ohos/                      ← 鸿蒙实现（新增）
```

当原插件已经是联合插件架构时，新增一个 `xxx_ohos` 包即可，它作为 ohos 平台实现注册到主包中。

这个场景下又分两种具体情况。

### 情况一：已整合至主包

ohos 实现已被主包接纳，成为官方认可的正式平台。

#### 典型案例：[screen_brightness_ohos](https://pub-web.flutter-io.cn/packages/screen_brightness_ohos)

`screen_brightness_ohos` 是 `screen_brightness` 插件的鸿蒙平台实现。查看它的依赖关系：

```
screen_brightness (v2.1.9) — 主包
    ├─ screen_brightness_platform_interface ← 抽象接口
    ├─ screen_brightness_android
    ├─ screen_brightness_ios
    ├─ screen_brightness_macos
    ├─ screen_brightness_windows
    └─ screen_brightness_ohos (v2.1.3)   ← 被主包自动引入
```

关键看主包 `screen_brightness` 的 `pubspec.yaml`：

```yaml
# screen_brightness/pubspec.yaml
dependencies:
  screen_brightness_platform_interface: ">=2.1.1 <3.0.0"
  screen_brightness_android: ">=2.1.5 <3.0.0"
  screen_brightness_ios: ">=2.1.3 <3.0.0"
  screen_brightness_ohos: ">=2.1.3 <3.0.0"  # 已纳入主包依赖

flutter:
  plugin:
    platforms:
      ohos:
        default_package: screen_brightness_ohos  # 正式注册
```

而 `screen_brightness_ohos` 自身依赖结构为：

```yaml
# screen_brightness_ohos/pubspec.yaml
name: screen_brightness_ohos
dependencies:
  flutter:
    sdk: flutter
  screen_brightness_platform_interface: ">=2.1.1 <3.0.0"  # 依赖平台接口
```

**使用方式极其简单**：用户只需引入主包，ohos 实现会自动被拉取：

```yaml
# 用户只需引入主包
dependencies:
  screen_brightness: ^2.1.9  # 自动包含 ohos 实现
```

这是最理想的状态 —— ohos 已成为主包的一等公民，用户无需感知 ohos 实现包的存在。

---

### 情况二：未整合至主包

ohos 实现包已开发完成并发布到 pub.dev，但尚未被主包接纳为官方平台。

#### 典型案例：[wakelock_plus_ohos](https://pub-web.flutter-io.cn/packages/wakelock_plus_ohos)

`wakelock_plus_ohos` 是 `wakelock_plus` 的鸿蒙实现。但查看主包 `wakelock_plus` 的 `pubspec.yaml`：

```yaml
# wakelock_plus/pubspec.yaml (v1.6.1)
# 列出了 android、ios、windows、macos、linux、web
# 但没有 ohos
```

即鸿蒙实现尚未被主包纳入。使用者需要**手动同时引入两个包**：

```yaml
dependencies:
  wakelock_plus: ^1.6.1           # 主包
  wakelock_plus_ohos: ^0.0.3       # 鸿蒙实现（手动添加）
```

与已整合情况的关键差异：

| 维度 | 已整合 (screen_brightness) | 未整合 (wakelock_plus) |
|------|---------------------------|----------------------|
| 用户依赖 | 只需主包 | 主包 + ohos 包都需要 |
| 可见性 | 用户无感知 | 用户需知道 ohos 包的存在 |
| 升级节奏 | 跟随主包发布 | 需独立跟踪主包版本 |
| 社区采纳 | 已被官方接纳 | 待社区 PR 合入 |

对于未整合的情况，开发者如果能将 ohos 实现合入主包，是最佳路径；如果暂时无法合入，只要在文档中清晰说明依赖方式，用户也能正常使用。

---

## 思路四：基于联合插件理念（普通插件改造）

### 架构思想

大部分 Flutter 插件并非联合插件架构 —— 它们将所有平台实现集成在同一个包内，使用 `pluginClass` 声明各平台。对于这类插件，我们可以借鉴联合插件的理念，创建一个独立的 `xxx_ohos` 包。

这个包的独特设计：

- **不包含 Dart 代码**（或只有一个空壳文件）
- **只包含 ohos 平台的原生实现**
- **MethodChannel 名称与原插件 Dart 层完全一致**
- 通过在 `pubspec.yaml` 中声明 ohos 平台，引擎启动时自动注册

```
Flutter App
    │
    ├─ 依赖原插件 (app_set_id)        ← 用户引入这个
    │     └─ MethodChannel('app_set_id').invoke('getIdentifier')
    │                                       │
    │                                       ▼
    │                              MethodChannel 路由
    │                              ┌──────┬──────┐
    │                              ▼      ▼      ▼
    │                           android  ios   OHOS
    │                                           ↑
    └─ 依赖鸿蒙实现包 (app_set_id_ohos) ─────────┘  ← 只需在yaml声明，不用import
```

核心逻辑：原插件的 Dart 层已经创建了 MethodChannel 并发起调用，ohos 包只需要用**相同的 channel name** 注册一个 ArkTS 处理器即可。用户不需要 `import` 这个包 —— 它只在构建期起作用。

### 典型案例：[app_set_id_ohos](https://pub-web.flutter-io.cn/packages/app_set_id_ohos)

`app_set_id` 是一个用于获取 App Set ID 的 Flutter 插件，它是一个**普通插件**（非联合架构），支持 Android、iOS、macOS、Web 平台，通过 MethodChannel 通信。

`app_set_id_ohos` 针对它做了鸿蒙适配，参见其依赖结构：

```yaml
# app_set_id_ohos/pubspec.yaml
name: app_set_id_ohos
dependencies:
  flutter:
    sdk: flutter

flutter:
  plugin:
    platforms:
      ohos:
        package: nl.u2312.app_set_id
        pluginClass: AppSetIdPlugin
```

与思路三（联合插件）中依赖平台接口不同，这里的 ohos 包**没有依赖 `screen_brightness_platform_interface` 这类抽象接口**，而是直接注册了一个与主包同名的 MethodChannel 处理器。

使用方式：

```yaml
dependencies:
  app_set_id: ^1.4.0      # 主包，提供 API
  app_set_id_ohos: ^1.4.0 # 鸿蒙平台实现
```

```dart
import 'package:app_set_id/app_set_id.dart';  // 只需引入主包

final id = await AppSetId.identifier;  // 调用原插件 API
// 底层自动路由到 app_set_id_ohos 的 ArkTS 实现
```

### 前置条件

**原插件必须使用 MethodChannel 通信**。如果原插件使用了 FFI、PlatformView 或其他非标准通信方式，此方案不适用。

---

## 四种思路架构对比

| 维度 | 思路一 | 思路二 | 思路三（已整合） | 思路三（未整合） | 思路四 |
|------|--------|--------|----------------|----------------|--------|
| **Dart 层** | 重写 | 不动 | 新增实现类 | 新增实现类 | 无 |
| **原生层** | 全量新建 | ohos/ 目录 | 独立 ohos 包 | 独立 ohos 包 | 独立 ohos 包 |
| **用户依赖** | 新插件 | git 引入 | 只需主包 | 主包+ohos包 | 主包+ohos包 |
| **API 兼容** | ❌ 不兼容 | ✅ 兼容 | ✅ 兼容 | ✅ 兼容 | ✅ 兼容 |
| **维护耦合** | 低 | 高（同步上游） | 低 | 中（待整合） | 低 |
| **典型案例** | holding | OpenHarmony fork | screen_brightness_ohos | wakelock_plus_ohos | app_set_id_ohos |

---

## 快速决策指南

在实际开发中，按照以下流程判断：

**第一步：先检查是否有对应插件**

```
Flutter 社区存在对应插件吗？
    ├─ 否 → 思路一（自主开发）
    └─ 是 → 继续
```

**第二步：看原插件 pubspec.yaml**

```
flutter.plugin 下是 default_package 还是 pluginClass？
    ├─ default_package → 联合插件架构 → 思路三
    │      └─ 进一步：ohos 是否已出现在 default_package 列表中？
    │           ├─ 已出现 → 无需适配，直接用
    │           └─ 未出现 → 开发 xxx_ohos → 推 PR 合入
    │
    └─ pluginClass → 普通插件 → 继续第三步
```

**第三步：看原插件 Dart 源码**

```
是否使用 MethodChannel 通信？
    ├─ 是 → 思路四（创建 xxx_ohos 独立包）
    └─ 否（FFI、PlatformView 等）→ 思路二（Fork 添加 ohos 目录）
```

---

## 总结

Flutter 三方插件的鸿蒙化适配，核心逻辑可以归结为一句话：**在不修改原插件 Dart 代码的前提下，为鸿蒙平台提供原生层 MethodChannel 处理器**。

四种思路的本质差异在于原生代码的组织方式和 Dart 代码的修改程度：

- **思路一（独立仓库）**：连 Dart 代码一起重写，适合鸿蒙独有功能
- **思路二（Fork 修改）**：在原仓库内增加 ohos 目录，适合批量适配、短期方案
- **思路三（联合插件）**：原插件已是联合架构时新增平台实现包，最为规范
- **思路四（联合插件理念）**：普通插件借联合插件的理念创建纯原生实现包，最具通用性

在实际项目中，超过 80% 的适配场景可以用**思路三**或**思路四**完成。最关键的判断依据是：确认原插件使用 MethodChannel 作为通信方式，并找到正确的 channel name。

## 参考文档

- [Flutter 联合插件官方文档](https://docs.flutter.cn/packages-and-plugins/developing-packages/#federated-plugins)
- [HarmonyOS Flutter SDK（flutter_ohos）](https://gitee.com/harmonyos_flutter/flutter_ohos)
- [OpenHarmony-tpc/flutter_packages](https://gitcode.com/openharmony-tpc/flutter_packages)
- [screen_brightness_ohos](https://pub-web.flutter-io.cn/packages/screen_brightness_ohos)
- [wakelock_plus_ohos](https://pub-web.flutter-io.cn/packages/wakelock_plus_ohos)
- [app_set_id_ohos](https://pub-web.flutter-io.cn/packages/app_set_id_ohos)
- [holding](https://pub-web.flutter-io.cn/packages/holding)