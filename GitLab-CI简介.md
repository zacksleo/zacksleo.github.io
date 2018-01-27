---
title: GitLab-CI简介
date: 2017-04-26 09:27:52
tags: [GitLab-CI,DevOps]
---

## 概述

持续集成（CI）和 持续交付(CD) 是一种流行的软件开发实践，每次提交都通过自动化的构建（测试、编译、发布）来验证，从而尽早的发现错误。

持续集成实现了DevOps, 使开发人员和运维人员从繁琐的工作中解放出来。另外，这种形式极大地提高了开发者的开发效率和开发质量。
持续集成有多种工具，如Jenkins. GitLab内置了GitLab-CI，通过配置一段`YAML`脚本来实现持续集成.

## 功能

持续集成可以实现的功能:

+ 代码审核: 自动化代码规范审查, 甚至代码质量检查
+ 自动化测试: 单元测试, 功能测试和验收测试
+ 编译发布: 将源代码编译成可执行程序, 并将程序上传到托管发布平台实现自动发布
+ 构建部署: 通过构建Docker镜像, 或登录远程服务器执行相关部署命令和脚本, 实现自动化部署

## 原理

GitLab-CI 检测每次代码变动, 通过`.gitlab-ci.yml`脚本执行构建命令, 将命令发布到`GitLab-Runners(运行机)`上, 进而执行命令.

`GitLab-Runners` 基于Docker执行持续集成的每项任务, 这样就解决了环境依赖问题.

`GitLab-Runners`把实时将执行结果输出到GitLab网页上, 任务执行完后, 通过徽章标记和邮箱告知执行结果.


下一章: [[GitLab 快速开始]]


+ [持续集成是什么](http://www.ruanyifeng.com/blog/2015/09/continuous-integration.html)
+ [Getting started with GitLab and GitLab CI](https://about.gitlab.com/2015/12/14/getting-started-with-gitlab-and-gitlab-ci/)
+ [Continuous Integration, Delivery, and Deployment with GitLab](https://about.gitlab.com/2016/08/05/continuous-integration-delivery-and-deployment-with-gitlab/)
