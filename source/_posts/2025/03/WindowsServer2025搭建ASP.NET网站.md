---
title: WindowsServer 2025 使用 IIS 搭建 ASP.NET 网站
date: 2025-03-22 23:26:21
tags: [阿里云, ECS, WindowsServer, IIS, ASP.NET]
---

## 开启远程桌面


1. 参考文章[Windows server开启远程桌面教程](https://blog.csdn.net/xuqingda/article/details/136473232)打开服务管理器。
2. ECS 配置安全组，开启 3389
3. Telnet 验证网络联通性  telnet  x.x.x.x 338
4. 安装 Windows App，登录验证


## 安装 ASP.NET 3.5

1.参考文章[Windows Server 2012安装 .NET Framework 3.5](https://developer.aliyun.com/article/540898)和
[Windows Server 2012上安装.NET Framework 3.5](https://blog.csdn.net/lz17267861157/article/details/134960359)

打开服务器管理器，选择“添加角色和功能”，依次点击下一步进直到入“功能”，勾选 .NET Framework 3.5 功能，点击安装。

2. 打开IIS，在新建的网站处右键，配置网站使用的应用程序池，选择 .NetCLR 版本 2.0

> 注意虽然我们安装的是 ASP.NET 3.5, 但整体核心架构是基于.NET2.0, 所以 IIS 中没有3.5的选项, 所以这里配置 .NetCLR 版本 2.0。

![选择应用程序池](https://blog.shaohushuo.com/images/2025/03/22/选择应用程序池.png)

3. 启动应用程序池

![启动应用程序池](https://blog.shaohushuo.com/images/2025/03/22/启动应用程序池.png)

4. 安装 URL Rewrite 模块

参考文章 [IIS安装和使用URL重写工具-URL Rewrite](https://blog.csdn.net/suxuelian/article/details/80103514)，

在页面[IIS官网](https://www.iis.net/downloads/microsoft/url-rewrite)下载并安装 URL Rewrite 模块([X64位下载](https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_zh-CN.msi))，安装 URL Rewrite。


## 常见问题处理

### Windows 远程桌面 RDP 连接不上

尝试从以下几个方面进行排查：

1. 检查服务器是否已开启了远程桌面服务
2. 检查 ECS 安全组是否放行了RDP端口，一般是3389
3. 账号密码是否正确
4. 检查本地办公网络是否拦截RDP端口，尝试使用代理或者VPN绕过拦截


### 安全性异常

>说明: 应用程序试图执行安全策略不允许的操作。要授予此应用程序所需的权限，请与系统管理员联系，或在配置文件中更改该应用程序的信任级别。
>异常详细信息: System.Security.SecurityException: 请求“System.Web.AspNetHostingPermission, System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089”类型的权限已失败。
>源错误:
>执行当前 Web 请求期间生成了未处理的异常。可以使用下面的异常堆栈跟踪信息确定有关异常原因和发生位置的信息。
>堆栈跟踪:
```bash
[SecurityException: 请求“System.Web.AspNetHostingPermission, System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089”类型的权限已失败。]
   System.Reflection.Assembly._GetType(String name, Boolean throwOnError, Boolean ignoreCase) +0
   System.Web.Compilation.CompilationUtil.GetTypeFromAssemblies(AssemblyCollection assembliesCollection, String typeName, Boolean ignoreCase) +227
   System.Web.Compilation.BuildManager.GetType(String typeName, Boolean throwOnError, Boolean ignoreCase) +362
   System.Web.Configuration.ConfigUtil.GetType(String typeName, String propertyName, ConfigurationElement configElement, XmlNode node, Boolean checkAptcaBit, Boolean ignoreCase) +64
```
>版本信息: Microsoft .NET Framework 版本:2.0.50727.9179; ASP.NET 版本:2.0.50727.9175

解决方案：修改应用程序池配置，修改“加载用户配置文件”为 True。

![加载用户配置文件](https://blog.shaohushuo.com/images/2025/03/22/load-user-profile.png)


## 参考资料

- [Windows server开启远程桌面教程](https://blog.csdn.net/xuqingda/article/details/136473232)
- [Windows Server 2012安装 .NET Framework 3.5](https://developer.aliyun.com/article/540898)
- [Windows Server 2012上安装.NET Framework 3.5](https://blog.csdn.net/lz17267861157/article/details/134960359)
- [IIS安装和使用URL重写工具-URL Rewrite](https://blog.csdn.net/suxuelian/article/details/80103514)
- [ASP.NET “System.Security.SecurityException”异常的解决办法](https://blog.bossma.cn/dotnet/asp-net-application-attempted-to-perform-an-operation-not-allowed-security-policy/)
