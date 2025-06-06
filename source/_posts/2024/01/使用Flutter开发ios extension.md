---
title: 使用Flutter开发ios app extension
subtitle: Flutter开发ios App扩展
date: 2024-01-10 08:26:06
tags: [Flutter,ios,extension]
---

## Flutter 开始支持App扩展

Flutter从3.16开始，支持在应用扩展中使用Flutter，具体操作可以参考官方文档。


## 注意事项

### 配置

1. App extension 与原App是两个独立的项目/进程，无法直接相互调用，代码也不共享
2. 如果需要共享资源，如存储等，需要配置 App Group，否则不需要
3. 开发过程中使用的是debug/profile版的Flutter.xcframework，发布时需要手动更改导入的库，改为导入release版的Flutter.xcframework.
profile/release版通过目录 <path_to_flutter_sdk>/bin/cache/artifacts/engine/ios/extension_safe 逐级向上查找，可以找到profile或release相关字样的目录

4. 不同类型的extension内存有限制，模拟器中没有限制。Flutter需要比较多的内存，所以文档中指出，只能在“内存限制不低于100M”的扩展类型中使用Flutter，例如 share extensions 
限制120M,可以使用Flutter；keyboard extension 内存限制为40M，故不可以使用Flutter。


## 参考资料

1. https://flutter.cn/docs/platform-integration/ios/app-extensions

2. [尝试Flutter开发custom keyboard］(https://github.com/zacksleo/flutter-ios-custom-keyboard-extension) 仅能在模拟器运行，真机因内存限制无法运行