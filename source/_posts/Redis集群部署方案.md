---
title: Redis集群部署方案
categories:
  - 技术教程
tags:
  - Redis
  - 集群
  - 后端技术
abbrlink: '3695'
date: 2026-03-31 18:45:00
---

## 一、Redis集群概述

Redis集群是Redis提供的分布式数据库方案,通过分片(Sharding)实现数据共享,并提供复制和故障转移功能。

## 二、主从复制

### 2.1 主从架构

一主多从架构,主节点负责写操作,从节点负责读操作。

#### 配置主节点

```conf
# redis.conf
port 6379
bind 0.0.0.0
daemonize yes
pidfile /var/run/redis.pid
logfile /var/log/redis.log
dir /data/redis
```

#### 配置从节点

```conf
# redis.conf
port 6380
bind 0.0.0.0
daemonize yes
pidfile /var/run/redis-slave.pid
logfile /var/log/redis-slave.log
dir /data/redis-slave

# 指定主节点
replicaof 192.168.1.100 6379

# 只读模式
replica-read-only yes
```

### 2.2 验证主从复制

```bash
# 连接主节点
redis-cli -p 6379

# 查看主从信息
INFO replication

# 输出示例
# Replication
role:master
connected_slaves:1
slave0:ip=192.168.1.101,port=6380,state=online,offset=42,lag=0
```

### 2.3 主从复制原理

1. 从节点连接主节点,发送SYNC命令
2. 主节点执行BGSAVE生成RDB快照
3. 主节点将RDB发送给从节点
4. 从节点加载RDB文件
5. 主节点将缓存的写命令发送给从节点

## 三、哨兵模式

### 3.1 哨兵架构

哨兵(Sentinel)用于监控主从节点,实现自动故障转移。

#### 配置哨兵

```conf
# sentinel.conf
port 26379
sentinel monitor mymaster 192.168.1.100 6379 2
sentinel down-after-milliseconds mymaster 30000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 180000
```

参数说明:
- `monitor`: 监控名为mymaster的主节点,2表示需要2个哨兵同意才能进行故障转移
- `down-after-milliseconds`: 主节点下线判定时间
- `parallel-syncs`: 故障转移后同时向新主节点发起复制的从节点数
- `failover-timeout`: 故障转移超时时间

### 3.2 启动哨兵

```bash
redis-sentinel /path/to/sentinel.conf
```

### 3.3 哨兵工作原理

1. **监控**: 哨兵定期向主从节点发送PING命令
2. **提醒**: 当监控的节点异常时,通知其他哨兵
3. **自动故障转移**:
   - 选择新的主节点
   - 将其他从节点指向新主节点
   - 通知客户端新主节点地址

### 3.4 Spring Boot集成哨兵

```yaml
spring:
  redis:
    sentinel:
      master: mymaster
      nodes:
        - 192.168.1.100:26379
        - 192.168.1.101:26379
        - 192.168.1.102:26379
    password: yourpassword
```

## 四、Redis Cluster

### 4.1 集群架构

Redis Cluster采用无中心节点架构,数据分片存储在多个节点上。

#### 集群规划

最少需要6个节点(3主3从):
- 192.168.1.100:6379 (主)
- 192.168.1.101:6379 (主)
- 192.168.1.102:6379 (主)
- 192.168.1.103:6379 (从)
- 192.168.1.104:6379 (从)
- 192.168.1.105:6379 (从)

#### 节点配置

每个节点的redis.conf:

```conf
port 6379
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
bind 0.0.0.0
protected-mode no
```

#### 创建集群

```bash
# Redis 5.0+
redis-cli --cluster create \
  192.168.1.100:6379 \
  192.168.1.101:6379 \
  192.168.1.102:6379 \
  192.168.1.103:6379 \
  192.168.1.104:6379 \
  192.168.1.105:6379 \
  --cluster-replicas 1
```

### 4.2 集群操作

#### 查看集群信息

```bash
redis-cli -c -h 192.168.1.100 -p 6379

# 查看集群状态
CLUSTER INFO

# 查看节点信息
CLUSTER NODES
```

#### 添加节点

```bash
# 添加主节点
redis-cli --cluster add-node 192.168.1.106:6379 192.168.1.100:6379

# 添加从节点
redis-cli --cluster add-node 192.168.1.107:6379 192.168.1.100:6379 --cluster-slave --cluster-master-id <node-id>
```

