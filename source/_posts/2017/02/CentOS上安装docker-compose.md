---
title: CentOS上安装docker-compose
subtitle: install-docker-compose-on-centos
date: 2017-02-15 13:42:06
tags: [docker-composer]
---

## 问题 

在安装完 docker 后, 我们常常安装 docker-compose 来简化 docker 的日常维护,
但是由于 GitHub 在国内较慢, 经常安装不了,所以使用 DaoCloud 提供的镜像来快速安装

## 官方的安装方法

1. 安装 docker `yum install docker`
2. 安装 docker-compose

```
$ curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

$ chmod +x /usr/local/bin/docker-compose

```
## 使用DaoCloud镜像安装 docker-compose

1. 安装 docker `yum install docker`
2. 安装 docker-compose
```
$ curl -L https://get.daocloud.io/docker/compose/releases/download/1.11.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

$ chmod +x /usr/local/bin/docker-compose

```

## Docker 镜像加速

由于下载镜像较慢, 可以使用 DaoCloud 提供的镜像对 Docker 进行加速  

```
$ curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://0835afe2.m.daocloud.io

```