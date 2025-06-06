---
title: GitHub使用Style-CI进行格式检查
subtitle: use-style-ci-in-github
date: 2018-01-30 10:55:06
tags: [GitHub,Style-CI,DevOps]
---

<!-- GitHub使用Style-CI进行格式检查 -->


## 配置

在项目根目录，新建`.styleci.yml` 配置文件，并编写配置内容：

```
preset: psr2

```

## 查看

打开https://styleci.io/，使用Gitlab账号登录，找到对应的项目，点击右侧的 `ENABLE STYLECI` 启用按钮，即可使用，

每次提交代码，都会看到检测结果

## 提示

如果没有找到自己的项目，打开 `https://styleci.io/account#repos` 点击 `Sync With GitHub` 同步，就会看到
