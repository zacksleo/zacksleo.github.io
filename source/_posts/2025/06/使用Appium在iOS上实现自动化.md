---
title: 使用Appium在iOS上实现自动化
date: 2025-06-04 17:46:02
tags: [appium, ios]
---

## 安装 Appium

```bash
npm install -g appium
```

检测 Appium 是否安装成功

```bash
appium --version
```

安装 Appium Doctor


```bash
npm install appium-doctor -g
```

安装 ios 测试驱动

```bash
appium driver install xcuitest
```

检测 iOS 环境是否正常

```bash
appium-doctor --ios
```

安装 ideviceinstaller

```bash
brew install ideviceinstaller
```

## 查询设备 udid

使用 USB 链接好 iPhone，使用以下命令查询设备 udid

```bash
idevice_id -l
# 例如，这些输出以下内容：
# 00000030-0018581E1E43402E
```

## 安装 WebDriverAgent


[WebDriverAgent](https://github.com/appium/WebDriverAgent) 是一个用于测试 iOS 应用的开源项目，它提供了一套完整的测试工具，用于测试 iOS 应用，最早由 facebook 开发，目前由appium 社区维护。

### 下载&签名

打开 WebDriverAgent 仓库下载源码到本地，并进入到 WebDriverAgent 目录下，使用 Xcode 打开 WebDriverAgent.xcodeproj 文件，对项目重新签名。

打开项目，在 Targets -> WebDriverAgentRunner -> General -> Signing -> Team，修改 Bundel Identifier, 解决重名问题，

Team 选择自己或者加入的团队，勾选  Automatically manage signing。


Targets 下的其他几个，如 WebDriverAgetLib, 也执行同样操作。

![alt text](images/2025/06/04/image-1.png)

### 运行

在 Xcode 中，中间顶部，左侧选择 WebDriverAgentRunner，右侧选择运行的设备，然后点击 Products -> Test。

![alt text](images/2025/06/04/image-4.png)

此时将在手机上安装 WebDriverAgentRunner App，

首次运行会出现以下错误提示：

`Unable to launch com.facebook.WebDriverAgentRunner.zacksleo.xctrunner`, 如图所示

![alt text](images/2025/06/04/image-5.png)



这是因为私有证书需要在手机上勾选允许，然后进入手机“设置”，打开 “通用”，找到“VPN与设备管理”，最下方找到 “开发者APP” 下面的证书，点开后选择信任 Apple Development:...，弹窗选择信任。

打开刚安装的这个名为 WebDriverAgentRunner 的 App，启动客户端代理，然后在电脑命令行中运行 Appium，启动 Appium 服务。

```bash
appium
```

编写测试代码，运行测试用例：

```bash
node test.js
```

## 参考资料

- [IOS + Appium自动化教程](https://www.cnblogs.com/crstyl/p/14690895.html)
- [2022年appium超详细环境安装步骤](https://blog.csdn.net/weixin_36192992/article/details/123645828)
- [Appium 快速入门介绍](https://appium.io/docs/zh/2.19/quickstart/)