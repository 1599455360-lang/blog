---
title: Nginx性能优化指南
categories:
  - 技术教程
tags:
  - Nginx
  - 后端技术
abbrlink: 91c4
date: 2026-04-02 18:45:00
---

## 一、Nginx性能优化概述

Nginx作为高性能的Web服务器和反向代理,在默认配置下已经表现出色。但通过针对性优化,可以进一步提升性能。

## 二、系统层面优化

### 2.1 内核参数调优

编辑`/etc/sysctl.conf`文件:

```conf
# 最大文件描述符
fs.file-max = 65535

# 允许系统打开的最大端口范围
net.ipv4.ip_local_port_range = 1024 65535

# TCP连接重用
net.ipv4.tcp_tw_reuse = 1

# TCP快速回收
net.ipv4.tcp_tw_recycle = 1

# TCP FIN超时时间
net.ipv4.tcp_fin_timeout = 30

# TCP最大孤儿连接数
net.ipv4.tcp_max_orphans = 262144

# TCP最大TIME_WAIT连接数
net.ipv4.tcp_max_tw_buckets = 5000

# TCP keepalive时间
net.ipv4.tcp_keepalive_time = 120
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3

# TCP接收和发送缓冲区
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# 网络设备积压队列
net.core.netdev_max_backlog = 262144

# TCP监听队列
net.core.somaxconn = 262144
net.ipv4.tcp_max_syn_backlog = 262144

# 开启SYN Cookies
net.ipv4.tcp_syncookies = 1

# TCP内存自动调整
net.ipv4.tcp_mem = 94500000 915000000 927000000
```

应用配置:

```bash
sysctl -p
```

### 2.2 文件描述符限制

编辑`/etc/security/limits.conf`:

```conf
* soft nofile 65535
* hard nofile 65535
```

## 三、Nginx配置优化

### 3.1 worker进程优化

```nginx
# worker进程数,建议设置为CPU核心数或auto
worker_processes auto;

# 绑定worker进程到CPU核心
worker_cpu_affinity auto;

# worker进程最大打开文件数
worker_rlimit_nofile 65535;

events {
    # 使用epoll事件模型(Linux)
    use epoll;

    # 每个worker进程的最大连接数
    worker_connections 65535;

    # 允许一个进程同时接受多个连接
    multi_accept on;
}
```

### 3.2 HTTP连接优化

```nginx
http {
    # 开启高效文件传输模式
    sendfile on;

    # 减少网络报文段数量
    tcp_nopush on;
    tcp_nodelay on;

    # 连接超时时间
    keepalive_timeout 65;
    keepalive_requests 100;

    # 客户端请求体缓冲区大小
    client_body_buffer_size 16k;
    client_max_body_size 10m;

    # 客户端请求头缓冲区大小
    client_header_buffer_size 1k;
    large_client_header_buffers 4 16k;

    # 输出缓冲区大小
    output_buffers 1 32k;
    postpone_output 1460;
}
```

### 3.3 Gzip压缩优化

```nginx
http {
    # 开启Gzip
    gzip on;

    # 最小压缩大小
    gzip_min_length 1k;

    # 压缩缓冲区
    gzip_buffers 4 16k;

    # 压缩级别(1-9,数字越大压缩率越高,但消耗CPU越多)
    gzip_comp_level 6;

    # 压缩类型
    gzip_types text/plain text/css text/javascript application/json application/javascript application/x-javascript application/xml;

    # 在响应头添加Vary: Accept-Encoding
    gzip_vary on;

    # 对代理服务器启用压缩
    gzip_proxied any;

    # IE6及以下不启用压缩
    gzip_disable "MSIE [1-6]\.";
}
```

### 3.4 静态文件缓存

```nginx
server {
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
        expires 30d;  # 缓存30天
        add_header Cache-Control "public, immutable";
        access_log off;  # 不记录访问日志
    }

    # HTML文件不缓存
    location ~* \.html$ {
        expires -1;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
```

### 3.5 FastCGI优化

```nginx
location ~ \.php$ {
    fastcgi_pass 127.0.0.1:9000;

    # FastCGI缓冲区
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;

    # FastCGI临时文件
    fastcgi_temp_file_write_size 128k;

    # FastCGI超时
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;

    # 保持连接
    fastcgi_keep_conn on;
}
```

### 3.6 代理缓冲优化

```nginx
location / {
    proxy_pass http://backend;

    # 代理缓冲区
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;

    # 临时文件
    proxy_temp_file_write_size 64k;

    # 超时设置
    proxy_connect_timeout 90;
    proxy_send_timeout 90;
    proxy_read_timeout 90;
}
```

