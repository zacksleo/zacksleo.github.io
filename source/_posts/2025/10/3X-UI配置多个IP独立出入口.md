---
title: 阿里云轻量应用服务3IP实战：3X-UI配置多个IP独立出入口
date: 2025-10-29 11:15:26
tags: [阿里云, 轻量应用服务器, 3IP, 3X-UI]
---

## 背景

阿里云轻量应用服务器 3IP，默认情况下，三个 IP 地址是共享同一个入出口的，如果需要实现多个 IP 独立出入口，可以通过 3X-UI 来实现。

如果需要配置多个 IP 独立出入口，可以通过 3X-UI 来实现， 本文以 3 IP 为例，进行配置，如果是其他数量的 IP，也是类似的操作。

首先在阿里云轻量应用服务器控制台，查看 3 个 IP 地址对应的内网 IP 地址：

![alt text](/image/2025/10/29/image-4.png)

3IP 绑定的 IP 内网地址是 172.21.0.42，172.21.0.48，172.21.0.73。

## 安装 3X-UI

使用 root 账号登录服务器，执行以下命令安装 [3X-UI](https://github.com/MHSanaei/3x-ui/blob/main/README.zh_CN.md)：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

```

安装成功后，查询端口和账号密码，如果找不到密码，可以使用重置功能 ：

执行以下命令，唤出菜单，选择 3. Reset Username & Password, 将输入地址、账号和密码

```bash
3x-ui
```

## 添加入站规则

添加前确保先在防火墙处把端口打开，可以选择全开，也可以按需添加

![alt text](/image/2025/10/29/image.png)

添加时需要注意，监听需要输入内网 IP 地址，不能使用外网 IP

![alt text](/image/2025/10/29/image-1.png)

按照上面的方式，添加 3 个入站规则，每个规则都使用不同的内网 IP 地址，这里的配置规则如下

![alt text](/image/2025/10/29/image-2.png)

备注即每个IP对应的内网 IP 地址

## 配置出站规则

打开 Xray 设置中的出站规则

![alt text](/image/2025/10/29/image-3.png)


选择出站规则，添加三个出站规则，分别按下图所示添加，注意，发送通过中需要使用自己服务器实际的三个内网 IP 地址

出站规则 1：

![alt text](/image/2025/10/29/image-5.png)

出站规则 2：

![alt text](/image/2025/10/29/image-6.png)

出站规则 3：

![alt text](/image/2025/10/29/image-7.png)

## 配置路由规则

添加完入站规则和出站规则后，需要配置路由规则，才能将入站请求转发到对应的出站规则，同样在Xray设置中的路由规则，添加下面三条路由规则

> 注意: 入站规则的 Tag 格式为： inbound-内网IP:端口号，例如本文中的第一个入站规则的 Tag 为 inbound-172.21.0.42:27762

路由规则 1：

![alt text](/image/2025/10/29/image-8.png)

InBoundTags 填写入站规则的Tag,本例中为 inbound-172.21.0.42:27762, Outbound Tag 为上面出站规则则设置的 Tag，本文这里面为 ip1

路由规则 2：

![alt text](/image/2025/10/29/image-9.png)

InBoundTags 填写入站规则的Tag,本例中为 inbound-172.21.0.48:44061, Outbound Tag 为上面出站规则则设置的 Tag，本文这里面为 ip2

路由规则 3：

![alt text](/image/2025/10/29/image-10.png)

InBoundTags 填写入站规则的Tag,本例中为 inbound-172.21.0.73:36274, Outbound Tag 为上面出站规则则设置的 Tag，本文这里面为 ip3

配置成功后，在Xray 设置页面，点击红色按钮，重启Xray 服务


## 测试

这里面需要注意的是，无论是通过二维码，还是复制 URL 导入客户端，都需要手动修改客户端的连接配置，将内网 IP 地址，改成对应的公网 IP 地址，否则无法连接。

在入站列表处，点击菜单中的导出链接，复制，然后粘贴导入客户端

![alt text](/image/2025/10/29/image-11.png)


打开客户端中的服务器设置，进入修改页面，将内网 IP 地址，改成对应的公网 IP 地址：

![alt text](/image/2025/10/29/image-12.png)


## 参考资料

- [3x-ui](https://github.com/MHSanaei/3x-ui/blob/main/README.zh_CN.md)