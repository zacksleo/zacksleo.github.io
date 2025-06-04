---
title: GitLab-CI对JavaScript项目持续集成或部署
date: 2018-03-13 11:34:00
tags: [GitLab-CI,DevOps,SSH,CD,CI,Yarn,npm,React]
---

## 需求

团队使用React开发了一套前端页面, 为了方便协作和部署, 使用 EsLint 进行代码格式审查, 同时进行持续集成和部署, 提高开发效率


## 配置

```
image: zacksleo/node

before_script:
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" > ~/deploy.key
    - chmod 0600 ~/deploy.key
    - ssh-add ~/deploy.key
    - mkdir -p ~/.ssh
    - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
    - export APP_ENV=testing
    - yarn config set registry 'https://registry.npm.taobao.org'
stages:
    - prepare
    - test
    - build
    - deploy

variables:
    COMPOSER_CACHE_DIR: "/cache/composer"
    DOCKER_DRIVER: overlay2
build-cache:
    stage: prepare
    script:
        - yarn install --cache-folder /cache/yarn
    cache:
      key: "$CI_COMMIT_REF_NAME"
      paths:
        - node_modules
    except:
        - docs
        - tags
    when: manual
eslint:
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
        - yarn eslint ./
    except:
        - docs
        - develop
        - master
        - tags
build-check:
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
        - yarn build
    except:
        - docs
        - develop
        - master
        - tags
build-package:
    stage: test
    script:
        - if [ ! -d "node_modules" ]; then
        - yarn install --cache-folder /cache/yarn
        - fi
        - if [ $CI_COMMIT_TAG ];then
        - cp deploy/production/.env .env
        - fi
        - yarn build
    dependencies: []
    cache:
      key: "$CI_COMMIT_REF_NAME"
      policy: pull
      paths:
        - node_modules
    artifacts:
        name: "build"
        untracked: false
        expire_in: 60 mins
        paths:
            - build
    except:
        - docs
    only:
        - develop
        - master
        - tags
production-image:
    stage: build
    image: docker:latest
    dependencies:
        - build-package
    before_script: []
    script:
        - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
        - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG .
        - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
        - docker rmi $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    only:
        - tags
production-server:
    stage: deploy
    dependencies: []
    cache: {}
    script:
        - cd deploy/production
        - rsync -rtvhze ssh . root@$DEPLOY_SERVER:/data/$CI_PROJECT_NAME --stats
        - ssh root@$DEPLOY_SERVER "docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY"
        - ssh root@$DEPLOY_SERVER "export COMPOSE_HTTP_TIMEOUT=120 && export DOCKER_CLIENT_TIMEOUT=120 && echo -e '\nTAG=$CI_COMMIT_TAG' >> .env && cd /data/$CI_PROJECT_NAME && docker-compose pull web && docker-compose stop && docker-compose rm -f && docker-compose up -d --build"
    only:
        - tags
    environment:
        name: staging
        url: https://xxx.com
```

## 说明

首先使用EsLint进行代码格式检查, 每次合并到主干分支, 进行构建检查, 每次添加Tags, 构建Docker镜像,并进行部署


