---
title: 如何编写GitLab-CI配置文件
date: 2017-04-27 15:45:00
tags: [GitLab-CI]
---

## 创建文件

在根目录新建`.gitlab-ci.yml`文件.

该文件与项目其他文件一样, 同样受到版本控制, 所以可以在不同的分支下, 配置不同的持续集成脚本

## YAML语法

配置文件遵循YAML语法, 关于该语法的内容, 自行搜索

参考 [YAML 语言教程](http://www.ruanyifeng.com/blog/2016/07/yaml.html)

## 关键词

### 根主要关键词一览

| 关键词  | 含义  | 可选  | 备注 |
|---|---|---|---|
| image | 声明使用的Docker镜像  | 为空时使用默认镜像 |  该镜像应当满足脚本执行的环境依赖 |
| services  | Docker镜像使用的服务, 通过链接的方式来调用所需服务  | 可空  | 常用于链接数据库  |
| stages  | 定义构建阶段  | 为空时, 单纯定义jobs  |  项目的构建分为多个阶段, 例如: 安装依赖/准备, 编译, 测试, 发布等, 同时每个阶段包含若干任务 |
| before_script  | 定义每个job之前执行的脚本  | 可空  | 每个job启动时会先执行该脚本 |
| after_script  | 定义每个job之后执行的脚本  | 可空  | 同上 |
| variables  | 定义变量  | 可空  | 同上 |
| cache  | 定义与后续job之间应缓存的文件  | 可空  | 同上 |


Demo:

```
image: aipline
services:
    - mysql
    - redis
stages:
    - build
    - test
    - deploy
before_script:
    - bundle install  
after_script:
    - rm secrets
cache:
    paths:
    - binaries/
    - .config
```


### Jobs中的关键词

jobs中存在一些与根中相同的关键词, 这些一旦定义, 则会向前覆盖, 即根中定义的则不会在该job执行

job 这里译为**任务**

| 关键词  | 含义  | 可选  | 备注 |
|---|---|---|---|
| image | 声明任务使用的Docker镜像  | 为空时使用根中的定义 |  该镜像应当满足脚本执行的环境依赖 |
| services  | 任务中Docker镜像使用的服务, 通过链接的方式来调用所需服务  | 可空  | 常用于链接数据库  |
| stage  | 所属构建阶段  | 为空时则不使用stages  | 一个任务属于一个构建阶段 |
| before_script  | 定义每个job之前执行的脚本  | 可选  | 如果在job中定义则会覆盖根中的内容 |
| script  | 定义每个job执行的脚本  | 必须  |  |
| after_script  | 定义每个job之后执行的脚本  | 可选  | 同上 |
| variables  | 定义任务中使用的变量  | 可选  | 同上 |
| cache  | 定义与后续job之间应缓存的文件  | 可选  | 同上 |
| only  | 指定应用的Git分支  | 可选  | 可以是分支名称, 可用正则匹配分支, 也可是tags来指定打过标签的分支 |
| except  | 排除应用的Git分支  | 可选  | 同上 |
| tags  | 指定执行的GitLab-Runners  | 可选  | 通过匹配Runners的标签选定 |
| allow_failure  | 允许失败  | 默认为false  | 如果允许失败, 本次任务不会影响整个构建的结果  |
| when  | 定义合适执行任务  | 默认为always  | 有`on_success`, `on_failure`, `always` or `manual`可选  |
| dependencies  | 定义合任务所需要的工件  | 可空  | 需要首先定义工件  |
| artifacts  | 定义工件  | 可空  | 工件中指定的目录会在任务执行成功后压缩传到GitLab, 后面需要该工件的任务执行时, 再自行下载解压  |
| environment  | 定义环境  | 可空  | 在部署任务中, 定义该任务所属的环境  |

Demo:

```
installing-dependencies:
    script:
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
        - composer dump-autoload --optimize
    artifacts:
        name: "vendor"
        untracked: true
        expire_in: 60 mins
        paths:
            - vendor/    
docker-build-image:    
    stage: test
    only:
        - master
    except:
        - develop
    tags:
        - ruby
        - postgres
    allow_failure: true
    dependencies:
        - installing-dependencies
    script:        
        - docker build -t registry.com/mops/image:latest .
        - docker push registry.com/mops/image:latest 
         
```

注意:

 1. jobs的名称不能重名
 2. 同一阶段中的任务, 是并行执行的
 3. 上一阶段所有任务执行完后, 才会进入下一阶段
 4. 定义工件时, 务必定义工件的过期时间, 否则工件会一直寸在GitLab上, 占用空间
 5. 如果需要在任务中传递文件, 优先选择使用 `dependencies` (结合`artifacts`)
 
 

## 验证配置文件合法性

在GitLab中, 打开 `/ci/lint`网址, 将配置文件粘贴在些, 进行验证

### 相关文档 

+ [配置构建任务](https://docs.gitlab.com.cn/ce/ci/yaml/README.html)
+ [Configuration of your jobs with .gitlab-ci.yml](https://docs.gitlab.com/ce/ci/yaml/README.html)

