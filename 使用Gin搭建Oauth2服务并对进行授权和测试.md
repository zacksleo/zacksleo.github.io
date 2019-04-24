---
title: 使用Gin搭建Oauth2服务并对进行授权和测试
subtitle: build-oauth2-services-by-gin-and-authorize-and-test-it
date: 2019-04-22 23:29:00
tags: [DevOps, Docker, GitLab-CI, REST, RESTful, Go, Golang, Gin, Oauth2, go-oauth2]
---

## 概述

前面分别介绍了 [Golang 持续集成与自动化测试和部署](https://zacksleo.github.io/2019/04/22/Golang%E6%8C%81%E7%BB%AD%E9%9B%86%E6%88%90%E4%B8%8E%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E5%92%8C%E9%83%A8%E7%BD%B2/)和[使用Gin开发Restful接口并进行自动化测试](https://zacksleo.github.io/2019/04/24/%E4%BD%BF%E7%94%A8Gin%E5%BC%80%E5%8F%91Restful%E6%8E%A5%E5%8F%A3/)
那么Restful接口搭建好了以后，如何进行接口授权验证，本文将讲述这些内容。

## go-oauth2

Oauth2 是一种验证授权机制，通过下发令牌，来实现接口的认证。

[go-oauth2](https://github.com/go-oauth2/oauth2)

## 路由

```go
	auth := r.Group("/api/v1/oauth2")
	{
		auth.POST("/tokens", controllers.CreateToken)
	}
```
## 控制器实现

<script src="https://gist.github.com/zacksleo/0607c81ff5a427ed16683c479e2d97e3.js"></script>

## 获取Token的测试

这里为了方便在其他接口测试案例中调用获取token的方法，特意进行了拆分

<script src="https://gist.github.com/zacksleo/4f52efceb3e2b3206de35f7e034f48fe.js"></script>
<script src="https://gist.github.com/zacksleo/916a4421de368a66036ab19731424d0b.js"></script>

## 其他接口的测试

<script src="https://gist.github.com/zacksleo/bf09d04c5120f1a9c8f06cbeeb86cb6e.js"></script>
