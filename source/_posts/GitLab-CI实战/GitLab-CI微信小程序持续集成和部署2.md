---
title: GitLab-CI微信小程序进行持续集成和部署2
date: 2020-06-08 08:05:26
tags: [GitLab-CI, DevOps, 小程序, 持续部署, 微信小程序]
---

## 问题缘由

在微信小程序开发中，先要在本地使用微信开发者工具进行调试，如果需要在线测试，则需要将编译好的代码上传。
目前，只能通过微信开发者工具手动点击上传，而该过程无法与持续集成/持续部署结合在一起，本文就是为了解决能够实现自动化和持续部署的难题

## 实现原理

微信 miniprogram-ci 库，提供了命令行调用方式,其中就包括上传的命令，我们可以通过脚本实现自动化集成

## 步骤

### 安装并配置 GitLab Runner

这部分文档在 [Install GitLab Runner on macOS](https://docs.gitlab.com/runner/install/osx.html)

#### 安装 

首先需要在本机上安装 [GitLab Runner](https://docs.gitlab.com/runner/),  由于微信开发者工具只提供了 mac 和 windows 版本，所以目前只能在这两种系统上实现持续集成，本文讲述在 mac 的具体实现， windows 上的实现与此类似，只是相关命令和路径需要做些变更

#### 注册 GitLab Runner

```bash
gitlab-runner register

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
release:
    stage: deploy
    before_script: []
    dependencies:
        - build-package
    variables:
        GIT_STRATEGY: none
    script:
        - yarn global add miniprogram-ci
        - if [[ -z "$CI_COMMIT_TAG" ]];then
        #- CI_COMMIT_TAG=$CI_COMMIT_REF_NAME
        - CI_COMMIT_TAG="测试版:$(date '+%Y-%m-%d')"
        - fi
        - COMMIT_MESSAGE=`cat ./dist/release.txt`
        - rm -f ./dist/release.txt
        # 将单行格式转为多行格式
        - LF=$'\\\x0A'
        - echo $UPLOAD_PRIVATE_KEY | sed -e "s/-----BEGIN RSA PRIVATE KEY-----/&${LF}/" -e "s/-----END RSA PRIVATE KEY-----/${LF}&${LF}/" | sed -e "s/[^[:blank:]]\{64\}/&${LF}/g" > private.key
        - miniprogram-ci upload --project-path=$PWD/dist --appid=$APP_ID --upload-version=$CI_COMMIT_TAG --private-key-path=$PWD/private.key --upload-description="$COMMIT_MESSAGE"
    environment:
        name: production
        url: https://mp.weixin.qq.com/wxamp/wacodepage/getcodepage
    only:
        - tags
        - master
```

注意，在设置-CI/CD-变量中，需要添加两个变量：

APP_ID 小程序 appid

UPLOAD_PRIVATE_KEY 小程序代码上传密钥, 需要在小程序后台获取

由于配置的密钥，在运行时过去到是单行文本形式，需要转换为多行原始格式，并输出到文件，以便上传使用

于是使用一下命令`- LF=$'\\\x0A'
        - echo $UPLOAD_PRIVATE_KEY | sed -e "s/-----BEGIN RSA PRIVATE KEY-----/&${LF}/" -e "s/-----END RSA PRIVATE KEY-----/${LF}&${LF}/" | sed -e "s/[^[:blank:]]\{64\}/&${LF}/g" > private.key
` 
## 相关文档

+ [如何编写GitLab-CI配置文件](https://zacksleo.github.io/2017/04/27/%E5%A6%82%E4%BD%95%E7%BC%96%E5%86%99GitLab-CI%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6/)
+ [GitLab-CI中的artifacts使用研究](https://zacksleo.github.io/2017/04/18/GitLab-CI%E4%B8%AD%E7%9A%84artifacts%E4%BD%BF%E7%94%A8%E7%A0%94%E7%A9%B6/)
+ [GitLab-CI使用cache加速构建过程](https://zacksleo.github.io/2018/01/26/GitLab-CI%E4%BD%BF%E7%94%A8cache%E5%8A%A0%E9%80%9F%E6%9E%84%E5%BB%BA%E8%BF%87%E7%A8%8B/)
+ [微信开发者工具HTTP调用](https://developers.weixin.qq.com/miniprogram/dev/devtools/http.html)
+ [Install GitLab Runner](https://docs.gitlab.com/runner/install/)
+ [Registering Runners](https://docs.gitlab.com/runner/register/index.html)
