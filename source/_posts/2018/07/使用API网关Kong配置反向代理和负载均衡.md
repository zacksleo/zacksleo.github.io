---
title: 使用API网关Kong配置反向代理和负载均衡
date: 2018-07-06 15:02:00
tags: [Gateway,网关,Kong,反向代理,负载均衡]
---

## 简介

[Kong](https://github.com/kong/kong) 是一个微服务API网关。
> Kong是一个云原生，快速，可扩展和分布式微服务抽象层（也称为API网关，API中间件或在某些情况下为Service Mesh）。
> 作为2015年的开源项目，其核心价值在于高性能和可扩展性。
> Kong积极维护，广泛应用于从创业公司到Global 5000以及政府组织等公司的生产。

[Konga](https://github.com/pantsel/konga) 是一个用于管理网关Kong的管理端，通过它可以方便的进网关进行管理配置。

使用网关能解决很多问题：

1. 解决端口和域名问题，代理后消除端口，将域名映射到端口，将服务映射成目录
2. 微服务代理，将微服务置于内网，统一由网关代理
3. 授权，可以配置授权管理，主要用于API授权
4. 负载均衡，可以增强高访问量下的可用性，解决部署时的服务中断问题

本文主要讲述使用 Konga 对 Kong 进行网关管理配置

## 安装

安装过程具体请参考官网文档，如果使用docker安装 Kong 和 Konga，可以参考 配置[docker-compose](https://github.com/warnstar/basic-auth-trans/blob/master/docker-compose.yml.dist)

## 配置反向代理

在 APIS 一栏，点击 `ADD NEW API` 按钮，添加一个代理：

+ 其中，Name 为显示名称，可任意填写；
+ Hosts 为所要使用的域名，如果不填写，则使用网关绑定的域名；如果填写，则可通过该域名访问；
+ Uris 为访问路径，如果需要将某个服务映射为一个目录，则此处需要配置; 
+ Upstream URL 为上游地址，即微服务实际地址，另外可将微服务置于内网，此处即为内网地址。

需要注意的是，如果页面中有301/302跳转，需要将 Preserve Host 勾选，以保证跳转后，header中携带的 Location 中的域名为代理后的域名，否则会出现实际域名/内网域名，造成混乱，甚至暴露微服务地址


### 示例一：普通反向代理

| 配置项  | 内容 | 说明  |
|---|---|---|
| Name  | dashboard  | 只是为了方便识别  | 
| Hosts  |  dashboard.xxx.com | 绑定的域名，类似于vhosts  | 
| Uris  |  / | 绑定目录  | 
| Methods  |   | 请求方法，默认不填  | 
| Upstream URL  | http://192.168.0.2:8080  | 实际微服务地址，建议使用内网ip, 并将该服务屏蔽外网访问  | 
| Strip uri  | YES |  |
| Preserve Host | YES | 转发时保留域名，处理301问题 |
| Https only  | YES | 如果不使用https，不勾选 |


## 配置负载均衡

需要注意的是，如果要使用负载均衡，需要配置 上游 (UPSTREAMS)。

在 UPSTREAMS 一栏，点击添加，Name 为一个域名形式的上游名称，如 `dashboard.upstream.xxx.com`, 添加完后，点击详情里面的Targets，添加一个目标，
Target 为实际的微服务地址，如 `	192.168.0.1:8080`, 注意这里不写http协议，只写ip或域名。

一个 UPSTREAMS 可以配置多个 Targets, 针对每个 Targets 设置不同的 Weight，即实现了负载均衡。

### 示例二：负载均衡

UPSTREAMS 配置

| 配置项  | 内容 | 说明  |
|---|---|---|
| Name  | coupon.api.foundation.com  | 类域名的别名  | 

Targets 配置

| 配置项  | 内容 | 说明  |
|---|---|---|
| Target  | 192.168.0.2:8001  | 微服务1的地址（建议使用内网）  | 
| WEIGHT  | 100  | 权重  | 

Targets2 配置

| 配置项  | 内容 | 说明  |
|---|---|---|
| Target  | 192.168.0.3:8001  | 微服务1的地址  | 
| WEIGHT  | 100  | 权重  | 

...

Apis 配置

| 配置项  | 内容 | 说明  |
|---|---|---|
| Name  | coupon  | 名称，任意  | 
| Hosts  |  |  留空使用网关默认的域名，如 api.xxx.com  | 
| Uris  | /coupon |  通过 api.xxx.com/coupon 访问该服务 | 
| Methods  |   |  留空不限制 | 
| Upstream URL  | http://coupon.api.foundation.com/api/  | 这里为配置的 UPSTREAMS 里的 Name  | 
| Strip uri  | YES |  |
| Preserve Host | YES |  |
| Https only  | YES | 如果不使用https，不勾选 |



## 参考文档

+ [Kong](https://github.com/kong/kong)
+ [Konga](https://github.com/pantsel/konga)
+ [basic-auth-trans](https://github.com/warnstar/basic-auth-trans)
