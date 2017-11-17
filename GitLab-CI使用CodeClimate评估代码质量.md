---
title: GitLab-CI使用CodeClimate评估代码质量
date: 2017-10-25 09:33:41
tags:
---

## 简介

Code Climate 是一个代码测试工具, 它可以帮助你进行代码冗余检测、质量评估，同时支持多种语言，如PHP, Ruby, JavaScript, CSS, Golang, Python 等。


## 使用

### 配置GitLab Runner 

```
[[runners]]
  ....
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "docker:latest"
    privileged = true
    disable_cache = false
    cache_dir = "cache"
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock", "/tmp/builds:/builds"]
    shm_size = 0
```

注意, 需要增加一个 `/tmp/builds:/builds` , 这里用于映射放代码。否则根据官方文档中的描述，无法正常实现

为了能使用宿主机的docker 缓存, 加快构建速度, 这里使用 sock 绑定的方式使用docker, 不使用 docker in docker 


### 配置 .gitlab-ci.yml 文件

```YAML
codeclimate:
  image: docker:latest
  script:
    - docker pull codeclimate/codeclimate
    - VOLUME_PATH=/tmp/builds"$(echo $PWD | sed 's|^/[^/]*||')"
    - docker run -v /tmp/cc:/tmp/cc -v $VOLUME_PATH:/code -v /var/run/docker.sock:/var/run/docker.sock codeclimate/codeclimate validate-config
    - docker run --env CODECLIMATE_CODE="$VOLUME_PATH" -v /tmp/cc:/tmp/cc -v $VOLUME_PATH:/code -v /var/run/docker.sock:/var/run/docker.sock codeclimate/codeclimate analyze -f text    
```

### 配置 .codeclimate.yml

```YAML
engines:
  duplication:
    enabled: true
    config:
      languages:
      - javascript
      - php
  csslint:
      enabled: true
  eslint:
    enabled: true
  fixme:
    enabled: true
  phpmd:
    enabled: true
ratings:
  paths:
  - "**.js"
  - "**.css"
  - "**.php"
exclude_paths:
- tests/
- vendor/

```

相关配置请参考[官方文档](https://docs.codeclimate.com/docs)

## 参考资料

+ [CodeClimate支持的语言和引擎](https://docs.codeclimate.com/docs/list-of-engines)
+ [GitLab-CI配置CodeClimate](https://docs.codeclimate.com/docs/list-of-engines)
+ [CodeClimate in Gitlab CI](https://blog.buzzell.io/codeclimate-in-gitlab-ci/)
+ [CodeClimate官方文档](https://docs.codeclimate.com/docs)