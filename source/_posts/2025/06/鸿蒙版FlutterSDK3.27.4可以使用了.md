---
title: 鸿蒙版FlutterSDK3.27.4可以使用了
date: 2025-06-27 00:40:02
tags: [HarmonyOS, Flutter]
---

> 近日，OpenHarmony 社区的 Flutter 仓库创建了 Flutter 3.27.4-dev 分支，这标志着 鸿蒙版 Flutter SDK 3.27 进入开发阶段。

值得注意的是，Flutter 等三方框架从 SIG 组织中分离出来，使用单独的 TPC（Third Party Components）来管理，专门存放开源三方库，代码管理更加清晰，但社区管理上，TPC 仍然由 OpenHarmony SIG 主导。

## 准备工作

这里我们使用 FVM 管理Flutter SDK

首先进入 fvm/versions 目录下，克隆 3.27.4-dev 分支的 flutter_flutter 仓库

```bash
cd ~/fvm/versions
git clone -b oh-3.27.4-dev https://gitcode.com/openharmony-tpc/flutter_flutter.git custom_3.27.4
```

## 切换 Flutter SDK

接下来进入自己的项目，使用 fvm 切换版本

```bash
fvm use custom_3.27.4
```

## 参考资料

- [FVM](https://fvm.app/)
- [Flutter_flutter](https://gitcode.com/openharmony-tpc/flutter_flutter)
