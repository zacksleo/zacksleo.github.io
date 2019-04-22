---
title: DevOps 软件开发流程规范
subtitle: devops-software-develop-guideline
date: 2019-04-16 15:34:00
tags: [DevOps, Docker, GitLab-CI, REST, RESTful, guideline]
---

## 流程概要

持续集成和持续交付是 DevOps 最核心的两个部分。

持续集成通过即时将最新的代码，集成到主干分支，并进行相关的测试（单元测试、集成测试等）和静态检查（代码格式，代码质量等），以期提早发现问题。

持续交付，在持续集成完成之后，即时生成生产环境可用的产物（如二进制文件、包、或者 Docker镜像），并准备随时部署，如果伴随着部署过程，则称为持续部署。

##  开发流程

+ 系统分析与设计：需求分析，架构设计，数据库设计等
+ 相关文档编写, 文档应与代码仓库一起
+ 系统开发
    + 持续集成 (gitlab-ci)
    + 格式检查和静态检查 (vscode, linter)
    + 数据库迁移 (migration)
    + 使用 Docker 搭建开发、测试和生产环境，docker-compose
    + Git开发流程 (git cz, master, branch )
    + 自动化测试：单元测试，HTTP测试（api测试），功能测试，基准测试 (ab)
    + 自动化部署（主备）(ngixn back)
    + 更新日志 (angular changelog)
    + crontab supervisord

+ 测试与验收

## 参考文档

+ [RESTful接口规范](https://zacksleo.github.io/2017/03/07/RESTful%E6%8E%A5%E5%8F%A3%E8%A7%84%E8%8C%83/)
+ 接口文档编写规范
+ [PHP编码规范](https://zacksleo.github.io/2017/03/07/PHP%E7%BC%96%E7%A0%81%E8%A7%84%E8%8C%83/)
+ [Git工作流程及使用规范](https://zacksleo.github.io/2017/03/07/Git%E5%B7%A5%E4%BD%9C%E6%B5%81%E7%A8%8B%E5%8F%8A%E4%BD%BF%E7%94%A8%E8%A7%84%E8%8C%83/)
+ [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)
