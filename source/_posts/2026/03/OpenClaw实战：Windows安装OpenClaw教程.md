
---
title: OpenClaw实战：Windows安装OpenClaw教程
date: 2026-03-12 11:00:08
tags: [OpenClaw实战, OpenClaw, 龙虾, AI]
categories: [AI, 开发工具]
---

# Windows 安装 OpenClaw 完整教程

## 前言

OpenClaw 是一款强大的 AI 助手框架，支持多种模型接入、技能扩展和消息通道集成。本文将在 Windows 平台上详细介绍 **两种安装方案**：原生安装和 WSL2 安装。

> 💡 **提示**：推荐优先使用 WSL2 方案，获得更好的 Linux 兼容性和更少的依赖问题。

无论你是 AI 开发者还是技术爱好者，本教程将帮助你快速搭建 OpenClaw 环境。更多资源请访问 [OpenClaw 官方文档](https://docs.openclaw.ai) 和 [OpenClaw 中文社区](https://openclaws.io/zh/)。

## 一、安装前准备

### 1.1 系统要求

在开始安装之前，请确保你的系统满足以下要求：

| 要求项 | 最低配置 | 推荐配置 |
|--------|----------|----------|
| 操作系统 | Windows 10 64 位 | Windows 11 64 位 |
| 内存 | 8GB | 16GB+ |
| 磁盘空间 | 5GB | 10GB+ |
| Node.js 版本 | 22.x | 22.x LTS |
| PowerShell 版本 | 5.1 | 7.x |

### 1.2 网络环境

由于部分依赖需要从 GitHub 和 npm 下载，建议确保网络连接稳定。如遇下载缓慢，可配置以下 **国内镜像**：

```Powershell
# 配置 npm 淘宝镜像
npm config set registry https://registry.npmmirror.com
```

```Powershell
# 配置 Git 代理（如需要）
git config --global http.proxy http://127.0.0.1:7890
```

## 二、原生安装方案

### 2.1 安装 Chocolatey 包管理器

Chocolatey 是 Windows 上的软件包管理器，可以简化依赖安装流程。

**步骤 1**：使用 **管理员权限** 打开 PowerShell

**步骤 2**：运行以下命令安装 Chocolatey：

```Powershell
powershell -c "irm https://community.chocolatey.org/install.ps1|iex"
```

**步骤 3**：验证安装是否成功：

```Powershell
choco -v
```

> ⚠️ **注意**：如果安装失败，请检查 PowerShell 执行策略设置。

### 2.2 安装核心依赖

使用 Chocolatey 一次性安装所需的核心工具：

```Powershell
choco install git nodejs python -y
```

安装完成后，验证各组件版本：

| 工具 | 验证命令 | 预期输出 |
|------|----------|----------|
| Git | `git --version` | git version 2.x.x |
| Node.js | `node -v` | v22.x.x |
| Python | `python --version` | Python 3.x.x |
| npm | `npm -v` | 10.x.x |

### 2.3 安装 Visual Studio Build Tools

OpenClaw 的部分原生模块需要 C++ 编译环境。

**步骤 1**：打开 Visual Studio Installer

```Powershell
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe
```

**步骤 2**：选择 **修改** Build Tools 2022

**步骤 3**：勾选以下工作负载：

- ✅ Desktop development with C++（桌面 C++ 开发）
- ✅ Windows 10/11 SDK

![Visual Studio 安装界面](https://blog.shaohushuo.com/images/2026/03/image.png)

![选择 C++ 开发组件](https://blog.shaohushuo.com/images/2026/03/image-1.png)

> 💡 **提示**：安装过程可能需要 10-20 分钟，请耐心等待。

### 2.4 安装 OpenClaw

所有依赖准备就绪后，使用 npm 全局安装 OpenClaw：

```Powershell
npm i -g openclaw
```

验证安装：

```Powershell
openclaw --version
```

## 三、WSL2 安装方案（推荐）

### 3.1 启用 WSL2 功能

**步骤 1**：以管理员身份打开 PowerShell

![管理员 PowerShell](https://blog.shaohushuo.com/images/2026/03/image-3.png)

**步骤 2**：启用 WSL 功能：

```Powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

**步骤 3**：启用虚拟机平台：

```Powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**步骤 4**：重启计算机后，设置 WSL2 为默认版本：

```Powershell
wsl --set-default-version 2
```

### 3.2 安装 Linux 发行版

从 Microsoft Store 安装 Ubuntu 22.04 LTS 或其他发行版，然后初始化：

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y
```

```bash
# 安装基础工具
sudo apt install -y curl git build-essential
```

### 3.3 配置 PowerShell 执行策略

在 Windows PowerShell 中允许脚本执行：

```Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3.4 一键安装 OpenClaw

运行官方安装脚本：

```Powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -Tag beta
```

![OpenClaw 安装过程](https://blog.shaohushuo.com/images/2026/03/image-2.png)

### 3.5 验证安装

安装完成后，确认 OpenClaw 可用：

```Powershell
openclaw --version
```

![安装成功验证](https://blog.shaohushuo.com/images/2026/03/openclaw-install-success.png)

## 四、首次运行与初始化

### 4.1 启动 Onboarding 流程

首次运行需要完成初始化配置：

```Powershell
openclaw onboard
```

该命令将引导你完成：

1. 模型提供商配置
2. API 密钥设置
3. 消息通道绑定
4. 技能库初始化

### 4.2 启动 Dashboard

打开 Web 控制台查看运行状态：

```Powershell
openclaw dashboard
```

默认访问地址：`http://localhost:3000`

## 五、常用命令速查

### 5.1 配置管理

| 命令 | 说明 |
|------|------|
| `openclaw config` | 编辑配置文件 |
| `openclaw config --validate` | 验证配置语法 |
| `openclaw gateway restart` | 重启网关服务 |

### 5.2 模型与技能

```Powershell
# 查看可用模型列表
openclaw models list
```

```Powershell
# 查看已安装技能
openclaw skills list
```

```Powershell
# 安装新技能
openclaw skills install <skill-name>
```

### 5.3 交互式对话

启动终端 UI 进行对话：

```Powershell
openclaw tui
```

### 5.4 通道管理

查询已配置的消息通道：

```Powershell
openclaw channels list
```

```Powershell
# 测试通道连接
openclaw channels test <channel-name>
```

## 六、常见问题排查

### 6.1 npm 安装失败

**问题**：`npm ERR! code EACCES`

**解决方案**：

```Powershell
# 清理 npm 缓存
npm cache clean --force

# 使用管理员权限重新安装
npm i -g openclaw --force
```

### 6.2 PowerShell 脚本执行被阻止

**问题**：`running scripts is disabled on this system`

**解决方案**：

```Powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 6.3 WSL2 网络问题

**问题**：WSL2 中无法访问外网

**解决方案**：

```bash
# 在 WSL2 中配置 DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

> 📌 **参考**：更多问题请查阅 [OpenClaw 故障排除文档](https://docs.openclaw.ai/troubleshooting)

## 七、下一步学习

安装完成后，你可以继续探索：

- 📖 阅读 [快速入门指南](https://docs.openclaw.ai/quickstart)
- 🔧 配置你的第一个 [AI 模型](https://docs.openclaw.ai/models)
- 🎯 编写自定义 [技能](https://docs.openclaw.ai/skills)
- 💬 集成 [消息通道](https://docs.openclaw.ai/channels)（Telegram/Discord/微信等）

## 总结

本文详细介绍了在 Windows 平台上安装 OpenClaw 的两种方案。**原生安装**适合纯 Windows 环境用户，**WSL2 方案**则提供更好的兼容性和性能。

根据你的使用场景选择合适的方案，开始你的 AI 助手开发之旅吧！

---

**相关资源：**

- [OpenClaw 官方网站](https://openclaw.ai/)
- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [OpenClaw 中文社区](https://openclaws.io/zh/)
- [GitHub 仓库](https://github.com/openclaw/openclaw)
- [Discord 社区](https://discord.com/invite/clawd)
- [npm 包页面](https://www.npmjs.com/package/openclaw)
- [ClawHub 技能市场](https://clawhub.com)
- [CSDN 社区](https://openharmonycrossplatform.csdn.net)

---

> 如果这篇文章对你有帮助，欢迎点赞👍、收藏⭐、关注🔔，你的支持是我持续创作的动力！