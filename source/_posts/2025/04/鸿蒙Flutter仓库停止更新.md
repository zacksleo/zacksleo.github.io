---
title: 鸿蒙Flutter仓库停止更新
date: 2025-04-16 11:12:23
tags: [鸿蒙, Flutter, HarmonyOS]
---

## 停止更新

熟悉 Flutter 鸿蒙开发的小伙伴应该知道，Flutter 3.7.12 鸿蒙化 SDK 已经在开源鸿蒙社区发布快一年了， Flutter 3.22.x 的鸿蒙化适配一直由[鸿蒙突击队仓库](https://gitee.com/harmonycommando_flutter/flutter)提供，最近有小伙伴反馈已经 2 个多月没有停止更新了，不少人以为停止维护了。

并非如此。

## 迁移合并

Flutter 的鸿蒙适配工作一直在进行，文章[鸿蒙Flutter实战：15-Flutter引擎Impeller鸿蒙化、性能优化与未来](https://blog.csdn.net/zackslee/article/details/144914441) 中详细介绍了适配的工作内容和未来规划，作者在之前的文章[原开源鸿蒙仓库停止更新](https://blog.csdn.net/zackslee/article/details/146475114)中提到，随着开源鸿蒙仓库集体迁移到 [gitcode](https://gitcode.com/openharmony-sig/)，[由鸿蒙突击队维护的3.22.x版本的Flutter SDK](https://gitee.com/harmonycommando_flutter/flutter)也已合并至[开源鸿蒙的Flutter主仓库](https://gitcode.com/openharmony-sig/flutter_flutter)，目前以分支 `3.22.0-ohos` 的形式存在。

至此，Flutter 鸿蒙化工作完成初步整合，两个大版本使用一个仓库同时维护。

## 总结回顾

Flutter 鸿蒙 SDK 仍然活跃，最近的一次更新在4天前。如果需要使用 FVM 安装 3.22 版本的 SDK，可使用以下命令：

```bash
git clone -b 3.22.0-ohos https://gitcode.com/openharmony-sig/flutter_flutter.git custom_3.22.0
```

如果需要使用 FVM 安装 3.7.12 版本的 SDK，可使用以下命令：

```bash
git clone -b br_3.7.12-ohos-1.0.6 https://gitcode.com/openharmony-sig/flutter_flutter.git custom_3.7.12
```

以下是所有涉及 Flutter 鸿蒙化的仓库地址：

- Flutter sdk https://gitcode.com/openharmony-sig/flutter_flutter
- Flutter engine https://gitee.com/openharmony-sig/flutter_engine
- Flutter packages https://gitcode.com/openharmony-sig/flutter_packages
- Flutter sample 示例库 https://gitcode.com/openharmony-sig/flutter_samples

其他  gitee/openharmony-sig 下的三方库，替换域名即可，如 flutter inappwebview 迁移至 https://gitcode.com/openharmony-sig/flutter_inappwebview


另外提一下，也有小伙伴在使用 Flutter 3.7.12 版本，那 SDK 也同样需要切换源地址，更换下域名即可。