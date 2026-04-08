---
title: Nginx负载均衡配置实践
categories:
  - 技术教程
tags:
  - Nginx
  - 后端技术
abbrlink: '2886'
date: 2026-04-05 18:45:00
---

## 一、负载均衡概述

负载均衡(Load Balance)是将工作负载分布到多个服务器上,以提高网站、应用、数据库或其他服务的性能和可靠性。

## 二、Nginx负载均衡策略

### 2.1 轮询(Round Robin)

默认策略,按时间顺序逐一分配到不同的后端服务器:

```nginx
upstream backend {
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    server 192.168.1.103:8080;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2.2 权重(Weight)

指定轮询几率,weight和访问比率成正比:

```nginx
upstream backend {
    server 192.168.1.101:8080 weight=5;
    server 192.168.1.102:8080 weight=3;
    server 192.168.1.103:8080 weight=2;
}
```

### 2.3 IP哈希(IP Hash)

每个请求按访问IP的hash结果分配,这样每个访客固定访问一个后端服务器:

```nginx
upstream backend {
    ip_hash;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    server 192.168.1.103:8080;
}
```

### 2.4 最少连接(Least Connections)

将请求分配到连接数最少的服务器:

```nginx
upstream backend {
    least_conn;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    server 192.168.1.103:8080;
}
```

### 2.5 URL哈希(URL Hash)

按访问URL的hash结果分配请求:

```nginx
upstream backend {
    hash $request_uri;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    server 192.168.1.103:8080;
}
```

## 三、健康检查

### 3.1 被动健康检查

```nginx
upstream backend {
    server 192.168.1.101:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.102:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.103:8080 backup;  # 备用服务器
}
```

参数说明:
- `max_fails`: 允许请求失败的次数,默认为1
- `fail_timeout`: 在经历max_fails次失败后,暂停服务的时间
- `backup`: 备用服务器,当其他服务器都不可用时启用

### 3.2 主动健康检查(需要nginx_plus或第三方模块)

```nginx
upstream backend {
    zone backend 64k;

    server 192.168.1.101:8080;
    server 192.168.1.102:8080;

    health_check interval=5s fails=3 passes=2;
}
```

## 四、完整配置示例

### 4.1 基础配置

```nginx
upstream backend {
    # 负载均衡策略
    least_conn;

    # 服务器列表
    server 192.168.1.101:8080 weight=5 max_fails=3 fail_timeout=30s;
    server 192.168.1.102:8080 weight=3 max_fails=3 fail_timeout=30s;
    server 192.168.1.103:8080 backup;

    # 长连接缓存
    keepalive 32;
}

server {
    listen 80;
    server_name example.com;

    # 访问日志
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    location / {
        proxy_pass http://backend;

        # 请求头设置
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # 长连接
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    # 健康检查接口
    location /health {
        access_log off;
        return 200 "OK\n";
    }
}
```

### 4.2 多应用配置

```nginx
# API服务
upstream api_backend {
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}

# Web服务
upstream web_backend {
    server 192.168.1.103:8080;
    server 192.168.1.104:8080;
}

server {
    listen 80;
    server_name example.com;

    # API转发
    location /api/ {
        proxy_pass http://api_backend/;
        proxy_set_header Host $host;
    }

    # Web转发
    location / {
        proxy_pass http://web_backend;
        proxy_set_header Host $host;
    }
}
```

## 五、负载均衡优化

### 5.1 开启长连接

```nginx
upstream backend {
    server 192.168.1.101:8080;
    keepalive 32;  # 保持32个长连接
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;  # 使用HTTP 1.1
        proxy_set_header Connection "";  # 清除Connection头
    }
}
```

### 5.2 缓冲区优化

```nginx
location / {
    proxy_pass http://backend;

    # 响应缓冲区
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;

    # 临时文件写入大小
    proxy_temp_file_write_size 64k;
}
```

### 5.3 会话保持

#### 方式一: IP Hash

```nginx
upstream backend {
    ip_hash;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}
```

#### 方式二: 使用Cookie

```nginx
upstream backend {
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}

server {
    location / {
        proxy_pass http://backend;

        # 设置会话保持Cookie
        add_header Set-Cookie "serverid=$upstream_addr; path=/";
    }
}
```

## 六、监控与日志

### 6.1 状态监控

```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
}
```

访问`http://example.com/nginx_status`可以看到:
```
Active connections: 5
server accepts handled requests
 10 10 20
Reading: 0 Writing: 1 Waiting: 4
```

### 6.2 日志格式

```nginx
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for" '
                '$upstream_addr $upstream_response_time $request_time';
```

## 七、故障排查

### 7.1 常见问题

**问题1: 502 Bad Gateway**
- 原因: 后端服务未启动或端口错误
- 解决: 检查后端服务状态和端口配置

**问题2: 504 Gateway Timeout**
- 原因: 后端服务响应超时
- 解决: 增加proxy_read_timeout时间

**问题3: 负载不均衡**
- 原因: 使用了ip_hash或会话保持
- 解决: 根据需求调整负载策略

### 7.2 调试命令

```bash
# 测试配置文件
nginx -t

# 查看连接状态
netstat -anp | grep :80

# 实时查看日志
tail -f /var/log/nginx/access.log

# 查看上游服务器状态
curl http://localhost/nginx_status
```

## 八、总结

Nginx作为高性能的反向代理服务器,提供了多种负载均衡策略和丰富的配置选项。通过合理配置负载均衡,可以有效提升系统的并发处理能力和可用性。在实际应用中,需要根据业务特点选择合适的负载策略,并做好健康检查和监控工作。