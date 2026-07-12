---
title: 阿里云 Web应用防火墙 3.0 使用 CNAME 接入传统负载均衡 CLB
date: 2025-06-25 17:54:30
tags: [阿里云,WAF,Web应用防火墙,运维实战]
---

## 开通 WAF

首先找到 Web应用防火墙，然后点击开通。

## 添加域名

开通后打开接入管理，点击 CNAME 接入

> 本文章中的示例域名为 api.baidu.com，不代表实际域名，请自行替换。

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image.png)

接下来输入需要接入的域名

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image-1.png)

回到域名解析管理中，按照提示添加 TXT 记录

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image-2.png)


接下来，添加服务器地址，这里的地址就是防护的服务器/负载均衡的公网 IP地址

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image-3.png)

点击提交后，同样根据页面提示，添加 CNAME 记录

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image-4.png)

回到域名解析控制台，添加 CNAME 记录

![alt text](https://blog.shaohushuo.com/images/2025/06/25/image-5.png)

## 检测 CNAME 是否生效


1. 在 Window 上，可以使用 nslookup 进行测试

```bash
nslookup -qt=CNAME api.baidu.com
```

如果看到 `api.baidu.com.c.yundunwaf5.com.` 相关的输出，则说明 CNAME 配置成功。

2. 在 Linux/Mac 上，可以使用 dig 进行测试

```bash
dig api.baidu.com CNAME
```

```bash
➜ dig api.baidu.com CNAME

; <<>> DiG 9.10.6 <<>> api.baidu.com CNAME
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50094
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;api.baidu.com.		IN	CNAME

;; ANSWER SECTION:
api.baidu.com.	10	IN	CNAME	api.baidu.com.c.yundunwaf5.com.

;; Query time: 41 msec
;; SERVER: 100.100.2.136#53(100.100.2.136)
;; WHEN: Wed Jun 25 19:34:27 CST 2025
;; MSG SIZE  rcvd: 91
```

如上所示，看到 `api.baidu.com.c.yundunwaf5.com.` 输出，则说明 CNAME 配置成功。

- [如何测试CNAME解析是否正常？](https://help.aliyun.com/zh/cdn/check-whether-a-cname-record-takes-effect)
- [CNAME接入](https://help.aliyun.com/zh/waf/web-application-firewall-3-0/user-guide/overview-8)
