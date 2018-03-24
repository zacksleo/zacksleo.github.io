---
title: PHP7连接访问SqlServer及开发环境搭建
date: 2018-03-24 11:06:00
tags: [docker,PHP,PHP7,SqlServer,Yii]
---

## PHP运行环境镜像构建

PHP7中访问SqlServer需要安装sqlsrv 和 pdo_sqlsrv，在此之前需要安装一此必备依赖，如msodbcsql 和 unixodbc-dev，由于SqlServer暂时不支持alpine,所以选择jessie，尽量使镜像保持最小，构建脚本如下：

```
FROM php:7.1-fpm-jessie

ENV ACCEPT_EULA=Y

# Microsoft SQL Server Prerequisites
RUN apt-get update \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/8/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install msodbcsql  unixodbc-dev

RUN docker-php-ext-install mbstring \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv
    
```

## 启动本地开发需要的SqlServer服务

由于微软官方提供的SqlServer镜像，无法通过环境变量配置的方便创建数据库，故选择[mcmoe/mssqldocker](https://github.com/mcmoe/mssqldocker)镜像，

使用docker-compose配置方式如下：

```
version: '3.2'

services:
  db:
    build: .
    image: mcmoe/mssqldocker
    environment:
      ACCEPT_EULA: Y
      SA_PASSWORD: 2astazeY
      MSSQL_DB: dev
      MSSQL_USER: Kobeissi
      MSSQL_PASSWORD: 7ellowEl7akey
    ports:
      - "1433:1433"
    container_name: mssqldev
```

需要注意的是，MSSQL密码(即上面的SA_PASSWORD和MSSQL_PASSWORD)必须至少8个字符长，包含大写，小写和数字，否则数据库会创建失败


## 连接访问数据库

在程序中配置数据库的地方，配置DSN如下 

```
sqlsrv:Server=mssql;Database=dev

```
sqlsrv 为驱动名称

