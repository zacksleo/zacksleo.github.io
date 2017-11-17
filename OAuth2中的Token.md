---
title: OAuth2中的Token
date: 2017-03-09 15:32:21
tags:
---

## 两个不同的Token

OAuth2 中主要有两个不同的Token, 其中的区别为是否与用户相关联, 即与用户相关的用户Token, 和与客户端相关的客户端Token,
可以通过用户Token, 查询到用户的相关信息, 客户端Token与用户无关, 一般只用于客户端认证

## 用户Token

> 获取用户Token一般有两个方式, 授权码模式和密码模式

### 授权码模式

> 授权码模式通过跳转到授权中心来获取token

+ 跳转到认证服务器
+ 认证服务器需要用户登录
+ 用户选择是否授权
+ 授权同意后, 自动跳转回原来的页面, 客户端拿到授权码
+ 客户端凭借授权码, 在服务器上通过接口向认证服务器申请令牌

### 密码模式

> 密码模式通过接口直接申请到Token

该接口需要几个参数, client_id, client_secret, grant_type, username, password

```
{
    "client_id": "客户端ID",
    "client_secret": "客户端密码",
    "grant_type": "授权模式, 此外为 password",
    "username": "用户名",
    "password": "用户密码"
}

```
## 客户端Token

> 通过客户端ID和客户端密码来获取Token

该Token与客户端相关, 与用于无关, 只用于客户端认证, 避免了接口泄露和滥用