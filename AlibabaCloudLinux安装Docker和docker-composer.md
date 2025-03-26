---
title: Alibaba Cloud Linux 安装 doccker和docker-compose
date: 2025-03-26 15:56:35
tags: [阿里云, ECS, CentOS, Docker, docker-compose]
---

## 简介

Alibaba Cloud Linux 是一个基于 CentOS 的 Linux 发行版，它提供了许多高级功能，如云服务器、云数据库、云服务器监控等。Alibaba Cloud Linux 的安装和配置与 CentOS 的安装和配置基本相同，只是需要安装一些额外的软件包。

以下是安装 Docker 和 docker-compose 的步骤：

1. 安装 Docker：

```bash
# 配置 Docker 源
dnf config-manager --add-repo=https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 安装 Docker
dnf -y install dnf-plugin-releasever-adapter --repo alinux3-plus
dnf -y install docker-ce --nobest

# 查询版本号
docker --version
dnf list docker-ce

# 启动并设置 Docker 为开机启动
systemctl start docker
systemctl status docker
systemctl enable docker

# 验证安装
docker ps
```

2. 安装 docker-compose：

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
#将可执行权限赋予安装目标路径中的独立二进制文件
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 验证安装
docker-compose --version
```

# 参考资料

- [安装Docker](https://www.alibabacloud.com/help/zh/ecs/use-cases/install-and-use-docker#9b082cb332wnq)

