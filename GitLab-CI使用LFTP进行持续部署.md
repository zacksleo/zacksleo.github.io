---
title: GitLab-CI使用LFTP进行持续部署
date: 2017-09-08 12:52:22
tags: [GitLab-CI,DevOps,CD]
---

## 简介

LFTP是一款FTP客户端软件, 支持 FTP 、 FTPS 、 HTTP 、 HTTPS 、 SFTP 、 FXP 等多种文件传输协议。

本文介绍如何使用 LFTP 将文件同步到远程FTP服务器上, 从而实现自动部署

## mirror 命令及主要参数


+ -R  反向传输, 因为是上传(put)到远程服务器, 所以使用该参数 (默认是从远程服务器下载)

+ -L  下载符号链接作为文件, 主要处理文件软链接的问题

+ -v  详细输出日志

+ -n  只传输新文件 (相同的旧文件不会传输, 大大提升了传输效率)

+ --transfer-all  传输所有文件, 不论新旧

+ --parallel  同时传输的文件数

+ --file  本地文件

+ --target-directory 目标目录


## 配置参考

```
deploy:
    stage: deploy
    dependencies:
        - installing-dependencies
    script:
        - apk add lftp
        # 只上传新文件
        - lftp -c "set ftp:ssl-allow no; open -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOST; cd /wwwroot; mirror -RLnv ./ /wwwroot --ignore-time --parallel=50 --exclude-glob .git* --exclude .git/"
        # 指定目录覆盖上传 (强制更新)
        - lftp -c "set ftp:ssl-allow no; open -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOST;mirror -RLv ./vendor/composer /wwwroot/vendor/composer --ignore-time --transfer-all --parallel=50 --exclude-glob .git* --exclude .git/"
        # 单独上传autoload文件(强制更新)
        - lftp -c "set ftp:ssl-allow no; open -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOST;mirror -Rv --file=vendor/autoload.php --target-directory=/wwwroot/vendor/ --transfer-all"
    only:
        - master
        
```


## 参考资料

+ [LFTP官网](https://lftp.yar.ru/)
