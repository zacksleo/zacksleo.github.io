---
title: 使用Git和Gollum搭建Wiki系统
date: 2017-03-13 01:22:09
tags:
---

[Gollum](https://github.com/gollum/gollum)是一个开源的Wiki系统, 该系统基于Git, 支持 Markdown, RDoc 等多种排版格式.

下面是在搭建的过程中经常会遇到一些问题

## UTF-8 问题

+ 安装 `gollum-rugged_adapter`
+ 通过参数 `--adapter rugged` 启动gollum

```
sudo apt-get install cmake
sudo gem install gollum-rugged_adapter
gollum --adapter rugged

```

## 如何设置只读

启动Gollum时, 设置 `--no-edit` 来禁止编辑


## 使用 Docker

使用Docker 安装gullum的内容见 [gollum](http://zacksleo.github.io/2017/03/11/gollum/)