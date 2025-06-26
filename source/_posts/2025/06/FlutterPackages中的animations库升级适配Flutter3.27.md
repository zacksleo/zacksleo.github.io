---
title: FlutterPackages中的animations库升级适配Flutter3.27
date: 2025-06-27 00:50:02
tags: [HarmonyOS, Flutter]
---

Flutter 3.27 支持的 Dart 版本为 3.6，本文说明如何将 TPC中的 animations 库升级适配Flutter 3.27

升级步骤：

1. 找到上有 animations 库的最新版本及源码，并下载至本地解压

打开 https://github.com/flutter/packages，点击 Doanlowd Zip，解压到本地。

2. 克隆 TPC 中的 flutter_packages 仓库

克隆之前我们先 Fork 一份仓库至自己的组织中，以便后续提交 PR 使用。克隆成功后，将 Fork 后的仓库克隆至本地

```bash
git clone https://gitcode.com/nutpi/flutter_packages.git
```

3. 新建一个分支

按照命名规则，新建分支为：`br_animations-v2.0.11_ohos`

4. 将解压的 animations 中的文件同步覆盖到 TPC 中的 flutter_packages/animations 文件夹下

需要注意的是，这里需要逐个文件覆盖，需要保留 TPC 仓库中的 ohos 相关文件目录

5. 测试代码

5.1 打开 example 目录，首先对 ohos 项目进行签名配置

5.2 使用 Deveco 打开 example/ohos 目录，然后修改配置签名

5.3 运行 lib/main.dart 代码，测试功能是否正常


6. 提交代码至自己的组织中

7. 提交 PR