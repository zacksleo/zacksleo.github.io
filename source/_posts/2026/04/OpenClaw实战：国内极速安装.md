---
title: OpenClaw实战：国内极速安装
date: 2026-04-10 23:31:08
tags: [OpenClaw实战, OpenClaw, 龙虾, AI]
---

## 背景

使用官方给出的安装脚本，一键安装时，容易卡在 installing 状态，无法继续往下执行。


```bash
curl -fsSL https://openclaw.ai/install.sh | bash

  🦞 OpenClaw Installer
  Automation with claws: minimal fuss, maximal pinch.

✓ Detected: linux

Install plan
OS: linux
Install method: npm
Requested version: latest

[1/3] Preparing environment
· Node.js not found, installing it now
· Installing Node.js via NodeSource
· Installing Linux build tools (make/g++/cmake/python3)
✓ Build tools installed
✓ Node.js v22 installed
· Active Node.js: v22.22.2 (/usr/bin/node)
· Active npm: 10.9.7 (/usr/bin/npm)

[2/3] Installing OpenClaw
· Git not found, installing it now
✓ Git installed
· Installing OpenClaw v2026.4.9
```

## 解决方案

结束当前进程，通过输出可以看到，除了 OpenClaw, 其他依赖的环境组件已经安装好了，就差安装OpenClaw自身了。

1. 首先，我们使用国内镜像安装 pnpm

```bash
npm install -g pnpm --registry=https://registry.npmmirror.com

```

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-2.png)


2. 接着配置环境

```bash
pnpm setup

source /root/.bashrc
```

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-3.png)

注意，如果不配置环境，使用命令时会出现这样的错误：

```bash
 ERR_PNPM_NO_GLOBAL_BIN_DIR  Unable to find the global bin directory

Run "pnpm setup" to create it automatically, or set the global-bin-dir setting, or the PNPM_HOME env variable. The global bin directory should be in the PATH.
```

2. 然后，我们使用pnpm 安装 OpenClaw

```bash
pnpm install -g openclaw@latest --registry=https://registry.npmmirror.com
```

此时可以看到，OpenClaw快速安装完成


![alt text](https://blog.shaohushuo.com/images/2026/04/10/image.png)



3. 启动配置龙虾

```bash
openclaw onboard --install-daemon
```

其中 --install-daemon 表示安装守护进程，这时候就进入的熟悉的龙虾配置界面了。

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-1.png)


## 参考资料

- [pnpm中文网](https://www.pnpm.cn/installation)
- [OpenClaw 推荐安装方法：三种方式完整指南](https://segmentfault.com/a/1190000047637722)
- [保姆级OpenClaw配置教程](https://zhuanlan.zhihu.com/p/2012494116148244770)