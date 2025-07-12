---
title: IIS网站间歇性打不开暴力解决方法
date: 2025-07-13 00:18:10
tags: [IIS, 运维实战]
---

## 背景

网站使用 Asp.NET 框架开发，使用 SQL Server 2012  IIS 8.5 运行。开发上线以后，经常出现网站间歇性打不开，但是重启 IIS 就可以正常访问。

## 问题排查过程

### 打开日志记录

观察 CPU，内存，带宽流量等占用正常，可以排除这方面原因，接下来开启相关日志，需要进一步观察。


首先确保已经打开了日志记录，包括访问日志、错误日志等。


![alt text](/images/2025/07/13/image.png)


日志格式选择 W3C， 日志事件目标选择日志文件和 ETW 事件，计划选择每天

![alt text](/images/2025/07/13/image-1.png)


### 分析错误日志

查询访问日志 `C:\inetpub\logs\LogFiles` ，网站运行几个小时后，开始出现大面积 500 错误

查询 HTTP 错误日志 `C:\Windows\System32\LogFiles\HTTPERR` ，查看错误日志，出现大量 `Connection_Dropped` 错误, 说明请求被IIS 关闭，以及 `Timer_ConnectionIdle`, 说明因连接超时，客户端主动断开


![alt text](/images/2025/07/13/image-2.png)


## 暴力解决方案

因为重启 IIS 中的 Web 网站可以恢复，所以可以将自动回收频率提高

### 配置自动回收


打开 IIS/应用程序池，找到网站的进程池，点击高级设置

![alt text](/images/2025/07/13/iis-pool.png)

固定时间间隔，改成 60 分钟，或者更短的时间

![alt text](/images/2025/07/13/iis-pool-1.png)

点击完成

![alt text](/images/2025/07/13/iis-pool-3.png)