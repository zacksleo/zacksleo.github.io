---
title: 如何自动部署GitLab项目
date: 2016-11-04 14:01:48
tags:
---

# 如何自动部署

## 原理
* GitLab有预制的钩子, 在代码提交/合并等事件中,会自动调用WebHoos, 即向该URL发送POST请求
* 在布署服务器上监听该POST, 验证通过后执行相关的布置Shell脚本, 即可完成自动布署

## 配置环境
* 1. 安装Python和Pip
* 2.如果需要, 安装python的requests模块和argparse模块
```
pip install requests
easy_install argparse
```
* 3. 下载监听脚本
```
curl https://raw.githubusercontent.com/zacksleo/docker-hook/master/docker-hook > /usr/local/bin/docker-hook; chmod +x /usr/local/bin/docker-hook
```
* 4.脚本安装完成后即可使用docker-hook 命令, 默认监听8555端口
```
nohup docker-hook  -t  <auth-token>  -c  <command> &
```
其中, auth-token 替换为授权token, command替换为要执行的命令, 例如
auth-token为`auto-deploy-pushserver`,command为`sh /mnt/pushserver/deploy.sh`
则执行命令: `docker-hook -t auto-deploy-pushserver -c sh /mnt/pushserver/deploy.sh`

deploy.sh的内容为:
```
git push origin dev
```
nohup+&命令为该进程设置为守护进程, 防止进程退出

* 5.在GitLab的项目设置里面,设置Webhooks, 本例子中则为`139.198.9.141:8555/audo-deploy-pushserver`

* 6. 注意, 如果需要部署多个hooks, 则需要通过--port配置不同的端口, 例如

```
nohup docker-hook  -t  <auth-token2>  -c  <command2>  --port 8556 &
```

## 参考
* [docker-hook](https://github.com/zacksleo/docker-hook)