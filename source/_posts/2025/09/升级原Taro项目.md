---
title: 鸿蒙 Taro 实战：升级原 Taro 项目到 4.x
date: 2025-09-10 17:32:09
tags: [鸿蒙Taro实战, 鸿蒙, Taro]
---
## 背景

原项目使用 Taro 2.x 版本开发，现需要升级到 Taro 4.x 版本。

## 升级步骤

1. 安装新版本 Taro-cli

```bash
npm install -g @tarojs/cli --force
```

这里面需要注意添加 --force 参数，否则可能出现以下错误：

```txt
npm error code EEXIST
npm error path /usr/local/bin/taro
npm error EEXIST: file already exists
npm error File exists: /usr/local/bin/taro
npm error Remove the existing file and try again, or run npm
npm error with --force to overwrite files recklessly.
npm notice
npm notice New major version of npm available! 10.8.2 -> 11.6.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.6.0
npm notice To update run: npm install -g npm@11.6.0
npm notice
npm error A complete log of this run can be found in: /Users/zacksleo/.npm/_logs/2025-09-10T09_02_58_916Z-debug-0.log
```

2. 升级项目依赖

进入项目目录，执行以下命令：

```bash
taro update project
```


```bash
[2/4] Fetching packages...
⚠ error Error: certificate has expired
    at TLSSocket.onConnectSecure (node:_tls_wrap:1677:34)
    at TLSSocket.emit (node:events:524:28)
    at TLSSocket._finishInit (node:_tls_wrap:1076:8)
    at ssl.onhandshakedone (node:_tls_wrap:862:12)
info Visit https://yarnpkg.com/en/docs/cli/install for documentation about this command.
```



## 参考资料

- [安装及使用](https://docs.taro.zone/docs/GETTING-STARTED)
- [升级命令](https://docs.taro.zone/docs/GETTING-STARTED#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)