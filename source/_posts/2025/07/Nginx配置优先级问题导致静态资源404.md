---
title:  Nginx配置优先级问题导致静态资源404
date: 2025-07-25 13:55:00
tags: [阿里云, 宝塔运维实战, Nginx, 404]
---

## 背景

网站搭建好之后，按照之前研发给的 Nginx 配置, 进行了重新部署，这方面已经在之前的文章[宝塔网站配置和伪静态使用技巧](./宝塔网站配置和伪静态使用技巧.md)中有介绍。配置完之后发现，静态资源无法访问，页面显示404。


## 配置内容

网站配置文件核心内容如下

```lua
server
{
    listen 80;
    listen 443 ssl http2 ;
    server_name example.com;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/wwwroot/html;

    include /www/server/panel/vhost/nginx/redirect/example.com/*.conf;

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
        expires      30d;
        access_log  /dev/null;
	error_log  /dev/null;
    }
}
```

由于静态文件位于 /opt/static/ 目录下，所以需要添加一个 location 来处理静态资源的访问, 使用 alias 来映射静态资源目录, 就像这样：

```lua
location /static/ {
    alias /opt/static/;
}
```

然而，在添加了这个 location 之后，发现静态资源仍然无法访问，页面依然显示404错误。

## 问题分析

背景知识，首先需要了解下 Nginx 的匹配优先级：


| 优先级 | 类型                  | 语法示例                          | 说明                                                                 |
|--------|-----------------------|-----------------------------------|----------------------------------------------------------------------|
| 1      | 精确匹配              | `location = /path`               | 只匹配完全相同的路径，优先级最高。                                   |
| 2      | 前缀匹配（提升优先级）| `location ^~ /prefix`            | 匹配以指定前缀开头的路径，如果使用`^~`修饰符，则优先级高于正则匹配。 |
| 3      | 正则匹配（区分大小写）| `location ~ \.png$`              | 按定义顺序匹配正则表达式（区分大小写），先定义优先。                 |
| 4      | 正则匹配（不区分大小写）| `location ~* \.png$`             | 按定义顺序匹配正则表达式（不区分大小写），先定义优先。               |
| 5      | 普通前缀匹配          | `location /static/`              | 匹配以指定前缀开头的路径，如果有多个匹配，选择最长前缀的。           |
| 6      | 通用匹配              | `location /`                     | 匹配所有请求，优先级最低。                                           |

由此可见，由于配置了 `location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$`, 这个正则匹配规则会优先于普通前缀匹配规则 `location /static/`，因此导致增加的规则失效，要解决这个问题，需要将正则匹配规则的优先级调高。

```lua
# 将 /static 目录映射成 /opt/static/, ^增加优先级
location ^~ /static/ {
  alias /opt/static/;
}
```

最终文件就可以正常访问了。