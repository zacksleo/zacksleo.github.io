---
title: GitLab-CI微信小程序进行持续集成和持续部署
date: 2018-04-08 11:21:26
tags: [GitLab-CI, DevOps, 小程序, 持续部署, 微信小程序]
---

## 问题缘由

在微信小程序开发中，先要在本地使用微信开发者工具进行调试，如果需要在线测试，则需要将编译好的代码上传。
目前，只能通过微信开发者工具手动点击上传，而该过程无法与持续集成/持续部署结合在一起，本文就是为了解决能够实现自动化和持续部署的难题

## 实现原理

微信开发者工具，提供了HTTP调用方式,其中就包括上传和自动化测试的命令，我们可以通过脚本实现自动化集成

## 步骤

### 安装并配置 GitLab Runner

这部分文档在 [Install GitLab Runner on macOS](https://docs.gitlab.com/runner/install/osx.html)

#### 安装 

首先需要在本机上安装 [GitLab Runner](https://docs.gitlab.com/runner/),  由于微信开发者工具只提供了 mac 和 windows 版本，所以目前只能在这两种系统上实现持续集成，本文讲述在 mac 的具体实现， windows 上的实现与此类似，只是相关命令和路径需要做些变更

#### 注册 GitLab Runner

```bash
gitlab-runner register

```
注意，注册时没有`sudo`, 因为需要使用用户模式来使用，而非系统模式

注册时，将本机添加上了 `mac` 标签, 运行模式为`shell`，这样可以在部署时，指定运行环境

```
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
https://xxxxxx.com/
Please enter the gitlab-ci token for this runner:
xxxxxx
Please enter the gitlab-ci description for this runner:
[xxx.com]: macbook.home
Please enter the gitlab-ci tags for this runner (comma separated):
mac,shell
Whether to run untagged builds [true/false]:
[false]: true
Whether to lock the Runner to current project [true/false]:
[true]: false
Registering runner... succeeded                     runner=Gd3NhK2t
Please enter the executor: docker-ssh, virtualbox, docker+machine, docker-ssh+machine, docker, parallels, shell, ssh, kubernetes:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!

```


#### 运行服务

```bash
cd ~
gitlab-runner install
gitlab-runner start

```

### 编写 `.gitlab-ci.yml`

在此之前，你需要对GitLab-CI有一定的掌握，这部分资料参考下方的相关文档

```YAML
image: node:alpine

before_script:
    - export APP_ENV=testing
    - yarn config set registry 'https://registry.npm.taobao.org'
stages:
    - build
    - deploy

variables:
    NPM_CONFIG_CACHE: "/cache/npm"
    YARN_CACHE_FOLDER: "/cache/yarn"
    DOCKER_DRIVER: overlay2
build-package:
    stage: build
    dependencies: []
    cache:
      key: "$CI_COMMIT_REF_NAME"
      policy: pull
      paths:
        - node_modules
    script:
        - if [ ! -d "node_modules" ]; then
        - yarn install --cache-folder /cache/yarn
        - fi
        - yarn build
        - cp deploy/project.config.json ./dist/project.config.json
    artifacts:
        name: "wxpkg-dlkhgl-$CI_COMMIT_TAG"
        untracked: false
        paths:
            - dist
    only:
        - tags
    tags:
        - docker
deploy:
    stage: deploy
    dependencies:
        - build-package
    variables:
        GIT_STRATEGY: none
    before_script: []
    script:
        # 获取HTTP服务的端口, 该端口是不固定的
        - PORT=`cat ~/Library/Application\ Support/微信web开发者工具/Default/.ide`
        # 调用上传的API
        - curl http://127.0.0.1:$PORT/upload\?projectpath\=$PWD/dist\&version\=$CI_COMMIT_TAG\&desc\=audo-deploy
    only:
        - tags
    tags:
        - mac
```

注意，`deploy/project.config.json` 文件为 `project.config.json`的副本，但其他的 `projectname` 不同，这样做是为了解决 `已存在相同 AppID 和 projectname 的项目（路径），请修改后重试`的问题，这是因为，同一台电脑上，微信开发者工具不能有两个同名的项目


另外注意，在运行自动部署时，微信开发者工具必须打开，且为登录状态

## 相关文档

+ [如何编写GitLab-CI配置文件](https://zacksleo.github.io/2017/04/27/%E5%A6%82%E4%BD%95%E7%BC%96%E5%86%99GitLab-CI%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6/)
+ [GitLab-CI中的artifacts使用研究](https://zacksleo.github.io/2017/04/18/GitLab-CI%E4%B8%AD%E7%9A%84artifacts%E4%BD%BF%E7%94%A8%E7%A0%94%E7%A9%B6/)
+ [GitLab-CI使用cache加速构建过程](https://zacksleo.github.io/2018/01/26/GitLab-CI%E4%BD%BF%E7%94%A8cache%E5%8A%A0%E9%80%9F%E6%9E%84%E5%BB%BA%E8%BF%87%E7%A8%8B/)
+ [微信开发者工具HTTP调用](https://developers.weixin.qq.com/miniprogram/dev/devtools/http.html)
+ [Install GitLab Runner](https://docs.gitlab.com/runner/install/)
+ [Registering Runners](https://docs.gitlab.com/runner/register/index.html)
