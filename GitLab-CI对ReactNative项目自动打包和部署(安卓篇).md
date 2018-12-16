---
title: GitLab-CI对ReactNative项目自动打包和部署(安卓篇)
date: 2018-04-08 11:21:26
tags: [GitLab-CI, DevOps, ReactNative, 持续部署, React Native]
---

# GitLab-CI对ReactNative项目自动打包和部署(安卓篇)

## 简述

本文讲述了如何使用 GitLab-CI 对 ReactNative 项目，自动打包和部署，由于安卓环境更易于在Docker上搭建环境，所以先实现了安卓应用的打包和部署。

## 环境依赖

1. Docker环境使用 registry.gitlab.com/wldhx/gitlab-ci-react-native-android:master 镜像, 该镜像包含了ReactNative打包安卓应用所需要的所有依赖
2. 注册一个 [fir.im](https://fir.im/) 账号
2. Python3。 部署应用采用的 fir.im平台发布，因此实现了一段用于自动上传apk的Python脚本
3. Node。 用于安卓依赖和格式化检查

## 编写GitLab-CI 脚本

cat .gitlab-ci.yml

```YAML
image: node

stages:
    - test
    - build
    - deploy

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - android/.gradle/

variables:
    NPM_CONFIG_CACHE: "/cache/npm"
    YARN_CACHE_FOLDER: "/cache/yarn"
    DOCKER_DRIVER: overlay2
lint:
    stage: test
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
        - yarn run lint
    except:
        - master
        - tags
    tags:
        - docker

build-package:
    stage: test
    dependencies: []
    cache:
      key: "$CI_COMMIT_REF_NAME"
      policy: pull
      paths:
        - node_modules
    script:
        - yarn install
    artifacts:
        name: "node_modules"
        untracked: false
        expire_in: 60 mins
        paths:
            - node_modules
    only:
        - master
        - tags
    tags:
        - docker

build-android:
    image: registry.gitlab.com/wldhx/gitlab-ci-react-native-android:master
    stage: build
    dependencies:
        - build-package
    script:
        - cd android && ./gradlew assembleRelease --no-daemon
    artifacts:
        expire_in: 7 days
        paths:
        - android/app/build/outputs/apk/
    only:
        - master
        - tags

release-android:
    image: python:3
    stage: deploy
    cache: {}
    dependencies:
        - build-android
    script:
        - pip install -r requirements.txt
        - if [[ -z "$CI_COMMIT_TAG" ]];then
        - echo $(git log -3 --pretty=%s | tail -1) > ./release.txt
        - else
        - echo $(git tag -l --format='%(contents)' $CI_COMMIT_TAG) > ./release.txt
        - fi
        - python ./upload.py
    only:
        - master
        - tags
```

该脚本分为三个阶段，第一阶段进行格式化检查，和安装npm依赖，第二阶段用于构建apk, 第三阶段将apk上传到fir.im平台上，
其中 release.txt 用于存储最近的更新日志，便于在上传apk时，加上对应信息。

requirement.txt 文件中则使用了`request`库:

cat requirement.txt
```
requests
```

upload.py 文件则调用fir.im的上传API, 则 apk 上传到改平台，需要注意的时，api_token 需要在 fir.im 平台的右上角个人信息处获取

cat upload.py

```python

import requests
import os


def file_get_contents(filename):
    with open(filename) as f:
        return f.read()


r = requests.post(
    'https://api.fir.im/apps',
    data={'type': 'android',
          'bundle_id': 'com.company.package',
          'api_token': '个人的API TOKEN'
          }
)

data = r.json()

if os.environ.get('CI_COMMIT_TAG') is None:
    tag = 'latest'
else:
    tag = os.environ['CI_COMMIT_TAG']

changelog = file_get_contents('./release.txt')

files = {'file': open(
    './android/app/build/outputs/apk/release/app-release.apk', 'rb')}
r2 = requests.post(
    data['cert']['binary']['upload_url'],
    data={
        'key': data['cert']['binary']['key'],
        'token': data['cert']['binary']['token'],
        'x:name': '应用名称',
        'x:version': tag,
        'x:build': 'com.company.package',
        'x:changelog': changelog
    },
    files=files
)

print(r2.json())

```




## 参考内容

+ [How to build and publish your React Native Android applications using GitLab CI](https://gitlab.com/gitlab-com/community-writers/issues/12)
+ [gitlab-ci-react-native-android](https://gitlab.com/wldhx/gitlab-ci-react-native-android)
+ [fir.im 开发文档](https://fir.im/docs)
