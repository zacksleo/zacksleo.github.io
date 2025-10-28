---
title: IIS申请免费证书并配置网页重定向至HTTPS
date: 2025-10-28 11:15:26
tags: [IIS, HTTPS, SSL, 证书]
---

## IIS 申请免费证书

### 安装 ACME 客户端

1. Win-ACME 是一个 Windows 平台下的 ACME 协议客户端，可以用来申请 Let's Encrypt 免费证书。

打开主页 [https://www.win-acme.com/](https://www.win-acme.com/)，下载最新版本的 Win-ACME。

点击 Download，选择最新版本下载，这里使用当年版本 [2.2.9.1](https://github.com/win-acme/win-acme/releases/download/v2.2.9.1701/win-acme.v2.2.9.1701.x64.trimmed.zip)。

解压下载的压缩包到一个目录，例如 `C:\win-acme`。

2. 运行 wacs.exe

按照提示依次执行，输入 N，创建证书

![alt text](/images/2025/10/28/image.png)

输入网站对应编号，这里显示编号为 6000，回车

![alt text](/images/2025/10/28/image-1.png)

输入 P，选择使用搜索模式选择绑定的域名

![alt text](/images/2025/10/28/image-2.png)

输入申请的域名，例如这里输入 `www.flex***.com`，需要注意的是，这里的域名必须和 IIS 绑定的域名一致，同时该域名需要解析到当前服务器的 IP 地址而且成正常访问，否则申请会失败。

![alt text](/images/2025/10/28/image-3.png)

接下来回车，输入 y，继续操作

![alt text](/images/2025/10/28/image-4.png)

继续按操作提示，直至完成证书申请。

![alt text](/images/2025/10/28/image-5.png)

## 配置 IIS 重定向至 HTTPS

在网站跟目录编辑 web.config 文件，如果没有，可以手动创建该文件，添加以下内容：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="Redirect to HTTPS" stopProcessing="true">
                    <match url="(.*)" ignoreCase="false" />
                    <conditions>
                        <add input="{HTTPS}" pattern="off" ignoreCase="true" />
                    </conditions>
                    <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
                </rule>
            </rules>
        </rewrite>
    </system.webServer>
</configuration>
```

上面的配置中，会自动将 HTTP 请求重定向至 HTTPS。


## 参考资料

- [使用Win-ACME在Windows+iis服务器下配置自动续期SSL证书](https://www.cnblogs.com/05-hust/p/17866651.html)

