---
title: 使用Gin开发Restful接口并进行自动化测试
subtitle: develop-a-restful-api-and-automate-testing-with-Gin
date: 2019-04-24 23:11:00
tags: [DevOps, Docker, GitLab-CI, REST, RESTful, Go, Golang, Gin]
---

## 概述

在之前的文章[Golang持续集成与自动化测试和部署](https://zacksleo.github.io/2019/04/22/Golang%E6%8C%81%E7%BB%AD%E9%9B%86%E6%88%90%E4%B8%8E%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95%E5%92%8C%E9%83%A8%E7%BD%B2/)中
简要介绍了如何快速搭建Api 微服务, 并进行DevOps集成。本文将进一步深入介绍，如果使用Gin实现Restful规范并进行自动化测试。

## Restful

在[RESTful接口规范](https://zacksleo.github.io/2017/03/07/RESTful%E6%8E%A5%E5%8F%A3%E8%A7%84%E8%8C%83/)一文中，介绍了 Restful 及其规范。

Gin 是一个性能优异的微服务框架，对于Restful有着良好的支持。因为基于此实现Restful并不困难。

Restful 中的核心在于对于资源的定义和使用，和对 HTTP 动词（GET, PUT, DELETE, POST, DELETE, OPTIONS）的充分使用，通过 HTTP 动词，免去了繁冗的接口方法定义。
例如，传统方式如果实现删除文章功能，则需要实现一个类似 `post/delete?id=6` 的方法， 如果使用 Restful, 则使用 `DELETE post/1` 形式，其中 DELETE是动词，代表删除操作，
`post/1` 代表单个文章资源。 

Restful 中的另一大规法是对于状态码的充分使用，不再使用响应内容表明状态。如200代表成功，404代表资源不存在，204代表删除成功，201代表创建成功。
有了状态码，响应内容中不再需要使用单独的字段来标记结果的状态（如 {result: "success"} ）。

这样的一大好处是实现方式更规范、统一和直观。只要知道资源定义（posts）, 就可以猜测出该如何进行增删改查的操作，不再需要知道方法名。
如此一来，可以很轻松的封装出一套同意的方法和操作。


### 路由定义

```go

package router

import (
	"os"
	"gitlab.com/zacksleo/project/controllers"
	"github.com/gin-gonic/gin"	
)

		api.GET("/customers", controllers.GetCustomers)
		api.GET("/customers/:id", controllers.GetCustomer)
		api.POST("/customers", controllers.CreateCustomer)
		api.PUT("/customers/:id", controllers.UpdateCustomer)
		api.DELETE("/customers/:id", controllers.DeleteCustomer)

```

下面一个较为完整的案例 `controllers/customer.go`

<script src="https://gist.github.com/zacksleo/14abb79d52e32c6ef89d9db207fabb4f.js"></script>

## 自动化测试

当实现了接口发后，为了验证接口运行正常，确保接口可靠和可用性，建议你对接口进行HTTP测试。
这里使用 httpexpect 对api进行测试，该库对响应的数据类型和结构验证有着较好的支持。

<script src="https://gist.github.com/zacksleo/555ae102e87af209593c5303f441cbfc.js"></script>




