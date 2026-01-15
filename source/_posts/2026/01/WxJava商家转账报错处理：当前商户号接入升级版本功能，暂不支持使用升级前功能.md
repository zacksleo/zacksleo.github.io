---
title: WxJava商家转账报错处理：当前商户号接入升级版本功能，暂不支持使用升级前功能
date: 2025-11-04 13:53:04
tags: [Keepalived, Windows, 磁盘扩容]
---

## 错误信息

使用 WxJava 调用微信支付接口时，出现以下错误信息：

当前商户号接入升级版本功能，暂不支持使用升级前功能，请在产品中心-商家转账-前往功能查看接口文档
---

## 错误分析

当前使用是旧版本的商家转账接口，需要升级为新版本的接口。新版API使用 `/v3/fund-app/mch-transfer/transfer-bills` 接口。


```java
  // 构建转账请求
  TransferBillsRequest request = TransferBillsRequest.newBuilder()
  .appid("wx1234567890123456")                    // 应用ID
  .outBillNo("TRANSFER_" + System.currentTimeMillis()) // 商户转账单号，确保唯一
  .transferSceneId("1005")                       // 转账场景ID（1005=佣金报酬）
  .openid("oUpF8uMuAJO_M2pxb1Q9zNjWeS6o")       // 收款用户的openid
  .userName("张三")                               // 收款用户真实姓名（可选，会自动加密）
  .transferAmount(100)                           // 转账金额，单位：分（此处为1元）
  .transferRemark("佣金报酬")                     // 转账备注，用户可见
  .notifyUrl("https://your-domain.com/transfer/notify") // 异步通知地址（可选）
  .userRecvPerception("Y")                       // 用户收款感知：Y=会收到通知，N=不会收到通知
  .build();
```


## 参考资料

- [发起转账接口文档]](https://pay.weixin.qq.com/doc/v3/merchant/4012716434)
- [微信商家转账新版的开发流程和常见问题](https://blog.csdn.net/qq_15036547/article/details/146402476)
- [Example](https://github.com/binarywang/WxJava/blob/develop/weixin-java-pay/src/main/java/com/github/binarywang/wxpay/example/NewTransferApiExample.java#L38)