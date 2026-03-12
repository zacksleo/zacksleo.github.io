
---
title: DockerSwarm部署容器服务
date: 2026-01-27 16:39:04
tags: [docker, dockerswarm, 容器]
---

## 环境准备

开通服务器后，安装 Docker CE。如果使用阿里云，可以在购买下单时，选择预装 Docker社区版，如下图所示：

![alt text](/images/2026/01/docker-ce.png)

确认 Docker CE 安装成功

```bash
[root@svc-c2 ~]# docker --version
Docker version 26.1.3, build b72abbb
```

## 初始化

选择一台服务器，作为 Docker Swarm 集群的初始管理节点，并执行如下命令：
```bash
docker swarm init
```

输出结果如下：

```bash
Swarm initialized: current node (p5ejcb359p0etw0hit4krccvs) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-xxx-xxx 192.168.3.200:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

集群管理节点的 IP 地址为 192.168.3.200，端口为 2377, 同时还输出了加入集群的命令，复制该命令，在另一台服务器上执行，即可将该服务器加入集群。
