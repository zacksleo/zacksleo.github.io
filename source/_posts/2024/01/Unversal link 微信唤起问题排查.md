---
title: Universal link 微信唤起问题排查
date: 2024-01-11 07:57:00
tags: [Unversal link,微信,微信支付,app-site-association]
---

# 背景

App主体迁移，没有及时更新 apple-app-site-association 文件，导致唤起微信报错“由于应用unversal link校验不通过”

# Unversal link

Uncersal link 是苹果推出的替代 schema 的一种跨应用跳转方案。
需要先生成 app-site-association 文件，然后放在跳转域名的指定目录 `/.well-known/apple-app-site-association` 文件中。

如果通过nginx可以使用如下配置

```lua
location ~ /.well-known/apple-app-site-association {
          charset UTF-8;
          default_type application/json;
        }
```
上面的配置可以省略，只要返回这个文件就可以，至于反回的头格式（header），苹果并不关心


# 验证文件格式

1. 可以使用 `https://yurl.chayev.com/ios-results`验证配置的文件是否有效。

2. 需要注意的是，配置文件一旦发生变更，并不是立即生效，apple CDN有缓存，可能长达1小时以上。

3. 经过测试，国内CDN节点要比国外慢，如果需要快速验证唤起微信，可以挂VPN，使用海外节点，从而更快刷新CDN缓存。

4. 手动验证CDN是否刷新，访问网址，https://app-site-association.cdn-apple.com/a/v1/{domain}，将{domain}替换为自己的域名，查看返回内容是否生效。

5. App团队发生变化，如迁移Appstore所属开发者主体，需要更新apple-app-site-association 文件。

6. 另外，迁移过程中，为了兼容原有应用，app-site-association文件中应该保留原应用的配置信息，追加新应用配置。
# 参考资料

1. https://juejin.cn/post/7254809601873690681
2. https://yurl.chayev.com/ios-results


