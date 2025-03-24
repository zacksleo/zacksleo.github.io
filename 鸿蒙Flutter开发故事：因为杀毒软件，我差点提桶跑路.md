---
title: 鸿蒙Flutter开发故事：因为杀毒软件，我差点提桶跑路
date: 2025-03-04 13:55:57
tags: [鸿蒙, Flutter, 鸿蒙开发故事]
---

大家好，[《鸿蒙Flutter实现实战》](https://gitee.com/zacks/awesome-harmonyos-flutter "《鸿蒙Flutter实现实战》")推出以来，得到不少小伙伴的好评，最近我们也在和华为开发者联盟合作，以期把这个系列做成最佳实践，在论坛推荐给更多需要的开发者。

教程是有了，但在实际操作过程中，总是会遇到各种意想不到的问题和挑战，有些甚至和语言、SDK无关，特别是配置环境，需要我们对自己的电脑操作系统有更深的了解，诸如环境变量怎么生效这样的问题。

本系列则是对实战的补充，通过具体的案例，描绘问题的排查和解决过程，记录下来也希望对下一个“受害者”有用。

本期受害者叫小天，起初是通过闲鱼找到我，攀谈半天发现他已经是公众号粉丝，这不大水冲了龙王庙么，于是果断邀他扫码入群，开远程协助调研现场。以下是整个问题的排查过程：

小天说安装好 flutter_flutter 以后，运行 app 出错，出错内容如下：

![](https://files.mdnice.com/user/84510/1a31e54d-81d3-49af-85a3-252482c2f6df.jpg)


看起来一头雾水，于是我让他检查下环境，使用
`flutter doctor` 查看出现如下错误:


![](https://files.mdnice.com/user/84510/9778f67c-f62f-40da-a31b-7bdbf9a21dd6.png)


看起来像是在 Dart 版本不对，经过询问发现，小天发现了 dart-sdk 是空的，于是手动复制了一份，查看错误输出，初步判断 dart-sdk 不匹配导致出错。那么问题来了，为什么目录为空？

![](https://files.mdnice.com/user/84510/9c70581d-e81e-47d9-b94c-332d0f86aa6f.png)


我们按照[环境配置指南](https://gitee.com/zacks/awesome-harmonyos-flutter/blob/master/%E9%B8%BF%E8%92%99%20Flutter%20%E5%AE%9E%E6%88%98/%E9%B8%BF%E8%92%99Flutter%E5%AE%9E%E6%88%98%EF%BC%9A01-%E6%90%AD%E5%BB%BA%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83.md "环境配置指南")重新安装 sdk，使用 git 克隆 Flutter 的 dev 分支之后，运行时 `flutter --version` 命令，起初，输出朝着期望的方式进行，但经过短暂 Flutter engine 下载之后，出现一堆红色错误，仔细查看错误原因，dart-sdk 竟然是空的？！

![](https://files.mdnice.com/user/84510/ae28ee68-c33a-4bff-a46b-002f6b855e6d.jpg)


此时退出命令，再次运行 `flutter doctor`，这次的输出不一样了

![](https://files.mdnice.com/user/84510/b871ff36-029d-489d-91f8-aaf0b37489fb.png)


按照[网上的提示](https://blog.csdn.net/weixin_44692055/article/details/109774822 "Error: Unable to ‘pub upgrade‘ flutter tool")，这时需要手动清理 cache，打开 Flutter 安装目录，删除 `bin/cache` 目录，重新运行，发现，又回到了第一次的情形。

经多几分钟的摸索和分析，我决定尝试手动处理缺失的 dart-sdk，按照命令输出的 url，手动下载解压，复制到 Flutter 目录下的 cache/dart-sdk，现在看看是否能用呢？


![](https://files.mdnice.com/user/84510/7a810901-7e47-4df7-b8b6-38afd0df3dc8.jpg)


Bingo！已经开始下载编译套件，成功近在咫尺了。

`flutter doctor` 检查通过，接下来按照正常流程运行，不过又有新的问题出现:


![](https://files.mdnice.com/user/84510/fcc943c5-7d15-49c9-a15b-59434c921ab6.png)


在这个过程中，杀毒软件频频弹窗，好家伙，竟然是你小子！

Flutter 在安装初始化和编译时会下载和生成大量文件，这就导致监控磁盘的杀软误报，这里必须要点击允许，不要因为忽略而关掉告警，否则无法往下进行。

第一次在鸿蒙设备上运行 Flutter，会下载鸿蒙相关的依赖套件，控制台输出 `downloading ohos-x64/arm64...`，需要耐心等待。

![](https://files.mdnice.com/user/84510/5ffc3698-e258-4dbd-bacf-b72f210893f1.png)


最终，经过比较漫长的编译等待，熟悉的画面在真机上出现了，完美收官。


本来以为故事到这就结束了，第二天，小天又传来消息，事态升级，发来一张截图，打开一看直接无语了

![](https://files.mdnice.com/user/84510/fcee6c43-d2ec-4dbe-815d-93b942c6527c.png)


这回杀毒软件直接把 Dart SDK 当成病毒清理了，好吧，这回除了卸载软件，也没啥好办法了。


以上就是本次 Windows 电脑下安装鸿蒙 Flutter 的一次冒险了，忙活大半天，一度陷入自我怀疑和沮丧，终其原因，竟然是杀毒软件拦截的锅，知道真相后，小天觉得自己又行了。那么，你是否也遇到过类似的遭遇呢，欢迎在评论区或者私信分享你的故事。

