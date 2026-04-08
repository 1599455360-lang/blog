---
title: Nginx基础配置详解
categories:
  - 技术教程
tags:
  - Nginx
  - 后端技术
abbrlink: 31f4
date: 2026-04-08 18:45:00
---

## 一、Nginx简介

Nginx是一款轻量级的Web服务器/反向代理服务器及电子邮件(IMAP/POP3)代理服务器,在BSD-like协议下发行。其特点是占有内存少,并发能力强。

## 二、Nginx核心配置文件

### 2.1 全局配置

```nginx
# 全局配置
worker_processes  1;  # 工作进程数,通常设置为CPU核心数

events {
    worker_connections  1024;  # 每个工作进程的最大连接数
}
```

### 2.2 HTTP服务器配置

```nginx
http {
    include       mime.types;  # 文件扩展名与文件类型映射表
    default_type  application/octet-stream;  # 默认文件类型

    sendfile        on;  # 开启高效文件传输模式
    keepalive_timeout  65;  # 连接超时时间

    server {
        listen       80;  # 监听端口
        server_name  localhost;  # 服务器域名

        location / {
            root   html;  # 网站根目录
            index  index.html index.htm;  # 默认首页文件
        }

        error_page   500 502 503 504  /50x.html;  # 错误页面
        location = /50x.html {
            root   html;
        }
    }
}
```

## 三、反向代理配置

### 3.1 简单的反向代理

```nginx
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:8080;  # 代理到本地8080端口
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 3.2 负载均衡配置

```nginx
upstream backend {
    server backend1.example.com weight=5;
    server backend2.example.com:8080;
    server backup.example.com:8080 backup;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

## 四、常用配置技巧

### 4.1 静态文件缓存

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;  # 缓存30天
    add_header Cache-Control "public, no-transform";
}
```

### 4.2 Gzip压缩

```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
```

### 4.3 防盗链

```nginx
location ~* \.(gif|jpg|png|swf|flv)$ {
    valid_referers none blocked www.example.com example.com;
    if ($invalid_referer) {
        return 403;
    }
}
```

## 五、性能优化建议

1. **调整worker_processes**: 设置为CPU核心数
2. **开启epoll**: Linux系统下使用epoll事件模型
3. **优化连接数**: 根据服务器配置调整worker_connections
4. **开启文件缓存**: 减少磁盘IO
5. **使用keepalive**: 减少TCP连接建立开销

## 六、常见问题排查

### 6.1 查看Nginx状态

```bash
# 测试配置文件
nginx -t

# 查看Nginx进程
ps aux | grep nginx

# 查看端口占用
netstat -tlnp | grep nginx
```

### 6.2 日志分析

```bash
# 访问日志位置
/var/log/nginx/access.log

# 错误日志位置
/var/log/nginx/error.log
```

## 七、总结

Nginx作为高性能的Web服务器和反向代理服务器,在互联网架构中扮演着重要角色。掌握其配置方法对于后端开发人员来说是必备技能。通过合理配置Nginx,可以显著提升网站的访问速度和并发处理能力。