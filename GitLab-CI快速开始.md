---
title: GitLab-CI快速开始
date: 2017-04-26 09:58:09
tags: [GitLab-CI]
---

> 假定已经安装好了`GitLab-Runners`

## Hello World !
###  在仓库根目录创建 `.gitlab-ci.yml` 文件, 内容如下

```
job-1:
  script:
    - echo "Hello World"
```

### 这样, 在每次提交代码后, 都会自动执行以上脚本. 其中`job-1`是任务名称, 可以定义多个任务,
`script`下面是 shell 命令, 只要命令执行成功, 就代表本次构建通过(出现passed标记)

如图

![](http://ww1.sinaimg.cn/large/675eb504gy1fezux5o1v6j21200dejur.jpg)


### 这样, 一次简单的持续集成已经搞定了.


## 远程拉取代码

### 使用ssh远程登录服务器, 然后执行`git pull` 拉取代码, 实现代码热更新

由于ssh无密码登录需要用到密钥, 所以首先需要注入私钥
 
如

```
release-doc:
    stage: deploy
    script:
        - ssh root@$DEPLOY_SERVER "cd /mnt/data/docker-gollum/wiki && git pull origin master"

````

一个更详细的例子 [[通过gitlab-ci实现文件的自动部署]]

## 通过Docker镜像实现自动部署

见文章 [[GitLab-CI使用Docker进行持续部署]]

## 参考资料

+ [GitLab-CI快速开始-中文](https://docs.gitlab.com.cn/ce/ci/quick_start/README.html)
+ [GitLab-CI快速开始-官方](https://docs.gitlab.com/ce/ci/quick_start/README.html)