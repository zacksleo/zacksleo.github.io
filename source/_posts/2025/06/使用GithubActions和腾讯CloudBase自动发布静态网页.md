---
title: 使用GithubActions和腾讯CloudBase自动发布静态网页
date: 2025-06-25 15:57:20
tags: [github-actions, cloudbase]
---

腾讯 CloudBase 可以用于托管静态网站，服务开通之后，使用 CloudBase CLI 可以将本地静态网站上传到 CloudBase，并生成相应的访问域名。

## 配置 Workflow

创建 .github/workflows/deploy.yml 文件, 编辑内容如下：

```yaml
name: Deploy to CloudBase Static Hosting

on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:

  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18' # 根据您的项目需求选择Node.js版本

      - name: Install CloudBase CLI
        run: npm install -g @cloudbase/cli

      - name: Deploy to CloudBase Static Hosting
        run: |
          tcb login --apiKeyId ${{ secrets.TCB_SECRET_ID }} --apiKey ${{ secrets.TCB_SECRET_KEY }}
          tcb hosting deploy ./dist --envId ${{ secrets.TCB_ENV_ID }}
```

这里，我们首先配置好 node 环境，然后安装 CloudBase CLI，通过 tcb login 命令登录 CloudBase，然后使用 tcb hosting deploy 命令将静态网站部署到 CloudBase。

可以看到，这里用到了几个环境变量，如 TCB_SECRET_ID、TCB_SECRET_KEY、TCB_ENV_ID。 接下来，我们需要在项目设置中添加环境变量。

## 配置

1. 点击 Settings 按钮，进入项目设置页面。找到 Secrets and Variables 选项展开，点击 Actions，在 `Repository secrets` 处点击

`New repository secret` 按钮，准备添加变量。


![alt text](/images/2025/06/25/image.png)

2. 添加变量，分别添加 TCB_SECRET_ID、TCB_SECRET_KEY、TCB_ENV_ID。

![alt text](/images/2025/06/25/image-1.png)

TCB_SECRET_ID、TCB_SECRET_KEY，通过控制台/访问管理，找到访问密钥管理，添加。

TCB_ENV_ID 为服务创建好之后的环境 ID。

## 参考资料

- [CloudBase CLI文档](https://docs.cloudbase.net/cli/intro)
- [与Git平台CI/CD集成](https://docs.cloudbase.net/hosting/cli-devops)