---
title: GitLab-CI使用Rsync进行持续部署
date: 2017-09-08 12:52:37
tags: [GitLab-CI,DevOps]
---

## 简介

rsync命令是一个远程数据同步工具


## 主要参数

+ -r 递归目录

+ -t 保留修改时间

+ -v 详细日志

+ -h 输出数字以人类可读的格式

+ -z 在传输过程中压缩文件数据

+ -e 指定要使用的远程shell, 注意该过程需要注入SSH

## 配置参考

```

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


testing-server:
    stage: deploy
    image: alpine
    variables:
        DEPLOY_SERVER: "server-host"
    script:
        - cd deploy
        - rsync -rtvhze ssh . root@$DEPLOY_SERVER:/data/$CI_PROJECT_NAME --stats

```

## 注意

远程服务器需要安装rsync, 否则会出现 `bash: rsync: command not found` 错误


## 参考资料

+ [官方文档](https://download.samba.org/pub/rsync/rsync.html)
+ [[GitLabCI通过ssh进行自动部署]]
