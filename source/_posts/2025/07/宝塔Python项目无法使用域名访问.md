---
title: 宝塔Python项目无法使用域名访问
date: 2025-07-26 21:36:10
tags: [阿里云, 宝塔运维实战, CentOs7, PHP8]
---

## 背景

使用宝塔安装了 Python 项目，项使用 Flask 框架，运行起来之后发现无法通过 IP 或域名访问。


## 问题排查

1. 首先检查阿里云安全组，确认 443 端口已经放行。

2. 使用 Telnet 测试端口是否正常

```bash
telnet 46.98.173.174 443
Trying 46.98.173.174...
telnet: connect to address 46.98.173.174: Connection refused
telnet: Unable to connect to remote host
```

测试结果表明，端口被拒绝，可以初步判断服务端异常。

3. 登录服务器，在服务上检查本地是否联通

```bash
curl -k https://localhost
```

发现无法访问

4. 检查项目配置


```json
{
"app" : {
"host": "localhost"
"debug": true,
"port": 50001
}
```

这里的 host 建议改为 0.0.0.0，允许所有 IP 访问

![alt text](https://blog.shaohushuo.com/images/2025/07/26/image-3.png)



5. 检查网站配置


```lua
server
{
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    listen 443 quic;
    listen [::]:443 ssl;
    listen [::]:443 quic;
    http2 on;
    server_name example.cn;
    index index.html index.htm default.htm default.html;
    root /root/APP/XP/backend;


    #禁止访问的文件或目录
    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md|package.json|package-lock.json|\.env) {
        return 404;
    }

    #一键申请SSL证书验证目录相关设置
    location /.well-known/ {
        root /www/wwwroot/java_node_ssl;
    }

    #禁止在证书验证目录放入敏感文件
    if ( $uri ~ "^/\.well-known/.*\.(php|jsp|py|js|css|lua|ts|go|zip|tar\.gz|rar|7z|sql|bak)$" ) {
        return 403;
    }

    # HTTP反向代理相关配置开始 >>>
    location ~ /purge(/.*) {
        proxy_cache_purge cache_one 127.0.0.1$request_uri$is_args$args;
    }

    # proxy
    location / {
        proxy_pass http://127.0.0.1:443;
        proxy_set_header Host 127.0.0.1:$server_port;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST $remote_addr;
        add_header X-Cache $upstream_cache_status;
        proxy_set_header X-Host $host:$server_port;
        proxy_set_header X-Scheme $scheme;
        proxy_connect_timeout 30s;
        proxy_read_timeout 86400s;
        proxy_send_timeout 30s;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # HTTP反向代理相关配置结束 <<<

    access_log  /www/wwwlogs/backend.log;
    error_log  /www/wwwlogs/backend.error.log;
}
```


经过分析，Nginx 监听了 80 和 443 端口，然后将请求转发至本地的 443 端口，也就是 proxy_pass ，这里存在问题，因为 Python 项目监听的是 50001 端口，而不是 443 端口。

经过以下修改，问题解决

```lua
    # proxy
    location / {
        proxy_pass http://127.0.0.1:50001;
    }
```

上面这个配置与宝塔面板中的外网映射等同，经过使用发现面板中的设置不一定生效，这里设置需要注意，端口选择50001，然后进行外网映射（默认使用 443端口），注意不要搞错对内和对外的端口。


![alt text](https://blog.shaohushuo.com/images/2025/07/26/image-2.png)







