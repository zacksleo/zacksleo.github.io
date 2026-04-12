---
title: 鸿蒙Flutter实战：30.在Pub上发布鸿蒙化插件
date: 2026-04-12 01:06:08
tags: [HarmonyOS,Flutter,鸿蒙Flutter实战]
author: 少湖
cover: https://blog.shaohushuo.com/images/flutter-ohos.jpg
source_url: https://blog.shaohushuo.com/2026/04/11/鸿蒙Flutter实战/30-在Pub上发布鸿蒙化插件/
---

## 背景

当我们编写好鸿蒙化插件后，特别是以 xxx_ohos 命名的联合插件，可以将其发布到 pub.dev 仓库中，以便其他开发者可以轻松地使用。

## 步骤

### 准备工作

包括但不限于：

1. 做好插件的测试，尤其要在真机上进行测试，确保插件的功能正常。
2. 确保插件的文档完善，包含使用说明、API 文档、示例代码、CHANGELOG 等，方便其他开发者理解和使用。
3. 确保插件的版本号正确，遵循语义化版本控制（SemVer）规范, 这里建议与原插件的版本号保持一致，如果版本号不够用，可通过 x.x.x+n 的方式来升级小版本号。
4. 确保插件的许可证正确，并添加到插件的根目录下。
5. 需要有一个 Google 账号，用于发布插件。

## 发布插件

使用命令`dart pub publish` 即可发布插件，按照提示一步步操作.

需要注意时，如果我们配置过 pub 镜像，则需要临时切换为官方镜像

```bash
export PUB_HOSTED_URL=https://pub.dev

dart pub publish
```

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image.png)


输入 `y` 确认，则会看到下面的 Google 授权链接，复制到浏览器中打开，进行授权。

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-1.png)

> 这里需要注意的是，浏览器和终端均需要确保可以访问 Google 网站，请配置好代理上网


在浏览器中选择 Google 账号

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-2.png)

接下来点击 继续

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-3.png)

直到网页中出现 `Pub Authorized Successfully`, 代表我们授权成功。

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-4.png)


回到终端，终端中出现 `Authorization received, processing`这样

```bash
Waiting for your authorization...
Authorization received, processing...
```

稍等片刻，则会开始上传插件，直到成功。

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-5.png)

## 进阶内容

很多插件会在名称旁边显示一个发布者的网站，这样的发布者也被称为“已验证发布者”。那么如何添加一个已验证发布者呢？

1.首选需要在 [Google Search Console](https://search.google.com/search-console/) 中验证域名的所有权。

进入 Google Search Console，点击添加资源，输入要验证的域名

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-7.png)

点击后，会看到如下界面，两个都可以选择

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-8.png)

接下来按照，到自己域名的解析平台，添加对应的解析，这里记录类型我们选择 CNAME


![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-9.png)

按照提示在域名解析平台添加解析记录，并等待解析完成，然后点击验证，等待验证成功即可。

2. 然后回到 pub.dev 上注册/登录Google账号

3. 紧接着点击 Create Publisher

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-6.png)

4. 在创建页面的底部输入刚才验证好的域名


![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-10.png)


按照提示点击 OK

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-11.png)


验证通过后，再点一次 `CREATE PUBLISHER`, 弹出对话框中点击 `OK`


![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-12.png)

最终完成创建

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-13.png)


此时跳转到配置页面，在以在表单中配置简介、邮箱等

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-14.png)


## 将发布的插件转移至已验证身份发布者

插件的第一次发布只能以普通身份发布，发布之后可以在 Package的详情页面，点击 `Admin` 标签，将插件转移至已验证身份发布者


![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-15.png)

转移完成之后，插件后续的新版本，都会以已验证身份发布者身份发布


## 最终效果

![alt text](https://blog.shaohushuo.com/images/鸿蒙Flutter实战/pub/image-16.png)

## 参考文档

- [发布 package](https://dart.cn/tools/pub/publishing/)