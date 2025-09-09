---
title: Linux内存不足导致无法安装软件的解决办法
date: 2025-09-09 19:32:25
tags: [Linux, 运维实战, 阿里云]
---

## 背景

有些时候，为了节约成本，服务器本身内存比较低，例如 0.5G/1G 内存，那这种情况下，安装一些软件时，可能会因为内存不足而安装失败。

就像这样，更新 yum 时，因为 OOM （内存不足） 直接被 killed 了

```bash
[root@aliyun ~]# yum update
Killed
```

## 解决方法

1. 添加 swap 文件

创建 swap 文件, 这里创建一个 2G 的 swap 文件

```bash
dd if=/dev/zero of=/swapfile bs=1M count=2048
```
2. 设置 swap 文件权限

```bash
chmod 600 /swapfile
```

3. 格式化为 swap 文件

```bash
mkswap /swapfile
```

4. 启动 swap 文件
```bash
swapon /swapfile
```

5. 验证是否生效

```bash
swapon --show
free -h
```

出现以下输出，说明 swap 文件已经生效

```bash
[root@aliyun ~]# swapon --show
NAME      TYPE SIZE USED PRIO
/swapfile file   2G   0B   -2
```
