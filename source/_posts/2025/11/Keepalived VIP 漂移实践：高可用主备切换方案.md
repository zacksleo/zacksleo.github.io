---
title: Keepalived VIP 漂移实践：高可用主备切换方案
date: 2025-11-03 17:10:25
tags: [Keepalived, Windows, 磁盘扩容]
---

在高可用架构中，VIP（虚拟 IP）漂移是实现主备切换的核心手段。本文介绍如何利用 Keepalived 实现 VIP 自动漂移和回切，确保服务持续可用。

---

## 一、背景与目标

在典型的两台主备服务器部署场景中：

- **主节点**：提供服务，优先级高
- **备节点**：备用服务器，优先级低
- **VIP（虚拟 IP）**：客户端只连接 VIP，不关心实际主机
- **目标**：当主节点宕机或服务异常时，VIP 自动漂移到备节点；主节点恢复后可自动回切。

通过 Keepalived 的 VRRP 协议与健康检查机制，可以实现 VIP 的自动漂移和回切。

---

## 二、Keepalived VIP 漂移原理

1. **priority（优先级）**
   - 节点基础优先级，高者优先持有 VIP。
   - 例如：主节点 101，备节点 50。

2. **track_script + weight**
   - 用健康检查脚本动态调整节点优先级。
   - 当主节点服务异常时降低优先级，触发 VIP 漂移。
   - 脚本返回 0 表示健康，返回非 0 则降低权重。

3. **preempt / preempt_delay**
   - 决定主节点恢复后是否立即抢回 VIP。
   - `preempt_delay 0` 可让 VIP 在主节点恢复后立即回切。

4. **检测间隔（interval、rise/fall）**
   - 控制健康检查频率及漂移响应时间。
   - 例如 `interval 2, rise 1, fall 2` 表示每 2 秒检测一次，连续成功 1 次恢复权重，连续失败 2 次降低权重。

---

## 三、Keepalived 配置示例

```bash
global_defs {
    router_id keepalived01
    script_user root
    enable_script_security
}

vrrp_script check_service {
    script "/etc/keepalived/service_check.sh"
    interval 2
    weight -5
    fall 2
    rise 1
}

vrrp_instance vip_instance {
    state MASTER
    interface ens5
    virtual_router_id 51
    priority 101          # 主节点优先级
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.42.7.10/24
    }
    track_script {
        check_service
    }
    preempt_delay 0       # 主节点可立即抢回 VIP
}
```

### 健康检查脚本示例 `/etc/keepalived/service_check.sh`

```bash
#!/bin/bash
# 检查关键服务是否运行
if ! pgrep nginx >/dev/null; then
    exit 1  # 服务异常，降低节点权重
fi
exit 0      # 服务正常
```

给脚本赋予可执行权限：

```bash
chmod +x /etc/keepalived/service_check.sh
```

---

## 四、VIP 漂移测试流程

1. **初始状态**
   - 主节点 VIP 已绑定：
   ```bash
   ip addr show ens5 | grep 10.42.7.10
   ```
   - 备节点未绑定 VIP。

2. **触发漂移**
   - 停止主节点关键服务：
   ```bash
   systemctl stop nginx
   ```
   - 检查备节点 VIP 是否接管：
   ```bash
   ip addr show ens5 | grep 10.42.7.10
   ```
   - 外部 ping 测试：
   ```bash
   ping -c 4 10.42.7.10
   ```

3. **主节点恢复**
   - 启动主节点服务：
   ```bash
   systemctl start nginx
   ```
   - VIP 自动回切到主节点（确保 `preempt_delay=0` 且健康检查脚本返回 0）。

---

## 五、注意事项

- **priority 高低与 weight 调整**
  - 主节点 priority 必须高于备节点
  - weight 不要过大，避免恢复后实际优先级低于备节点，导致 VIP 不回切

- **preempt_delay 设置**
  - 控制 VIP 回切行为，生产环境可根据实际需求调整

- **检测脚本可靠性**
  - 确保脚本返回值正确，避免 VIP 漂移误触发

- **日志与监控**
  - 使用 `journalctl -u keepalived -f` 观察 VRRP 状态切换
  - 定期检查 VIP 状态，确保高可用机制稳定

---

## 六、总结

利用 Keepalived 配合健康检查脚本，可以实现关键服务的 VIP 漂移与主备自动切换，保证客户端始终连接到健康的主机。通过合理设置 `priority`、`track_script weight`、`preempt_delay` 与检测间隔，可以实现快速、可靠的高可用服务架构.