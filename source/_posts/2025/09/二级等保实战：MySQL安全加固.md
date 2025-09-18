---
title: 二级等保实战：MySQL安全加固
date: 2025-09-08 13:38:53
tags: [二级等保实战, MySQL, 阿里云]
---

## 身份鉴别

## 空闲至多30分钟自动超时退出

打开 RDS 控制台，进入实例详情页面，点击左侧“参数设置”，找到 “wait_timeout”，默认参数值为 86400，改为 1800，修改完成后点击提交。

这样，用户空闲 30 分钟后，会自动退出登录。

![alt text](/images/2025/09/08/image.png)


## 登录失败处理策略


### 登录失败10次以内，锁定5分钟以上

> 需要 MySQL 8.0.19+ 才支持 FAILED_LOGIN_ATTEMPTS 和 PASSWORD_LOCK_TIME。

使用 高权限账号/root 账号，登录 MySQL，执行以下 SQL 语句：

```sql
ALTER USER 'test_user'@'%'
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME 1;
```

上面的意思是说，用户 test_user 在 10 次登录失败后，锁定 1 天。

需要注意的时，PASSWORD_LOCK_TIME 单位是天，不是分钟，且只能为整数。


使用下面的命令验证设置是否生效：

```sql
SELECT
   User, User_attributes
FROM mysql.user
WHERE user = 'test_user';
```

![alt text](/images/2025/09/08/image-7.png)


>解除锁定命令：ALTER USER 'test_user'@'%' ACCOUNT UNLOCK;

### 限制口令期限

> 口令限制至多90天

使用 高权限账号/root 账号，登录 MySQL，执行以下 SQL 语句：

```sql
ALTER USER 'test_user'@'%' PASSWORD EXPIRE INTERVAL 90 DAY;
```

验证是否生效：

```sql
SELECT user, host, password_expired, password_lifetime, password_last_changed
FROM mysql.user
WHERE user = 'test_user';
```

### 限制默认账户远程

打开 RDS 控制台，进入实例详情页面，点击数据库连接，点击“关闭外网地址”。

![alt text](/images/2025/09/08/image-1.png)

### 加密远程协议

> 数据库：使用SSL协议远程管理；

打开 RDS 控制台，进入实例详情页面，点击“数据安全性”，在 SSL 设置处，开启 SSL 证书信息，点击确定

![alt text](/images/2025/09/08/image-2.png)

### 数据库审计

打开 RDS 控制台，进入实例详情页面，点击“自治服务”，找到“安全审计”，点击开启安全审计


![alt text](/images/2025/09/08/image-3.png)


审计数据存储时长选择180天，点击提交

![alt text](/images/2025/09/08/image-4.png)

开启成功后，点击“开始使用”

![alt text](/images/2025/09/08/image-5.png)

然后就进入了查看界面

![alt text](/images/2025/09/08/image-6.png)