---
title: 华为云主机安装宝塔面板并使用DeepSeek助力网站运维
date: 2025-07-06 19:52:31
tags: [云主机, 宝塔面板, DeepSeek, 华为云]
---

## 免费领取云主机

点击[免费领取链接](https://developer.huaweicloud.com/space/devportal/desktop?utm_source=csdndspace&utm_adplace=csdncxlhdp3), 登录华为云账号，免费领取云主机。

如果没有华为账号的话，先点击注册；有账号的话直接登录。

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.38.14.png)


根据提示，填写手机号和密码，完成注册。


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.38.54.png)


然后找到配置云主机


![alt text](https://blog.shaohushuo.com/images/2025/07/06/image.png)


根据下面的提示选择配置，然后点击安装。

![alt text](https://blog.shaohushuo.com/images/2025/07/06/image-1.png)


这样云主机就领取并安装好了。

## 启动云主机

接下来，我们进入云主机安装宝塔面板，快速建站。

首先点击打开云主机，选择进入桌面

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.44.02.png)

打开云主机，会进入初始化界面，等待几分钟

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_18.53.24.png)


然后就看到云主机的桌面了

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_18.57.00.png)



## 安装宝塔面板

在桌面的左下角，找到命令行工具，也就是 Terminal Emulator，长这个样子


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.01.29.png)

我们打开命令行工具，然后从[宝塔官方下载页面](https://www.bt.cn/new/download.html)，复制安装命令，复制时我们选择 Ubuntu/Debain 的安装命令：

![](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_18.59.21.png)


我们在刚才打开的命令行工具中，右键，选择粘贴，将刚才复制的命令粘贴到命令行工具中，然后回车

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.00.27.png)


在刚开始运行时，程序会提示我们确认（Do you want to install Bt-Panel to the /www directory now?(y/n)），我们输入 y，表示确认，然后加车，开始安装。

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.00.58.png)


等到一段时间的等待之后，命令行中会提示安装成功，像下面这样

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.17.47.png)

注意，你需要把上面“面板账户登录信息”全部复制并记录下来，以登录时使用。


选中以后，右键复制，将信息保存到本地记录本中。


## 登录并配置宝塔面板

在桌面找到火狐浏览器（FireFox）打开，输入刚才记录的内网面板地址

> 需要注意的是，这款云主机，并不支持外网IP访问

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.21.04.png)

然后输入前面记录的账号密码，登录宝塔面板

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.24.53.png)

首次使用会弹出用户协议，滚动鼠标滚轮至最后，完成阅读，勾选同意，进入面板

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.26.05.png)


如果你之前没有使用过宝塔面板，则需要绑定宝塔官方账号，这里我还没有注册，所有先选择注册，点击后打开注册页面

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.27.11.png)

按提示输入注册信息，并完成注册

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.28.54.png)


注册成功后，就可以关闭当前页面了，回到之前的宝塔面板，登录注册账号。绑定成功后，将弹出初始化推荐配置对话框：

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.31.41.png)

因为我们要通过 Docker 安装 DeekSeep，这里我们暂时跳过配置。

打开左侧的菜单，找到 Docker，点击进入，然后点击立即安装。


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.56.19.png)


选择默认安装方式，点击确认

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_19.56.49.png)


等待安装成功后，我们搜索 DeepSeek，点击安装


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_20.46.57.png)


等待安装成功


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-06_20.51.34.png)


经过漫长的等待，安装成功

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-07_00.24.28.png)

接下来，我们在火狐浏览器中打开Open WebUI，输入 http://localhost:18480


![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-07_00.32.43.png)

点击开始使用

接下来输入管理员账号和密码

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-07_00.33.22.png)


最好，我们可以愉快的使用 DeepSeek 了！任何关于网站系统运维的问题，都可以帮你解答。

![alt text](https://blog.shaohushuo.com/images/2025/07/06/iShot_2025-07-07_00.35.13.png)

## 参考资料

- [宝塔下载](https://www.bt.cn/new/download.html)