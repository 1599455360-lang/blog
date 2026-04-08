---
title: Redis持久化机制详解
categories:
  - 技术教程
tags:
  - Redis
  - 后端技术
abbrlink: b597
date: 2026-04-03 18:45:00
---

## 一、Redis持久化概述

Redis是一个内存数据库,数据存储在内存中。为了防止数据丢失,Redis提供了两种持久化机制:RDB和AOF。

## 二、RDB持久化

### 2.1 RDB简介

RDB(Redis Database)是将某个时间点的数据状态保存到磁盘的快照文件,默认文件名为dump.rdb。

### 2.2 触发RDB快照

#### 自动触发

在redis.conf中配置:

```conf
# 900秒内至少有1个key被改变
save 900 1

# 300秒内至少有10个key被改变
save 300 10

# 60秒内至少有10000个key被改变
save 60 10000
```

#### 手动触发

```bash
# 同步保存,会阻塞Redis
SAVE

# 异步保存,在后台执行
BGSAVE
```

### 2.3 RDB文件配置

```conf
# RDB文件名
dbfilename dump.rdb

# RDB文件存储路径
dir ./

# 压缩RDB文件
rdbcompression yes

# 校验RDB文件
rdbchecksum yes
```

### 2.4 RDB优缺点

**优点:**
- 适合大规模数据恢复
- 对性能影响小(异步保存)
- 文件紧凑,适合备份和传输

**缺点:**
- 可能丢失最后一次快照后的数据
- 数据量大时,保存时间长
- fork子进程时会阻塞父进程

## 三、AOF持久化

### 3.1 AOF简介

AOF(Append Only File)是将所有写命令追加到文件中,通过重新执行命令来恢复数据。

### 3.2 启用AOF

```conf
# 开启AOF
appendonly yes

# AOF文件名
appendfilename "appendonly.aof"

# AOF文件路径
dir ./
```

### 3.3 AOF同步策略

```conf
# always: 每个写命令都同步,最安全但最慢
appendfsync always

# everysec: 每秒同步一次(推荐)
appendfsync everysec

# no: 由操作系统决定,最快但最不安全
appendfsync no
```

### 3.4 AOF重写

随着写操作增多,AOF文件会越来越大。Redis提供了AOF重写功能,合并重复和冗余的命令。

#### 自动重写

```conf
# AOF文件大小是上次重写后大小的100%时触发
auto-aof-rewrite-percentage 100

# AOF文件至少达到64MB时才触发重写
auto-aof-rewrite-min-size 64mb
```

#### 手动重写

```bash
# 触发AOF重写
BGREWRITEAOF
```

### 3.5 AOF重写原理

1. Redis fork一个子进程
2. 子进程根据当前内存数据生成新的AOF文件
3. 父进程继续处理命令,同时将新命令写入AOF重写缓冲区
4. 子进程完成重写后,父进程将重写缓冲区的命令追加到新AOF文件
5. 用新AOF文件替换旧AOF文件

### 3.6 AOF优缺点

**优点:**
- 数据安全性高,最多丢失1秒数据
- AOF文件可读,易于分析和修复
- 支持重写机制,压缩文件大小

**缺点:**
- AOF文件通常比RDB文件大
- 恢复速度比RDB慢
- 对性能有一定影响

## 四、RDB与AOF对比

| 特性 | RDB | AOF |
|------|-----|-----|
| 文件大小 | 小(压缩二进制) | 大(文本命令) |
| 恢复速度 | 快 | 慢 |
| 数据安全性 | 低(可能丢失数据) | 高(最多丢失1秒) |
| 系统资源消耗 | 低(快照时高) | 持续消耗 |
| 适用场景 | 备份、主从复制 | 高可用、数据安全 |

## 五、混合持久化

Redis 4.0之后支持混合持久化,结合了RDB和AOF的优点。

### 5.1 开启混合持久化

```conf
# 开启AOF
appendonly yes

# 开启混合持久化
aof-use-rdb-preamble yes
```

### 5.2 混合持久化原理

- AOF重写时,先写入RDB格式的快照数据
- 然后追加AOF格式的增量命令
- 恢复时,先加载RDB部分,再执行AOF部分

### 5.3 优势

- 结合了RDB的快速恢复和AOF的数据安全
- 文件大小适中
- 恢复速度快

## 六、数据恢复

### 6.1 RDB恢复

1. 停止Redis服务
2. 将dump.rdb文件复制到Redis数据目录
3. 启动Redis服务

### 6.2 AOF恢复

1. 停止Redis服务
2. 将appendonly.aof文件复制到Redis数据目录
3. 如果AOF文件损坏,使用`redis-check-aof --fix`修复
4. 启动Redis服务

### 6.3 修复AOF文件

```bash
# 检查AOF文件
redis-check-aof appendonly.aof

# 修复AOF文件
redis-check-aof --fix appendonly.aof
```

## 七、持久化策略选择

### 7.1 只用RDB

**适用场景:**
- 允许分钟级数据丢失
- 对性能要求高
- 数据量较大

### 7.2 只用AOF

**适用场景:**
- 数据安全性要求高
- 不能接受数据丢失
- 数据量相对较小

### 7.3 RDB + AOF

**适用场景:**
- 数据安全性要求高
- 需要快速恢复
- 推荐使用混合持久化

## 八、生产环境配置建议

### 8.1 配置示例

```conf
# RDB配置
save 900 1
save 300 10
save 60 10000
dbfilename dump.rdb
dir /data/redis
rdbcompression yes
rdbchecksum yes

# AOF配置
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-use-rdb-preamble yes
```

### 8.2 监控指标

```bash
# 查看RDB信息
INFO persistence

# 查看最后一次RDB保存时间
LASTSAVE

# 查看AOF文件大小
INFO stats | grep aof
```

## 九、常见问题

### 9.1 RDB文件过大

**原因**: 数据量增加,fork子进程慢

**解决方案**:
- 使用更快的磁盘
- 调整save策略,减少快照频率
- 使用AOF替代

### 9.2 AOF文件增长过快

**原因**: 写操作频繁

**解决方案**:
- 调整auto-aof-rewrite参数
- 定期手动触发BGREWRITEAOF
- 检查是否有不必要的写操作

### 9.3 数据恢复失败

**解决方案**:
- 检查文件权限
- 验证文件完整性
- 使用redis-check-aof或redis-check-rdb修复

## 十、总结

Redis持久化是保证数据安全的重要机制。在实际应用中:
1. 根据业务需求选择合适的持久化策略
2. 推荐使用RDB + AOF混合持久化
3. 定期备份持久化文件
4. 监控持久化性能指标
5. 做好数据恢复预案