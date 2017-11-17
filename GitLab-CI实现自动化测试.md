---
title: GitLab-CI实现自动化测试
date: 2017-05-30 10:37:33
tags:
---

# GitLab-Ci实现自动化测试

>持续集成的目的，就是让产品可以快速迭代，同时还能保持高质量。它的核心措施是，代码集成到主干之前，必须通过自动化测试。只要有一个测试用例失败，就不能集成。

使用自动化测试, 可以提高软件的质量和可靠性, 今早发现其中的缺陷和问题, 以便即时改正.



## 配置环境

首先需要一个满足运行自动化测试的Docker镜像, 以便后面运行测试代码, 例如:

```
image: zacksleo/docker-composer:develop

```

## 配置服务

某些测试需要使用额外的服务, 如数据库、缓存服务器等等, 并通过`variables`配置服务中的一些变量

```
services:
    - mysql:5.6
    - redis:latest
variables:
    MYSQL_ROOT_PASSWORD: root
    MYSQL_DATABASE: web
    MYSQL_USER: web
    MYSQL_PASSWORD: web    
```

## 声明依赖工件

一般在测试前要进行准备过程, 如安装依赖库或者编译等, 可将上述过程生成的的文件, 通过依赖声明, 传递过来, 这样可以比避免重复执行相关过程.

```
installing-dependencies:
    stage: prepare
    script:
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
        - composer dump-autoload --optimize
    artifacts:
        name: "vendor"
        untracked: true
        expire_in: 60 mins
        paths:
            - $CI_PROJECT_DIR/vendor
```

```
dependencies:
    - installing-dependencies

```
## 配置测试脚本

  假定你已经在本地编写好了测试代码, 并且可以本地运行, 那么就可以通过调整和适配, 让测试可以在GitLab-CI中自动化执行, 在下面的例子中,
  
  测试代码位于`tests`目录,并且`.env`中配置了一些环境变量, 该文件的作用是为了让不同环境使用不同的一组变量, 如数据库、接口地址、账号等等，
  这样做的目录可以尽量少的变更代码，保持核心代码的稳定性和适应能力， 通过`php -S` 启动了一个本地接口服务, 最后调用api测试, 对所有接口
  进行测试
  
  在下面的例子中, 还声明了`coverage`, 这个用来说明代码测试覆盖率的取得方法, 因为在测试中会将覆盖率输出(`--coverage --no-colors`),
  GitLab-CI 通过正则匹配输出内容, 读取到覆盖率, 从而显示在项目徽标处  
  

```
dependencies:
    - installing-dependencies
script:
    - cp tests/.env .env
    - ./yii migrate/up --interactive=0
    - php -S localhost:80 --docroot api/tests &>/dev/null&
    - ./vendor/bin/codecept run api -c tests --coverage --no-colors

    coverage: '/^\s*Lines:\s*\d+.\d+\%/'    
```

## 测试失败如何处理

  当测试失败后, 除了查看`Pipline`中的任务输出, 我们还应当详细查看测试中的相关日志, 下面这里, 将需要查看的文件生成工件, 在GitLab中下载,
  然后可以在本地详细查看, `when`说明了仅在测试失败时, 才生成工件
  
  ```
      artifacts:
          name: "debug"
          when: on_failure
          untracked: true
          expire_in: 60 mins
          paths:
              - $CI_PROJECT_DIR/api/runtime
              - $CI_PROJECT_DIR/tests/_output
  ```
  
## 完整的例子

下面是一个完整的API自动化测试的盒子

```
api-test:
    stage: testing
    services:
        - mysql:5.6
        - redis:latest
    variables:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: web
        MYSQL_USER: web
        MYSQL_PASSWORD: web
    dependencies:
        - installing-dependencies
    script:
        - cp tests/.env .env
        - ./yii migrate/up --interactive=0
        - php -S localhost:80 --docroot api/tests &>/dev/null&
        - ./vendor/bin/codecept run api -c tests
    artifacts:
        name: "debug"
        when: on_failure
        untracked: true
        expire_in: 60 mins
        paths:
            - $CI_PROJECT_DIR/api/runtime
            - $CI_PROJECT_DIR/tests/_output
    only:
        - develop
        - master
```  
  
关于持续集成完整的项目, 请查看 [zacksleo/yii2-app-advanced](https://github.com/zacksleo/yii2-app-advanced) 项目

  [使用Docker镜像](https://docs.gitlab.com/ce/ci/docker/using_docker_images.html)