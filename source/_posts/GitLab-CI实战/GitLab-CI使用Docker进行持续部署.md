---
title: GitLab-CI使用Docker进行持续部署
date: 2017-04-22 22:33:31
tags: [GitLab-CI,Docker,DevOps,CD]
---

Docker镜像通过私有仓库进行发布(如阿里云), 发布命令为:

```
 docker login -u username -p password registry.demo.com
 docker build -t registry.demo.com/repos/$CI_PROJECT_NAME:latest .
 docker push registry.demo.com/repos/$CI_PROJECT_NAME:latest

```
其中 `username`是用户名, `password`是密码, `registry.demo.com`是私有镜像库地址,

`$CI_PROJECT_NAME` 是GitLab-CI内置变量, 会自动替换为项目的名称, 这里也可以直接写死, 如

`docker build -t registry.demo.com/repos/image-name:latest .`

`image-name`, 就是要构建的镜像名称, `latest`是TAG标签, `repos`是仓库的空间名称

在下面的例子中, 首先通过composer安装依赖库, 然后通过artifacts传递给构建任务, 构建完镜像将镜像发布到私有库, 
部署时通过拉取最新的镜像库, 进行部署

> 项目的deploy目录中, 放置一些配置文件, 如`Dockerfile`, `docker-compose.yml`等, 通过`rsync`同步到部署服务器上, 用于部署所需


```
image: zacksleo/docker-composer:1.1

before_script:
    - 'which ssh-agent || ( apk update && apk add openssh-client)'
    - apk add rsync
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" > ~/deploy.key
    - chmod 0600 ~/deploy.key
    - ssh-add ~/deploy.key
    - mkdir -p ~/.ssh
    - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
    - export APP_ENV=testing

stages:
    - prepare    
    - build
    - deploy

variables:
    COMPOSER_CACHE_DIR: "/cache/composer"
    DOCKER_DRIVER: overlay

installing-dependencies:
    stage: prepare
    script:
        - composer install --prefer-dist -n --no-interaction -v --no-suggest
    artifacts:
        name: "vendor"
        untracked: true
        expire_in: 60 mins
        paths:
            - $CI_PROJECT_DIR/vendor    
test-image:
    stage: build
    image: docker:latest
    services:
        - docker:dind
    dependencies:
        - installing-dependencies
    script:
        - docker login -u username -p password registry.demo.com
        - docker build -t registry.demo.com/repos/$CI_PROJECT_NAME:latest .
        - docker push registry.demo.com/repos/$CI_PROJECT_NAME:latest
testing-server:
    stage: deploy
    image: alpine
    variables:
        DEPLOY_SERVER: "server-host"
    script:
        - cd deploy
        - rsync -rtvhze ssh . root@$DEPLOY_SERVER:/data/$CI_PROJECT_NAME --stats        
        - ssh root@$DEPLOY_SERVER "docker login -u username -p password registry.demo.com"
        - ssh root@$DEPLOY_SERVER "cd /data/$CI_PROJECT_NAME && docker-compose stop && docker-compose rm -f && docker-compose pull && docker-compose up -d"
        - ssh root@$DEPLOY_SERVER "docker exec -i $CI_PROJECT_NAME chown www-data:www-data web/assets"
        - ssh root@$DEPLOY_SERVER "docker exec -i $CI_PROJECT_NAME ./yii migrate/up --interactive=0"
    
```


![](http://ww1.sinaimg.cn/large/675eb504ly1fezvjdberyj20w30axdh2.jpg)


## 相关文档

[Using Docker Build](https://docs.gitlab.com/ce/ci/docker/using_docker_build.html)
