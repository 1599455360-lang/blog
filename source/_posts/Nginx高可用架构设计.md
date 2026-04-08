---
title: Nginx高可用架构设计
categories:
  - 技术教程
tags:
  - Nginx
  - 高可用
  - 后端技术
abbrlink: ef00
date: 2026-03-30 18:45:00
---

## 一、高可用架构概述

高可用(High Availability)是指系统无中断地执行其功能的能力,通常用"几个9"来衡量,例如99.99%的可用性表示一年停机时间不超过52.6分钟。

## 二、Keepalived + Nginx

### 2.1 架构设计

```
                  VIP(虚拟IP)
                      |
        +-------------+-------------+
        |                           |
    Master Nginx              Backup Nginx
    (192.168.1.10)           (192.168.1.11)
        |                           |
    Keepalived                 Keepalived
```

### 2.2 安装Keepalived

```bash
# CentOS/RHEL
yum install -y keepalived

# Ubuntu/Debian
apt-get install -y keepalived
```

### 2.3 Keepalived配置

#### Master节点配置

```conf
# /etc/keepalived/keepalived.conf

global_defs {
    router_id NGINX_MASTER
}

vrrp_script check_nginx {
    script "/etc/keepalived/check_nginx.sh"
    interval 2
    weight -20
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        192.168.1.100
    }

    track_script {
        check_nginx
    }
}
```

#### Backup节点配置

```conf
# /etc/keepalived/keepalived.conf

global_defs {
    router_id NGINX_BACKUP
}

vrrp_script check_nginx {
    script "/etc/keepalived/check_nginx.sh"
    interval 2
    weight -20
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 90
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        192.168.1.100
    }

    track_script {
        check_nginx
    }
}
```

### 2.4 Nginx健康检查脚本

```bash
#!/bin/bash
# /etc/keepalived/check_nginx.sh

A=$(ps -C nginx --no-header | wc -l)
if [ $A -eq 0 ]; then
    systemctl start nginx
    sleep 2
    if [ $(ps -C nginx --no-header | wc -l) -eq 0 ]; then
        systemctl stop keepalived
    fi
fi
```

```bash
chmod +x /etc/keepalived/check_nginx.sh
```

### 2.5 启动服务

```bash
systemctl start keepalived
systemctl enable keepalived
```

## 三、负载均衡高可用

### 3.1 双Nginx负载均衡

```
                    DNS轮询
                       |
        +--------------+--------------+
        |                             |
    Nginx LB 1                   Nginx LB 2
    (Keepalived VIP1)            (Keepalived VIP2)
        |                             |
        +--------------+--------------+
                       |
            +----------+----------+
            |          |          |
        Server1    Server2    Server3
```

### 3.2 Nginx负载均衡配置

```nginx
upstream backend {
    server 192.168.1.20:8080;
    server 192.168.1.21:8080;
    server 192.168.1.22:8080;

    keepalive 32;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # 健康检查
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_connect_timeout 2s;
    }

    # 健康检查接口
    location /health {
        access_log off;
        return 200 "OK\n";
    }
}
```

## 四、应用层高可用

### 4.1 多机房部署

```
                    DNS解析
                       |
        +--------------+--------------+
        |                             |
     机房A                          机房B
   (北京/上海)                    (深圳/广州)
        |                             |
   +----+----+                   +----+----+
   |         |                   |         |
 Nginx    Nginx               Nginx    Nginx
   |         |                   |         |
App集群   App集群             App集群   App集群
   |         |                   |         |
 DB主从   DB主从             DB主从   DB主从
```

### 4.2 跨机房配置

```nginx
# 机房A的Nginx配置
upstream backend_local {
    server 192.168.1.20:8080;
    server 192.168.1.21:8080;
}

upstream backend_remote {
    server 10.0.1.20:8080 backup;
    server 10.0.1.21:8080 backup;
}

server {
    listen 80;

    location / {
        # 优先使用本地机房
        proxy_pass http://backend_local;

        # 本地故障时切换到远程机房
        proxy_next_upstream error timeout http_502 http_503 http_504;
        proxy_connect_timeout 2s;
    }
}
```

## 五、数据库高可用

### 5.1 MySQL主从复制

```
      写请求                读请求
        |                     |
    Master Nginx         Slave Nginx
        |                     |
    MySQL Master -------- MySQL Slave
   (192.168.1.30)        (192.168.1.31)
        |
    MySQL Slave
   (192.168.1.32)
```

### 5.2 读写分离配置

