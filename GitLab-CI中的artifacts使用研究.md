---
title: GitLab-CI中的artifacts使用研究
date: 2017-04-18 23:56:44
tags: [GitLab-CI]
---

在GitLab-CI中, `cache`与`artifacts`比较容易混淆.

其中 `cache` 指的是缓存, 常用于依赖安装中, 如几个`jobs`都需要安装相同的依赖, 可以使用`依赖`, 此时可以加快依赖的安装进度;
对于`artifacts`则是将某个`工件`上传到GitLab提供下载或后续操作使用, 由于每个`job`启动时, 都会自动删除`.gitignore`中指定的文件, 因此对于依赖安装目录, 即可以使用`cache`, 也可以使用`artifacts`.

两个主要有以下几个区别:

1. 虽然定义了`cache`, 但是如果`cache`和`.gitignore`中重复的这部分, 仍然需要重新安装
2. 重新安装时因为使用的是缓存, 所以很有可能不是最新的
3. 特别是开发环境, 如果每次都希望使用最新的更新, 应当删除`cache`, 使用`artifacts`, 这样可以保证确定的更新
4.`artifacts`中定义的部分, 会自动生成, 并可以传到下面的`job`中解压使用, 避免了重复依赖安装等工作
5. 如果使用Docker运行Gitlab-Runner, `cache`会生成一些临时容器, 不容易清理
6. `artifacts`可以设置自动过期时间, 过期自动删除
7. `artifacts`会先传到GitLab服务器, 然后需要时再重新下载, 所以这部分也可以在GitLab下载和浏览

## `artifacts` 的依赖使用

下面是一个使用`artifacts`的例子, 首先有一个安装依赖的工作, 然后工作完成后, 会将安装文件转移到后续的工作时

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
code-review:
    stage: testing
    dependencies:
        - installing-dependencies
    script:
        - php vendor/bin/phpcs --config-set ignore_warnings_on_exit 1
        - php vendor/bin/phpcs --standard=PSR2 -w --colors ./
test-image:
    stage: build
    image: docker:latest
    services:
        - docker:dind
    dependencies:
        - installing-dependencies
    script:        
        - docker build -t $CI_PROJECT_NAME:latest .
        - docker push domain.com/repos/$CI_PROJECT_NAME:latest
    only:
        - develop    
```

如果上述过程使用`cache`, 则会变成下面这样子, 注意, 此时每次都要执行`composer install`这样的依赖安装工作, 即`before_script`

```
cache:
    paths:
        - vendor
before_scritp:    
    - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
    - composer dump-autoload --optimize    
code-review:
    stage: testing    
    script:
        - php vendor/bin/phpcs --config-set ignore_warnings_on_exit 1
        - php vendor/bin/phpcs --standard=PSR2 -w --colors ./
test-image:
    stage: build
    image: docker:latest
    services:
        - docker:dind    
    script:        
        - docker build -t $CI_PROJECT_NAME:latest .
        - docker push domain.com/repos/$CI_PROJECT_NAME:latest
    only:
        - develop    
```

或


```
cache:
    paths:
        - vendor
code-review:
    stage: testing    
    script:    
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
        - composer dump-autoload --optimize     
        - php vendor/bin/phpcs --config-set ignore_warnings_on_exit 1
        - php vendor/bin/phpcs --standard=PSR2 -w --colors ./
test-image:
    stage: build
    image: docker:latest
    services:
        - docker:dind    
    script:        
        - composer install --prefer-dist --optimize-autoloader -n --no-interaction -v --no-suggest
        - composer dump-autoload --optimize      
        - docker build -t $CI_PROJECT_NAME:latest .
        - docker push domain.com/repos/$CI_PROJECT_NAME:latest
    only:
        - develop    
```
否则, 会出现类似 `vendor not found`的问题

## 禁用artifacts

  默认artifacts会自动在不同的stage中传输, 如果该stage中的job不需要artifacts, 则可以禁用artifacts, 以加速构建速度
  
  ```
     dependencies: []
  
  ```

## 注意

>> 使用`cache`会出现一个问题, 就是缓存有可能使用上次执行该`job`时的缓存, 不能保证某些文件最新


## 相关文档

[Introduction to job artifacts](https://docs.gitlab.com/ce/user/project/pipelines/job_artifacts.html)