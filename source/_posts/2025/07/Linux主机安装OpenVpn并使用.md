---
title: Linux主机安装OpenVpn并使用
date: 2025-07-24 16:07:03
tags: [Linux,运维实战,OpenVpn]
---

## 安装OpenVPN

首先使用 SSH 工具登录到 Linux 主机

1. 下载 OpenVPN 安装脚本

```bash
wget -O openvpn.sh https://get.vpnsetup.net/ovpn
```

2. 使用默认配置安装 OpenVPN

```bash
sudo bash openvpn.sh --auto
```

执行成功后，会在当前目录生成一个 `client.ovpn` 文件，这个文件包含了连接 OpenVPN 所需的配置。

## 下载配置文件

1. 复制 `client.ovpn` 文件内容

如果不会使用 scp 等工具，可以直接复制文件内容到本地, 输入以下命令：

```bash
cat client.ovpn
```
这将输出类似这样的内容：

```bash
client
dev tun
proto udp
remote xx.xx.xx.xx 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-128-GCM
ignore-unknown-option block-outside-dns block-ipv6
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUJ3hsR+RpaDUnIPH6YKQOCkkzH3swDQYJKoZIhvcNAQEL
....
4XBkPqW6DL4CpGHxgcit0zZ6GP4SowSfH73amYn85w==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDVTCCAj2gAwIBAgIRAPtV4raZvcox0HwtgWgLfEMwDQYJKoZIhvcNAQELBQAw
....
WrBjhO+hTXno3WUptabjOHK3l8CmJB8ZfVYcoHZuHLjlf505uRLagwg=
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC5Xt/FmWwWRYOJ
.....
CcHdON46VjzosQQoMMAZHw==
-----END PRIVATE KEY-----
</key>
<tls-crypt>
-----BEGIN OpenVPN Static key V1-----
756f90e1fc73346b391e7c946b4e991d
......
4b21fe08ce8e8e5895dc823d15dd7965
-----END OpenVPN Static key V1-----
</tls-crypt>
```

![alt text](/images/2025/07/24/image.png)

注意从 client 这一行开始复制，一直到

```
-----END OpenVPN Static key V1-----
</tls-crypt>
```

结束。

2. 在本地计算机上创建一个 `client.ovpn` 文件，将内容粘贴进去。

## 导入配置文件到 OpenVPN 客户端

1. 将这个 `client.ovpn` 文件导入（拖拽）到 OpenVPN 客户端中


## 生成新的配置文件

一个配置文件只能给一个客户端使用，如果需要给多个客户端使用，那么就需要生成多个配置文件。

SSH 登录主机后，找到脚本 `openvpn.sh` 所在目录，执行以下命令：

```bash
sudo bash openvpn.sh
```

输出以下内容：

```bash
OpenVPN Script
https://github.com/hwdsl2/openvpn-install

OpenVPN is already installed.

Select an option:
   1) Add a new client
   2) Export config for an existing client
   3) List existing clients
   4) Revoke an existing client
   5) Remove OpenVPN
   6) Exit
Option: 1
```

我们需要创建新的客户端，所有输入 1，回车

```bash
Provide a name for the client:
Name:
```
输入新的客户端名称，这里随便输入名称就可以，如 client1，回车。

接下来将会在当前目录生成一个新的 `client1.ovpn` 文件。

同样使用 cat 命令查看文件内容，然后将内容复制到本地计算机上。

```bash
cat client1.ovpn
```

在本地计算机上创建一个 `client1.ovpn` 文件，将内容粘贴进去，再次导入到 OpenVPN 中。


## 参考资料

- [OpenVPN 安装脚本](https://github.com/hwdsl2/openvpn-install/blob/master/README-zh.md)