```nginx
# 写请求转发到主库
upstream mysql_master {
    server 192.168.1.30:3306;
}

# 读请求转发到从库
upstream mysql_slave {
    server 192.168.1.31:3306;
    server 192.168.1.32:3306;
}

server {
    listen 3306;

    # 写请求
    location /write {
        proxy_pass http://mysql_master;
    }

    # 读请求
    location /read {
        proxy_pass http://mysql_slave;
    }
}
```

## 六、缓存高可用

### 6.1 Redis Sentinel架构

```
      应用服务
          |
    Redis Sentinel
          |
    +-----+-----+
    |           |
Master Redis  Slave Redis
```

### 6.2 Nginx配置Redis负载均衡

```nginx
upstream redis_backend {
    server 192.168.1.40:6379;
    server 192.168.1.41:6379 backup;
    server 192.168.1.42:6379 backup;
}

server {
    listen 6379;

    location / {
        proxy_pass http://redis_backend;
        proxy_connect_timeout 1s;
    }
}
```

## 七、监控告警

### 7.1 Prometheus监控

#### Prometheus配置

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['192.168.1.10:9113', '192.168.1.11:9113']

  - job_name: 'keepalived'
    static_configs:
      - targets: ['192.168.1.10:9165', '192.168.1.11:9165']
```

#### Nginx VTS模块配置

```nginx
server {
    listen 9113;

    location /metrics {
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
    }
}
```

### 7.2 告警规则

```yaml
# alert_rules.yml
groups:
  - name: nginx_alerts
    rules:
      - alert: NginxDown
        expr: nginx_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Nginx服务宕机"
          description: "Nginx实例 {{ $labels.instance }} 已宕机超过1分钟"

      - alert: KeepalivedDown
        expr: keepalived_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Keepalived服务宕机"
          description: "Keepalived实例 {{ $labels.instance }} 已宕机超过1分钟"
```

## 八、故障演练

### 8.1 模拟Nginx宕机

```bash
# 在Master节点停止Nginx
systemctl stop nginx

# 观察VIP是否漂移
ip addr show eth0

# 查看Keepalived日志
tail -f /var/log/messages
```

### 8.2 模拟服务器宕机

```bash
# 关闭Master服务器
shutdown -h now

# 在Backup节点检查VIP
ip addr show eth0
```

### 8.3 恢复测试

```bash
# 启动Master服务器和Nginx
systemctl start nginx
systemctl start keepalived

# 检查VIP是否抢占
# 注意: 需要配置nopreempt来避免VIP抢占
```

## 九、高可用最佳实践

### 9.1 配置优化

#### Nginx配置

```nginx
# 增加超时时间
proxy_connect_timeout 10s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;

# 增加重试次数
proxy_next_upstream_tries 3;
proxy_next_upstream_timeout 30s;

# 长连接
proxy_http_version 1.1;
proxy_set_header Connection "";
keepalive_timeout 65;
```

#### Keepalived配置

```conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    nopreempt  # 不抢占VIP

    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        192.168.1.100
    }
}
```

### 9.2 自动化运维

#### 自动化部署脚本

```bash
#!/bin/bash
# deploy_nginx_ha.sh

# 安装依赖
yum install -y nginx keepalived

# 配置Nginx
cat > /etc/nginx/nginx.conf <<EOF
# Nginx配置内容
EOF

# 配置Keepalived
cat > /etc/keepalived/keepalived.conf <<EOF
# Keepalived配置内容
EOF

# 创建健康检查脚本
cat > /etc/keepalived/check_nginx.sh <<'EOF'
#!/bin/bash
A=\$(ps -C nginx --no-header | wc -l)
if [ \$A -eq 0 ]; then
    systemctl start nginx
    sleep 2
    if [ \$(ps -C nginx --no-header | wc -l) -eq 0 ]; then
        systemctl stop keepalived
    fi
fi
EOF

chmod +x /etc/keepalived/check_nginx.sh

# 启动服务
systemctl start nginx
systemctl start keepalived
systemctl enable nginx
systemctl enable keepalived
```

### 9.3 定期演练

建议定期进行故障演练:
- 每月进行一次计划性故障切换演练
- 每季度进行一次全链路高可用测试
- 每年进行一次灾备切换演练

## 十、总结

构建Nginx高可用架构需要从多个层面考虑:
1. **负载均衡层**: Keepalived实现VIP漂移
2. **应用层**: 多实例部署,健康检查
3. **数据库层**: 主从复制,读写分离
4. **缓存层**: Redis Sentinel或Cluster
5. **监控层**: Prometheus + Grafana监控告警

高可用架构的目标是保证系统在单点故障时仍能正常提供服务。通过合理的架构设计和完善的监控告警机制,可以将系统停机时间降到最低。同时要定期进行故障演练,确保高可用机制真正有效。