---
title: OpenClaw实战：飞书安装和使用
date: 2026-04-10 23:31:08
tags: [OpenClaw实战, OpenClaw, 龙虾, AI]
---


```bash
npx -y @larksuite/openclaw-lark install
```
输出内容如下，然后按照提示使用飞书 App 扫码即可

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image.png)


## 配置

1.开启流式输出

默认是不开启的，打开后体验更好，不会觉得太慢了

```bash
openclaw config set channels.feishu.streaming true

```

流式输出开启之后，当机器人开始回复时，会实时以流式的方式输出内容，而不是等全部内容生成完毕后一次性输出，也就是能看到机器人在“打字”，体验更好。


![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-5.png)



2.流式输出时显示耗时和状态

```bash
openclaw config set channels.feishu.footer.elapsed true  # 开启耗时
openclaw config set channels.feishu.footer.status true  # 开启状态展示
```

状态展示就是在消息发送后，会在下方展示一个敲击键盘的表情，表示 openclaw 正在处理中。


![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-1.png)

开启耗时后，则会在每次对话末尾，显示当前使用的时间。

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-2.png)

2. 多任务并行及独立上下

这个可以让机器人在单独话题对话框中，使用单独的上下文，可多任务并行。


我们可以在聊天消息卡片中右击，点击 “新建话题”，则会创建一个单独的会话窗口，机器人在这个窗口中会使用独立的上下文，和其他窗口互不干扰。

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-4.png)


下图展示了多个话题的使用示例

![alt text](https://blog.shaohushuo.com/images/2026/04/10/image-3.png)

```bash
openclaw config set channels.feishu.threadSession true
```


## 参考文档

- [OpenClaw 飞书官方插件使用指南](https://bytedance.larkoffice.com/docx/MFK7dDFLFoVlOGxWCv5cTXKmnMh)