#### 删除节点

```bash
redis-cli --cluster del-node 192.168.1.100:6379 <node-id>
```

#### 重新分片

```bash
redis-cli --cluster reshard 192.168.1.100:6379
```

### 4.3 Spring Boot集成Redis Cluster

```java
@Configuration
public class RedisClusterConfig {

    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        RedisClusterConfiguration config = new RedisClusterConfiguration(
            Arrays.asList(
                "192.168.1.100:6379",
                "192.168.1.101:6379",
                "192.168.1.102:6379"
            )
        );
        config.setPassword("yourpassword");

        LettuceConnectionFactory factory = new LettuceConnectionFactory(config);
        return factory;
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate(
            RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        // 序列化配置
        Jackson2JsonRedisSerializer<Object> serializer =
            new Jackson2JsonRedisSerializer<>(Object.class);

        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(serializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);

        return template;
    }
}
```

## 五、集群对比

| 特性 | 主从复制 | 哨兵模式 | Redis Cluster |
|------|---------|---------|---------------|
| 高可用 | 否 | 是 | 是 |
| 数据分片 | 否 | 否 | 是 |
| 故障转移 | 手动 | 自动 | 自动 |
| 部署复杂度 | 低 | 中 | 高 |
| 扩展性 | 低 | 中 | 高 |
| 适用场景 | 读多写少 | 中小规模 | 大规模 |

## 六、生产环境部署建议

### 6.1 硬件配置

- **CPU**: 4核以上
- **内存**: 8GB以上(根据数据量)
- **磁盘**: SSD硬盘,提高IO性能
- **网络**: 千兆网卡,低延迟网络

### 6.2 集群配置优化

```conf
# 最大内存
maxmemory 4gb

# 内存淘汰策略
maxmemory-policy allkeys-lru

# 持久化
appendonly yes
appendfsync everysec

# 慢查询日志
slowlog-log-slower-than 10000
slowlog-max-len 128

# 客户端连接数
maxclients 10000

# 超时设置
timeout 300
```

### 6.3 监控指标

#### 关键指标

- **内存使用率**: used_memory / maxmemory
- **命中率**: hit_rate = hits / (hits + misses)
- **连接数**: connected_clients
- **命令执行次数**: total_commands_processed
- **键空间**: keyspace
- **持久化状态**: rdb_last_bgsave_status, aof_last_rewrite_status

#### 监控工具

```bash
# Redis自带的监控命令
redis-cli --stat
redis-cli --bigkeys
redis-cli --latency

# 查看实时统计
redis-cli INFO stats

# 查看内存使用
redis-cli INFO memory
```

### 6.4 备份策略

#### RDB备份

```bash
# 定时备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
redis-cli BGSAVE
sleep 5
cp /data/redis/dump.rdb /backup/dump_${DATE}.rdb
```

#### AOF备份

```bash
# 定时重写AOF
redis-cli BGREWRITEAOF
```

## 七、故障处理

### 7.1 主从复制延迟

**原因**: 网络延迟、主节点写入量大

**解决方案**:
- 使用更快的网络
- 优化主节点写入
- 使用Redis Cluster分散压力

### 7.2 集群节点宕机

**处理流程**:
1. 哨兵或集群自动检测故障
2. 选举新的主节点
3. 更新配置信息
4. 通知客户端

### 7.3 数据迁移

```bash
# 使用redis-cli进行数据迁移
redis-cli --cluster import 192.168.1.100:6379 --cluster-from 192.168.1.200:6379 --cluster-copy
```

## 八、集群运维工具

### 8.1 Redis_exporter

用于Prometheus监控:

```bash
docker run -d --name redis_exporter \
  -p 9121:9121 \
  oliver006/redis_exporter \
  --redis.addr=redis://192.168.1.100:6379
```

### 8.2 RedisInsight

可视化管理和监控工具:

```bash
docker run -d --name redis-insight \
  -p 8001:8001 \
  redislabs/redisinsight:latest
```

## 九、总结

Redis集群方案的选择需要根据业务需求:
- **主从复制**: 适合读多写少、不需要自动故障转移的场景
- **哨兵模式**: 适合中小规模、需要高可用的场景
- **Redis Cluster**: 适合大规模、需要水平扩展的场景

在生产环境中,需要做好监控、备份、故障预案等工作,确保Redis集群的稳定运行。同时要根据数据量和访问量选择合适的部署方案和配置参数。