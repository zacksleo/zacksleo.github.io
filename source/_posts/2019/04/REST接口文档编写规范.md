---
title: REST接口文档编写规范
subtitle: restful-docs-guideline
date: 2019-04-16 15:41:26
tags: [REST, RESTful, 规范]
---

REST接口文档遵循 [API Blueprint 编码规范](https://apiblueprint.org/)

中文说明需要遵循 [中文文案排版指北](https://github.com/mzlogin/chinese-copywriting-guidelines)

按照该格式书写的文档, 可以被 GitLab 及 Gollum 完美解析

## 主要内容


1. 使用 Markdown 编写
2. 请求和响应主体, 使用8个字符缩进
3. 不使用` 包裹json代码

## Demo

```

## 用户密码 [/users/password]

### 重置密码 [PATCH]


+ Attributes
    + phone (number, required) - 手机号码
    + password (string, required) - 密码
    + verify_code (string, required) - 短信验证码

+ Header 
    + Authorization Bearer: {clientToken} - 访问令牌, 通过客户端模式获得
    + Content-Type: application/json

+ Request (application/json)

        {
            "phone":"17083300514",
            "password":"pa66w0rd",
            "verify_code":"312338"
        }

+ Response 201 (application/json)      

        {
            "phone":"17083300514",
            "password":"pa66w0rd",
            "verify_code":"312338"
        }

+ Response 422 (application/json)

        [
          {
            "field": "verify_code",
            "message": "短信验证码错误"
          },
          {
            "field": "phone",
            "message": "手机号不存在"
          },
         {
            "field": "password",
            "message": "密码至少包含一位数字"
          }
        ]
        
        
        
## 扫描二维码 [/qrcode-tokens/{ticket}]

### 更新状态 [PUT]

+ Attributes
    + action (string, required) - 动作, 值为SCANNED或LOGGED_IN
    + ticket (string, required) - ticket 二维码中链接中后面的字符串

+ Header 
    + Authorization: Bearer {clientToken}
    + Content-Type: application/json

+ Request (application/json)

        {
            "action":"SCANNED"
        }
  
+ Response 201 (application/json)      

        {
            "action":"SCANNED"
        }        


```

## 参考链接

+ [API Blueprint官网](https://apiblueprint.org/)
+ [GitHub](https://github.com/apiaryio/api-blueprint)
+ [API Blueprint 指导手册](https://blog.callmewhy.com/2014/06/05/blueprint-tutorial/)
