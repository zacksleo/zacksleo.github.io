---
title: Golang持续集成与自动化测试和部署
subtitle: golang-devops-and-auto-deploy
date: 2019-04-22 11:20:00
tags: [DevOps, Docker, GitLab-CI, REST, RESTful, Go, Golang]
---

## 概述

Golang是一门性能优异的静态类型语言，但因其奇快的编译速度，结合DevOps, 使得它也非常适合快速开发和迭代。

本文讲述如何使用Golang, 进行持续集成与自动化测试和部署。主要使用了以下相关技术：

+ [dep](https://github.com/golang/dep)： 进行包的依赖管理
+ [gin](https://github.com/gin-gonic/gin)： 搭建 api 服务
+ [gorm](https://github.com/jinzhu/gorm)：ORM, 数据CRUD
+ [mysql](http://github.com/go-sql-driver/mysql): 存储数据
+ [testfixtures](https://github.com/go-testfixtures/testfixtures)： 测试夹具，在自动化测试时，自动向数据库填充用于测试的数据
+ [httpexpect](https://github.com/gavv/httpexpect): HTTP 测试包，用于API测试
+ [GoDotEnv](https://github.com/joho/godotenv): 环境变量处理
+ go test: 使用test命令进行单元测试, 基准测试和 HTTP 测试
+ GitLabCI: DevOps 工具
+ [golint](https://github.com/golang/lint): Golang 静态检查工具
+ [migrate](https://github.com/golang-migrate/migrate/): 数据库迁移工具
+ Docker: 使用 [zacksleo/golang](https://github.com/zacksleo/golang) 镜像, 该镜像默认安装了 curl,git,build-base,dep 和 golint
+ [db2struct](https://github.com/Shelnutt2/db2struct): 将数据库表结构一键生成为 struct(gorm的model)
+ [apig](https://github.com/cweagans/apig/tree/dep-conversion): 基于 gorm 和 gin 一键生成 CRUD API

##  开发流程

+ 使用 apig 脚手架工具初始化项目结构和目录
+ 使用 dep 安装相关依赖
+ 使用 migrate 编写数据库迁移方法，并执行迁移创建数据表
+ 使用 db2struct 生成 models
+ 使用 apig 生成 crud 代码
+ 使用 httpexpect 编写 api 测试代码，并通过 testfixtures 实现数据的自动填充
+ 编写 GitLabCI 脚本进行持续集成

在上述过程中，如需连接数据库时，可通过 GoDotEnv 来实现环境变量的使用

## 相关CI脚本

<script src="https://gist.github.com/zacksleo/6b86c61fff51939de7dbd6af531de9f3.js"></script>

## 集成测试

<script src="https://gist.github.com/zacksleo/a80e81fb4e7b8a8bd8289060c8190a60.js"></script>


## 注意事项

在测试中，如果需要区分单元测试和集成测试，可以使用 build tags 实现，如在文件头部中添加 `// +build integration`, 运行测试使用 `- go test -tags=integration $(go list ./tests/... | grep -v /vendor/) -v` 可以只执行集成测试



## 参考文档
+ [Go Test](https://golang.org/pkg/testing/)
+ [How to write benchmarks in Go](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go)
+ [Go 性能调优之 —— 基准测试](https://segmentfault.com/a/1190000016354758)
+ [Go语言圣经（中文版）](https://yar999.gitbooks.io/gopl-zh/content/)
+ [使用tags区隔单元测试和集成测试](https://stackoverflow.com/questions/25965584/separating-unit-tests-and-integration-tests-in-go)

