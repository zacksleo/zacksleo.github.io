---
title: GitLab-CI集成FTP自动发布
date: 2025-04-17 11:24:48
tags: [GitLab-CI,DevOps,FTP]
---

## 简介

在某些场景下，代码是以 FTP 的方式部署到服务器上，那么我们可以使用 GitLab-CI 来实现自动发布。


## 配置参考

```
.sftp-deploy: &sftp-deploy |-
    files=$(git log -10 --pretty=format: --name-only | grep -v '^$' | sort -u)
    include_patterns=$(echo "$files" | sed 's/[][*?]/\\&/g' | paste -sd, -)
    lftp -c "set ftp:ssl-allow no; open -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOST; cd /; mirror -RLnv --no-perms --exclude-glob .git* --exclude .git/ --include-glob='{$include_patterns}' ./ /"

stages:
    - deploy

deploy:
    stage: deploy
    image: zacksleo/docker-composer:lftp
    dependencies: []
    script:
        - lftp -c "set ftp:ssl-allow no; open -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOST; cd /; mirror -RLnv --no-perms ./ / --ignore-time --exclude-glob .git* --exclude .git/"
        - *sftp-deploy
    only:
        - master
        - tags

```

## 配置说明


- `FTP_HOST`: FTP 服务器地址
- `FTP_USERNAME`: FTP 用户名
- `FTP_PASSWORD`: FTP 密码

以上通过在 GitLab 的 CI/CD 设置中添加环境变量来配置。

script 中有两段脚本，第一行使用 lftp 命令，将项目中的文件上传到服务器，配置了 --ignore-time, lftp 将会使用文件大小比对方式，只有文件大小不一样时，文件才会被上传。

有时候，即使文件内容有更改，但如果文件大小不发生变化，第一段脚本不会传输该文件，于是我们通过第二段脚本来弥补这个问题。

第二段脚本，根据最近 10 次的 git 提交记录，找出所有涉及的修改的文件，组合成 --include-glob 所需要的表达式， 通过 lftp 的 --include-glob 命令，来指定传输这些文件。

> 上述 include_patterns 会输出类似这样的形式: path/to/file1,path/to/file2 ,也就是说最终的命令形式为 --include-glob='path/to/file1,path/to/file2'


## 参考资料

- [LFTP官网](https://lftp.yar.ru/)
- [GitLab-CI使用LFTP进行持续部署](https://blog.shaohushuo.com/2017/09/08/GitLab-CI%E4%BD%BF%E7%94%A8LFTP%E8%BF%9B%E8%A1%8C%E6%8C%81%E7%BB%AD%E9%83%A8%E7%BD%B2/)
