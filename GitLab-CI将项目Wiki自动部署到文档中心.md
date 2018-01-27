---
title: GitLab-CI将项目Wiki自动部署到文档中心
date: 2018-01-27 11:48:09
tags: [GitLab-CI,Wiki,Gollum,DevOps]
---

## 概述

公司的GitLab中，有一个存放所有技术文档的Wiki仓库，按照目录分门别类，包括API文档，编码规范，技术专题文档等，通过与[Gollum进行持续部署](使用Git和Gollum搭建Wiki系统.md).

然而在GitLab中，每个项目都有自己的Wiki库, 所以在将项目文档合并更新到总Wiki仓库时，同步更新比较麻烦，通过充分使用GitLab的持续集成功能, 将项目Wiki与Wiki仓库集成, 从而实现了Wiki的自动部署，

同步时，自动同步的提交信息和提交人信息

## 步骤

### 配置SSH

+ GitLab中在使用SSH的时候, 会生成公钥和私钥对

+ 将公钥添加到gitlab上, 以便于该用于可以拉取代码

+ 在 `CI/CD Piplines`中设置 `Secret Variables`, 这里名为 `SSH_PRIVATE_KEY`

 `SSH_PRIVATE_KEY` 值为私钥.


### 编写 `.gitlab-ci.yml` 文件, 注入私钥, 通过`ssh`执行远程命令

 
 创建一个分支, 如`docs`, 在该分支中添加 `gitlab-ci.yml`文件, 实现wiki自动提交, 内容形如以下内容:
 
 ```
 
 image: zacksleo/docker-composer:develop
 
 before_script:
     - eval $(ssh-agent -s)
     - echo "$SSH_PRIVATE_KEY" > deploy.key
     - chmod 0600 deploy.key
     - ssh-add deploy.key
     - rm -f deploy.key
     - mkdir -p ~/.ssh
     - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
 
 build-docs:
     stage: deploy
    variables:
        GIT_STRATEGY: none
    dependencies: []
     script:
        # 定义变量: 项目Wiki的Git地址,项目(目录)别名
        - export WIKI_REPO=git@domain.com:project.wiki.git && export PROJECT_NAME=$CI_PROJECT_NAME
        # 创建临时目录, 用于存放和合并git文档
        - mkdir ~/tmp && cd ~/tmp
        # 克隆项目wiki
        - git --git-dir=~/tmp/$PROJECT_NAME.wiki.git clone --depth=1 $WIKI_REPO $PROJECT_NAME
        # 删除.git 只保留纯文档, 获取最近的提交日志,用户邮箱和名称  
        - cd $PROJECT_NAME && export GIT_LOG=`git log -1 --pretty=%B` && export GIT_EMAIL=`git log -1 --pretty=%ae` && export GIT_USERNAME=`git log -1 --pretty=%an` && rm -rf .git && cd ..
        # 注册Git账号
        - git config --global user.email $GIT_EMAIL && git config --global user.name $GIT_USERNAME       
        # 克隆联络Wiki
        - git clone git@domain.com:orgs/wiki.git
        # 删除旧wiki, 增加新wiki
        - rm -rf wiki/api/$PROJECT_NAME && mv -f $PROJECT_NAME wiki/api
        # 增加提交日志并提交
        - cd wiki && git add . && git commit -m "$PROJECT_NAME:$GIT_LOG" && git push origin master
        # 删除临时目录
        - rm -rf ~/tmp
     only:
         - docs
 
 ```
 
 其中, 将`WIKI_REPO`后面的`git@domain.com:project.wiki.git`替换为项目wiki的git地址,
 `$CI_PROJECT_NAME`替换为项目英文别名(如不改则使用当前GitLab的项目名), 用于在文档中心的api下面创建相关目录。 
 其他地方不需要修改。
  
 
 > 注意: 项目wiki的git地址与项目的git地址不相同, 请在Wiki右侧中的Clone repository 找到       
 
### 创建 Triggers Token

打开项目的 CI/CD Pipelines 选项,  找到 `Triggers`, 点击添加一个Token, 并从下方的 `Use webhook` 段落找到触发URL, 如
 
 ` https://domain.com/api/v4/projects/74/ref/REF_NAME/trigger/pipeline?token=TOKEN`
 
 将TOKEN替换为上述`Triggers`中获取的Token, 将 `REF_NAME` 替换分分支名称 `docs`, 得到最终URL

### 配置 Webhooks

打开项目的 integrations 选项, 在URL中, 填写上一步中拿到的URL

