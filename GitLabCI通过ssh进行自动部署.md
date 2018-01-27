---
title: GitLab-CI通过ssh进行自动部署
date: 2017-04-14 14:39:50
tags: [GitLab-CI,DevOps,SSH,CD]
---

## 需求

通过gitlab-ci实现文件的自动部署

## 实现过程

文档托管在gitlab上, 每次代码更新, 会自动出发gitlab-ci构建
在构建脚本中, 通过ssh 登录远程服务器执行git拉取文档的命令

## 过程

### 首先需要在服务器上生成ssh证书

> 注意该证书的用户必须与ssh远程登录的用户一样, 例如我们的用户名是root

### 将公钥添加到gitlab上, 以便于该用于可以拉取代码

### 在 `CI/CD Piplines`中设置 `Secret Variables`, 包括 `DEPLOY_SERVER` 和 `SSH_PRIVATE_KEY`

其中 `SSH_PRIVATE_KEY` 的内容是服务器上的私钥, `DEPLOY_SERVER` 是服务器地址

### 编写 `.gitlab-ci.yml` 文件, 注入密钥, 通过`ssh`执行远程命令
 
## 完整代码
 
 ```
 # 使用alpine镜像, 该镜像很少,只有几兆
 image: alpine
 stages:
     - deploy
 before_script:
     # 预先装 ssh-agent
     - 'which ssh-agent || ( apk update && apk add openssh-client)'
     # 启动服务
     - eval $(ssh-agent -s)
     # 将私钥写入deploy.key 文件
     - echo "$SSH_PRIVATE_KEY" > deploy.key
     # 配置较低权限
     - chmod 0600 deploy.key
     # 注入密钥
     - ssh-add deploy.key
     - mkdir -p ~/.ssh    
     - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
  
 release-doc:
     stage: deploy
     script:
         # 连接远程服务器并执行拉取代码的命令
         - ssh root@$DEPLOY_SERVER "cd /path/to/wiki && git pull origin master"
     only:
         - master
     environment:
         name: production
         url: http://$DEPLOY_SERVER
         
 ```
 
  

## 相关文档

[Using SSH keys](https://docs.gitlab.com/ce/ci/ssh_keys/README.html)
