---
title: CentOS安装Docker并设置开机启动
subtitle: install-docker-on-centos
date: 2018-12-27 16:31:06
tags: [CentOS,Docker]
---

1. 删除旧版 
```bash
sudo yum remove docker docker-common  docker-selinux  docker-engine
```

2.  安装库
```bash
sudo yum install -y yum-utils  device-mapper-persistent-data  lvm2
```
3. 配置stable repo
```bash
sudo yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo
```
4. 安装
```bash
sudo yum install docker-ce
```
5. 启动
```
sudo systemctl start docker
```

6. 开机启动
```bash
sudo systemctl enable docker
```

7 . hello world
```bash
sudo docker run hello-world
```
