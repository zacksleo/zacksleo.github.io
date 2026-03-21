---
title: 大疆司空平台接入实战：司空 Sync文件同步
date: 2026-03-21 21:05:27
tags: [大疆司空, 大疆机场, 无人机, Java, OpenAPI]
---

## 创建 OSS 存储桶

1. 登录阿里云控制台，进入 OSS 存储桶管理，创建一个存储桶，这里假设创建的存储桶名称是 `dji-files`。
2. 修改访问权限，根据使用需要，在 OSS 详情配置，找到权限控制，分别设置是否允许公共访问和读写权限，这里面我们打开公共访问和公式读，如下图所示.

![alt text](/images/2026/03/21/dji-sikong-sync-7.png)

![alt text](/images/2026/03/21/dji-sikong-sync-6.png)


## 阿里云创建 AK 和 SK

1.打开阿里云控制台，进入“RAM 访问控制“，点击用户，创建一个 RAM 用户，创建时勾选“使用永久 AccessKey 访问“，这里面假定我们创建的 RAM 用户名称是 `司空OSS文件同步`。


![alt text](/images/2026/03/21/dji-sikong-sync-3.png)

2. 创建权限策略

进入权限策略，点击创建，选择脚本编辑器，填写如下脚本：


![alt text](/images/2026/03/21/dji-sikong-sync-4.png)


建议配置权限策略如下，将 bucket 名称替换成自己的，这里假设 bucket 名称是 `dji-files`。

```json
{
  "Version": "1",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "oss:Get*",
        "oss:List*",
        "oss:ListParts",
        "oss:ListObjects",
        "oss:GetObject",
        "oss:GetObjectTagging",
        "oss:PutObjectTagging",
        "oss:PutObject",
        "oss:AbortMultipartUpload"
      ],
      "Resource": [
        "acs:oss:*:*:dji-files",
        "acs:oss:*:*:dji-files/*"
      ]
    }
  ]
}
```

这里面需要注意的是，官方给的"权限配置代码样例"有问题，会出现 "连通失败，请检查IP和端口填写是否正确，检查网络状态"，这里我们加上 "oss:Get*" 和 "oss:List*" 以解决这一问题。，

点击保存，并组权限策略命令，如 `SikongUploadOnlyTest`.

3. 授权

在权限策略详情页面，点击授权管理，新增授权，选择上面登录的 RAM 用户，将本权限策略授权给 RAM 用户。

![alt text](/images/2026/03/21/dji-sikong-sync-5.png)


# 设置司空 Sync

打开大疆司空平台，找到组织列表，点击组织设置，进入司空 Sync


![alt text](/images/2026/03/21/dji-sikong-sync-0.png)


找到“直播与数据存储"中的文件同步，点开

![alt text](/images/2026/03/21/dji-sikong-sync-1.png)



## 编辑存储桶配置，按照提示填写配置


![alt text](/images/2026/03/21/dji-sikong-sync-2.png)



点击 "连通检测"，当检测通过后，点击 "保存"


## 资源同步配置

在资源同步配置下方，勾选需要同步的项目，在右侧点击全部打开即可。

![alt text](/images/2026/03/21/dji-sikong-sync-8.png)


## 查看同步状态

查看同步状态和进度，当同步状态为 “空闲" 时，表示同步完成。


![alt text](/images/2026/03/21/dji-sikong-sync-9.png)