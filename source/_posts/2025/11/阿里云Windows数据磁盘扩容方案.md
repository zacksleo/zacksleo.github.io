---
title: 阿里云Windows数据磁盘扩容方案
date: 2025-11-03 10:22:26
tags: [阿里云, Windows, 磁盘扩容]
---

## 2TB 内扩容

如果磁盘总容量小于 2TB，则可以直接在阿里云控制台扩容后，在 Windows 系统内使用磁盘管理工具进行扩容。

![alt text](/images/2025/11/03/image.png)

## 大于 2TB 扩容

需要根据磁盘分区形式进行不同的扩容方案。

### 查询磁盘分区形式

打开磁盘管理工具，在下方磁盘处右键，点击属性，查看磁盘分区形式

![alt text](/images/2025/11/03/image-1.png)

点击卷标签页，查看分区形式是 MBR 还是 GPT，如下所示，如何磁盘分区形式是 MBR，则无法支持超过 2TB 的磁盘扩容，必须转换为 GPT 分区形式才能支持超过 2TB 的磁盘扩容。

![alt text](/images/2025/11/03/image-2.png)

### GTP 直接扩容

如果磁盘分区形式是 GTP，则可以直接在阿里云控制台扩容后，在 Windows 系统内使用磁盘管理工具进行扩容。这一步与 “2TB 内扩容方案”一致。

## MBR 磁盘扩容

整体思路如下，首先我们将原磁盘A 扩容至 2.5T，然后使用磁盘快照创建一个 2T 的临时数据磁盘 B，我们将磁盘 A 格式化为 GTP 分区形式，然后再使用快照回滚功能将数据还原至磁盘 B，最后将 B 中的数据全部拷贝至 A 中，最终实现磁盘扩容。

1. 使用快照进行备份

首先创建磁盘快照，在阿里云控制台[创建快照](https://help.aliyun.com/zh/ecs/user-guide/create-a-snapshot)，并等待快照完成。

![alt text](/images/2025/11/03/image-7.png)

2. 原磁盘扩容

在阿里云ECS控制台，进入块存储，点击扩容，然后根据提示扩容至 2.5T。

![alt text](/images/2025/11/03/image-6.png)

2. 使用快照创建一块新的磁盘 B

在刚创建的快照右侧，找到“创建云盘”，

![alt text](/images/2025/11/03/image-8.png)

这创建一块 2T 的磁盘，同样，在 ECS 控制台，打开块存储，点击“创建云盘”，是否挂载选择“挂载到ECS实例”，大小选择 2T（2048G），付费类型选择按量付费，然后点击确认下单。

![alt text](/images/2025/11/03/image-5.png)

3. 原磁盘A 格式化为 GTP 分区

### 3.1. 回在磁盘管理，选中原磁盘，右键，点击删除卷

![alt text](/images/2025/11/03/image-4.png)

### 3.2 当删除完毕后，右键单击磁盘，选择转换成 GTP 磁盘

![alt text](/images/2025/11/03/image-3.png)

### 3.3 确认转换生效

在磁盘右键，点击属性，查看磁盘分区形式，如果为 GTP，则说明转换成功。

#### 3.4 重新分区

在原磁盘A 中右键，点击“新建简单卷”，设置磁盘大小为最大值（这里2.5T），然后点击下一步，直到完成。

4. 恢复数据

注意，这里不可使用快照回滚功能恢复数据，因为回滚后磁盘分区形式会变为 MBR，无法支持超过 2TB 的磁盘扩容。

将磁盘B 中的数据全部拷贝至磁盘 A 中，这里可以使用 复制粘贴，或者 Robocopy，diskgenius  等工具进行数据复制。

等待全部数据复制完成后，将磁盘 B 卸载并删除，在阿里云控制台释放这个临时磁盘 B， 即完成整个扩容过程。

## 参考资料

- [手动创建单个快照](https://help.aliyun.com/zh/ecs/user-guide/create-a-snapshot)
- [扩容云盘（Windows）](https://help.aliyun.com/zh/ecs/user-guide/resize-windows-cloud-disks)
- [转换MBR分区为GPT分区](https://help.aliyun.com/zh/ecs/user-guide/convert-mbr-partitions-into-gpt-partitions)