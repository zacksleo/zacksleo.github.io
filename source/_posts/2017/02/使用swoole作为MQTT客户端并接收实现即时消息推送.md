---
title: 使用swoole作为MQTT客户端并接收实现即时消息推送
date: 2017-02-15 13:42:06
tags: [swoole,mqtt,即时推送,消息推送,mq]
---

## 环境准备

### 首先需要安装swoole

可以使用pecl进行安装 ，如 `pecl install swool`, 注意加上版本号

或者使用构建好的docker镜像，这里使用构建好的 `zacksleo/php:7.1-alpine-fpm-swoole` 镜像

### 使用 compose 安装依赖库

```
composer require jesusslim/mqttclient

```
## 编写业务逻辑代码

```php

<?php

namespace console\controllers;

use yii;
use console\components\mqtt\Logger;
use console\components\mqtt\Store;
use yii\console\Controller;
use mqttclient\src\swoole\MqttClient;
use mqttclient\src\subscribe\Topic;

class MqttController extends Controller
{
    public function actionClient()
    {
        $r = new MqttClient(getenv('TOKEN_MQTT_HOST'), getenv('TOKEN_MQTT_PORT'), 'push-server-client');
        $r->setAuth(getenv('TOKEN_MQTT_USERNAME'), getenv('TOKEN_MQTT_PASSWORD'));
        $r->setKeepAlive(60);
        $r->setLogger(new Logger());
        $r->setStore(new Store());
        $r->setTopics(
            [
                //消息回执
                new Topic('user-auth/create', function (MqttClient $client, $msg) {
                    //$msg 为获取到的消息体
                }),
                //消息打开
                new Topic('user-auth/delete', function (MqttClient $client, $msg) {
                   //$msg 为获取到的消息体
                })
            ]
        );
        $r->connect();
    }
}

```

## 执行命令

由于该客户端需要常驻内存，所以需要在 terminal 运行，如

```
./yii mqtt/client

```

## 进程保活

为了防止进程被杀死，获取因为异常退出，可以使用进程管理工具进行管理，如 `supervisor`

更多内容，参见 [[使用supervisor管理进程]]