### 3.7 连接池优化

```nginx
upstream backend {
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;

    # 保持长连接缓存池
    keepalive 32;  # 每个worker进程保持32个长连接
    keepalive_timeout 60s;  # 长连接超时时间
    keepalive_requests 1000;  # 每个长连接最多处理1000个请求
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;  # 使用HTTP 1.1
        proxy_set_header Connection "";  # 清除Connection头
    }
}
```

## 四、缓存优化

### 4.1 开启代理缓存

```nginx
http {
    # 缓存路径配置
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:100m
                     max_size=10g inactive=60m use_temp_path=off;

    server {
        location / {
            proxy_pass http://backend;

            # 使用缓存
            proxy_cache my_cache;

            # 缓存key
            proxy_cache_key $scheme$request_method$host$request_uri;

            # 缓存有效期
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;

            # 缓存条件
            proxy_cache_min_uses 1;

            # 缓存锁
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;

            # 添加缓存状态头
            add_header X-Cache-Status $upstream_cache_status;
        }
    }
}
```

### 4.2 清除缓存

```nginx
location ~ /purge(/.*) {
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    proxy_cache_purge my_cache $scheme$request_method$host$1;
}
```

## 五、SSL/TLS优化

```nginx
server {
    listen 443 ssl http2;

    # SSL证书
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # SSL协议
    ssl_protocols TLSv1.2 TLSv1.3;

    # 加密套件
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;

    # SSL会话缓存
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # SSL会话票据
    ssl_session_tickets on;

    # OCSP装订
    ssl_stapling on;
    ssl_stapling_verify on;

    # DH参数
    ssl_dhparam /path/to/dhparam.pem;
}
```

## 六、日志优化

### 6.1 日志缓冲

```nginx
http {
    # 访问日志缓冲
    access_log /var/log/nginx/access.log main buffer=32k flush=5s;

    # 错误日志级别
    error_log /var/log/nginx/error.log warn;
}
```

### 6.2 条件日志

```nginx
server {
    location / {
        # 不记录静态文件日志
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            access_log off;
        }

        # 只记录错误状态码
        location /api/ {
            access_log /var/log/nginx/api.log if=$loggable;
        }
    }
}

# 定义变量
map $status $loggable {
    ~^[23] 0;
    default 1;
}
```

## 七、监控与调优

### 7.1 状态监控

```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

### 7.2 性能测试

使用ab(Apache Benchmark)测试:

```bash
# 并发100个请求,总共10000个请求
ab -n 10000 -c 100 http://localhost/

# 使用keepalive
ab -n 10000 -c 100 -k http://localhost/
```

### 7.3 监控指标

- **Active connections**: 活跃连接数
- **Server accepts handled requests**: 接受、处理、请求总数
- **Reading**: 读取客户端请求的连接数
- **Writing**: 写入响应到客户端的连接数
- **Waiting**: 等待下一个请求的空闲连接数

## 八、常见性能问题

### 8.1 CPU占用过高

**原因**: Gzip压缩级别过高、正则表达式复杂

**解决方案**:
- 降低gzip_comp_level到4-6
- 优化正则表达式
- 使用更简单的location匹配

### 8.2 内存占用过高

**原因**: 缓冲区设置过大、连接数过多

**解决方案**:
- 调整buffer大小
- 限制worker_connections
- 开启proxy_buffering

### 8.3 响应速度慢

**原因**: 磁盘IO慢、后端服务慢、网络延迟

**解决方案**:
- 使用SSD硬盘
- 开启sendfile和tcp_nopush
- 优化后端服务
- 开启缓存

## 九、完整优化配置示例

```nginx
user nginx;
worker_processes auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    use epoll;
    worker_connections 65535;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    keepalive_timeout 65;
    keepalive_requests 100;

    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/javascript application/json application/javascript;
    gzip_vary on;

    access_log /var/log/nginx/access.log main buffer=32k flush=5s;

    upstream backend {
        server 192.168.1.101:8080;
        server 192.168.1.102:8080;
        keepalive 32;
    }

    server {
        listen 80;
        server_name example.com;

        location / {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }

        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 30d;
            access_log off;
        }

        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}
```

## 十、总结

Nginx性能优化需要从系统层面和Nginx配置层面综合考虑。主要优化方向包括:
1. 合理设置worker进程数和连接数
2. 开启sendfile、tcp_nopush等高效传输选项
3. 使用Gzip压缩减少传输数据量
4. 配置合理的缓存策略
5. 优化SSL/TLS性能
6. 做好监控和日志管理

通过以上优化,可以显著提升Nginx的性能和并发处理能力。