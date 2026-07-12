---
title: 使用Appium在iOS上实现自动化2
date: 2025-06-04 17:46:31
tags: [appium, ios]
---

## 安装定位工具

```bash
appium plugin install --source=npm appium-inspector-plugin
```

## 运行

```bash
appium --use-plugins=inspector --allow-cors
```

## 打开浏览器

在浏览器中打开 `http://localhost:4723/inspector`


在右侧编辑 json, 点击保存按钮，点击 Start Session

```json
{
  "platformName": "iOS",
  "appium:automationName": "XCUITest",
  "appium:udid": "00000030-0018581E1E43402E"
}
```

![alt text](https://blog.shaohushuo.com/images/2025/06/04/image-2.png)


点击 +号，开启位置定位查询

![alt text](https://blog.shaohushuo.com/images/2025/06/04/image-3.png)

## 编写测试代码

index.js

```js
// Appium 服务配置
const APPIUM_HOST = '127.0.0.1';
const APPIUM_PORT = 4723;
// Appium 配置
const iosOptions = {
  capabilities: {
    platformName: "iOS",
    "appium:udid": "00000030-0018581E1E43402E",
    "appium:platformVersion": "16.2",          // 修改为你的 iOS 版本
    "appium:deviceName": "iPhone",   // 修改为你的设备名称
    "appium:automationName": "XCUITest",
    "appium:bundleId": "com.xxx.xxx",   // bundle ID
    "appium:noReset": true,
    "appium:newCommandTimeout": 300
  },
  hostname: APPIUM_HOST,
  port: APPIUM_PORT,
};

async function startTest() {
  // 初始化 Appium 驱动
  const driver = await wdio.remote(iosOptions);
  // 模拟点击事件
  await driver.performActions([{
    type: 'pointer',
    id: 'finger1',
    parameters: { pointerType: 'touch' },
    actions: [
      { type: 'pointerMove', duration: 0, x: 80, y: 300 },
      { type: 'pointerDown', button: 0 },
      { type: 'pause', duration: 100 },
      { type: 'pointerUp', button: 0 }
    ]
  }]);
}

// 启动测试
startTest().catch(console.error);
```

## 启动测试

首先启动 Appium 服务器

```bash
appium
```

然后运行测试代码
```bash
node index.js
```

## 更多问题

非iOS原生应用，如何解决复制粘贴问题？

这种情况下无法直接复制或者发送文本，一个思路是使用微信输入法的剪贴板/常用语，通过模拟点击操作，间接实现输入功能。

## 参考资料

- [appium-inspector](https://appium.github.io/appium-inspector/latest/quickstart/installation/)