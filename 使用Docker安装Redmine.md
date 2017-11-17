---
title: 使用Docker安装Redmine
date: 2016-08-23 18:43:38
tags:
---

### 安装步骤

* 1. 安装部署Docker
>
因为docker对内核版本有要求，所有要先升级系统（linux内核3.0+），这里用的CentOS 7

* 2.拉取镜像  `docker pull sameersbn/redmine:latest`

[docker镜像加速](https://www.daocloud.io/mirror.html#accelerator-doc)

```
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://0835afe2.m.daocloud.io
```

* 3. 安装docker-compose, **“由于网络原因，该步骤可能会下载失败，请尝试多下载几次，或者外挂代理”**

```
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```
修改权限
```
chmod +x /usr/local/bin/docker-compose
```
* 4. 使用compose快速启动 **可以需要外挂**
```
wget https://raw.githubusercontent.com/sameersbn/docker-redmine/master/docker-compose.yml
docker-compose up
```
* 5. 映射数据目录

### 注意事项

* linux内核要最新 3.0+
* redmine默认使用的端口是10083，如果启动成功后，无法打开，使用telnet 远程检测端口访问性，如果不能访问，检查两个方面：1.本机防火墙是否禁用端口（用telnet 检测）；2.运营商/云端是否禁用
* 注意使用volumn命令映射数据存储命令



### 参考链接

* [Docker Compose安装](https://docs.docker.com/compose/install/)
* [Docker安装redmine](https://github.com/sameersbn/docker-redmine)
* [Docker终极指南](http://dockone.io/article/133)