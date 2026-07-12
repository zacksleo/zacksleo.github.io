---
title: 宝塔运维实战：CentOs7启动PHP7.4失败
date: 2025-07-18 00:29:10
tags: [阿里云, 宝塔运维实战, CentOs7, PHP8]
---

使用宝塔安装PHP7.4后，发现启动失败，保存内容如下显示：

![alt text](https://blog.shaohushuo.com/images/2025/07/18/image.png)

```
/www/server/php/74/sbin/php-fpm: error while loading shared libraries: libsodium.so.23: cannot open shared object file: No such file or directory
```


## 解决方案

### 安装SSH 终端

首先打开软件商店，搜索 SSH，找到宝塔SSH终端，点击安装

![alt text](https://blog.shaohushuo.com/images/2025/07/18/image-1.png)

打开确认弹窗，点击立即安装

![alt text](https://blog.shaohushuo.com/images/2025/07/18/image-2.png)


很快就可以安装成功，我们回到宝塔首页，点击 “宝塔SSH终端1.0”，打开终端页面

![alt text](https://blog.shaohushuo.com/images/2025/07/18/image-3.png)



### 安装确实的软件包


我们首先确实使用的系统版本：

```bash
cat /etc/centos-release
```

输出：

```
CentOS Linux release 7.9.2009 (Core)
```

则说明使用的系统是 CentOS 7.9


接下来我们尝试直接安装 libsodium 包

```bash
sudo yum install libsodium
sudo yum install libsodium-devel
```

如果安装失败，例如出现 mirror 404 错误，类似下面这样：


```
https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/repodata/repomd.xml: [Errno 14] HTTPS Error 404 - Not Found
Trying other mirror.
To address this issue please refer to the below wiki article

https://wiki.centos.org/yum-errors
```

则说明当前系统使用的源有问题，需要修改源，这是因为 CentOS 7 已经停止维护，导致很多镜像源失效。这里我们需要更改源为阿里云镜像源。


进入配置文件目录

```bash
cd /etc/yum.repos.d
# 备份原来的源文件
sudo mv CentOS-Base.repo CentOS-Base.repo.backup
# 下载阿里云的源文件
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```


接下来运行以下命令，以便清理软件源缓存，并重新生成缓存：

```
sudo yum clean all
sudo yum makecache
```

### 安装 libsodium

```bash
sudo yum install epel-release
sudo yum --enablerepo=epel install libsodium libsodium-devel
```

epel-release 是一个扩展源，用于提供一些额外的软件包，如 libsodium。

这里需要注意的是，需要先使用命令 `sudo yum install epel-release` 安装epel源，否则可能会出现以下错误：

```bash
[root@vm yum.repos.d]# yum --enablerepo=epel install libsodium
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
base                                                                        | 3.6 kB  00:00:00
https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/repodata/repomd.xml: [Errno 14] HTTPS Error 404 - Not Found
Trying other mirror.
To address this issue please refer to the below wiki article

https://wiki.centos.org/yum-errors

If above article doesn't help to resolve this issue please use https://bugs.centos.org/.
```

### 关闭 SSH 窗口


![alt text](https://blog.shaohushuo.com/images/2025/07/18/image-4.png)

点击关闭按钮，确认关闭即可。

### 重启 PHP 7.4


回到软件商店，找到PHP 7.4，点击设置，尝试重启即可。


![alt text](https://blog.shaohushuo.com/images/2025/07/18/image-5.png)


这里展示的是 PHP 8.4 的 设置界面，重启逻辑是一样的。