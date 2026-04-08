---
title: Redis数据结构与使用场景
categories:
  - 技术教程
tags:
  - Redis
  - 后端技术
abbrlink: 9d17
date: 2026-04-06 18:45:00
---

## 一、Redis简介

Redis(Remote Dictionary Server)是一个开源的、基于内存的高性能键值对数据库,支持多种数据结构,常用于缓存、消息队列、排行榜等场景。

## 二、五种基本数据结构

### 2.1 String(字符串)

#### 基本操作

```bash
# 设置值
SET key value
SET key value EX 10  # 设置10秒过期

# 获取值
GET key

# 自增自减
INCR counter
DECR counter
INCRBY counter 10

# 追加字符串
APPEND key value
```

#### 使用场景
- **缓存**: 缓存JSON数据、HTML页面等
- **计数器**: 文章阅读数、点赞数
- **分布式锁**: SETNX实现分布式锁
- **Session共享**: 集群环境下的Session存储

#### 示例代码

```java
@RestController
public class CacheController {

    @Autowired
    private StringRedisTemplate redisTemplate;

    @GetMapping("/cache/{key}")
    public String getCache(@PathVariable String key) {
        return redisTemplate.opsForValue().get(key);
    }

    @PostMapping("/cache")
    public void setCache(@RequestParam String key, @RequestParam String value) {
        redisTemplate.opsForValue().set(key, value, 10, TimeUnit.MINUTES);
    }
}
```

### 2.2 Hash(哈希)

#### 基本操作

```bash
# 设置字段
HSET user:1 name "张三"
HSET user:1 age 25

# 获取字段
HGET user:1 name
HGETALL user:1

# 删除字段
HDEL user:1 age

# 判断字段是否存在
HEXISTS user:1 name
```

#### 使用场景
- **对象存储**: 存储用户信息、商品信息等
- **购物车**: 用户ID为key,商品ID为field,数量为value
- **计数器**: 存储多个计数项

#### 示例代码

```java
public class UserService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    public void saveUser(User user) {
        String key = "user:" + user.getId();
        Map<String, String> map = new HashMap<>();
        map.put("name", user.getName());
        map.put("age", String.valueOf(user.getAge()));
        redisTemplate.opsForHash().putAll(key, map);
    }

    public User getUser(Long id) {
        String key = "user:" + id;
        Map<Object, Object> map = redisTemplate.opsForHash().entries(key);
        // 转换为User对象
        return convertToUser(map);
    }
}
```

### 2.3 List(列表)

#### 基本操作

```bash
# 左推入
LPUSH list1 a b c

# 右推入
RPUSH list1 d e f

# 左弹出
LPOP list1

# 右弹出
RPOP list1

# 获取列表元素
LRANGE list1 0 -1  # 获取所有元素

# 阻塞弹出
BLPOP list1 10  # 阻塞10秒
```

#### 使用场景
- **消息队列**: LPUSH和RPOP实现队列
- **最新列表**: 最新文章、最新评论
- **关注列表**: 用户关注的人列表

#### 示例代码

```java
public class MessageQueueService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 生产者
    public void sendMessage(String queueName, String message) {
        redisTemplate.opsForList().leftPush(queueName, message);
    }

    // 消费者
    public String receiveMessage(String queueName) {
        return redisTemplate.opsForList().rightPop(queueName, 10, TimeUnit.SECONDS);
    }
}
```

### 2.4 Set(集合)

#### 基本操作

```bash
# 添加元素
SADD set1 a b c

# 获取所有元素
SMEMBERS set1

# 判断元素是否存在
SISMEMBER set1 a

# 删除元素
SREM set1 a

# 集合运算
SINTER set1 set2  # 交集
SUNION set1 set2  # 并集
SDIFF set1 set2   # 差集
```

#### 使用场景
- **标签系统**: 文章标签、用户标签
- **社交功能**: 共同好友、可能认识的人
- **去重**: 存储不重复的数据

#### 示例代码

```java
public class TagService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 添加标签
    public void addTags(String articleId, Set<String> tags) {
        String key = "article:tags:" + articleId;
        redisTemplate.opsForSet().add(key, tags.toArray(new String[0]));
    }

    // 获取标签
    public Set<String> getTags(String articleId) {
        String key = "article:tags:" + articleId;
        return redisTemplate.opsForSet().members(key);
    }

    // 共同标签
    public Set<String> getCommonTags(String articleId1, String articleId2) {
        String key1 = "article:tags:" + articleId1;
        String key2 = "article:tags:" + articleId2;
        return redisTemplate.opsForSet().intersect(key1, key2);
    }
}
```

### 2.5 ZSet(有序集合)

#### 基本操作

```bash
# 添加元素
ZADD rank1 100 user1
ZADD rank1 90 user2
ZADD rank1 95 user3

# 获取排名(升序)
ZRANGE rank1 0 -1 WITHSCORES

# 获取排名(降序)
ZREVRANGE rank1 0 -1 WITHSCORES

# 获取分数范围
ZRANGEBYSCORE rank1 90 100

# 增加分数
ZINCRBY rank1 5 user2
```

#### 使用场景
- **排行榜**: 游戏积分榜、销量榜
- **延时队列**: 带权重的队列
- **热搜榜**: 按热度排序的话题

#### 示例代码

```java
public class RankService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 更新分数
    public void updateScore(String rankName, String userId, double score) {
        redisTemplate.opsForZSet().add(rankName, userId, score);
    }

    // 获取排名
    public List<String> getTopN(String rankName, int n) {
        Set<String> set = redisTemplate.opsForZSet()
            .reverseRange(rankName, 0, n - 1);
        return new ArrayList<>(set);
    }

    // 获取用户排名
    public Long getUserRank(String rankName, String userId) {
        return redisTemplate.opsForZSet().reverseRank(rankName, userId);
    }
}
```

## 三、高级数据结构

### 3.1 Bitmap(位图)

```bash
# 设置位
SETBIT bitkey 0 1
SETBIT bitkey 1 1

# 获取位
GETBIT bitkey 0

# 统计位数
BITCOUNT bitkey
```

**使用场景**: 用户签到、在线状态统计

### 3.2 HyperLogLog

```bash
# 添加元素
PFADD hll a b c d

# 统计基数
PFCOUNT hll
```

**使用场景**: UV统计、IP统计

### 3.3 GEO

```bash
# 添加地理位置
GEOADD city 116.40 39.90 "北京"
GEOADD city 121.47 31.23 "上海"

# 计算距离
GEODIST city 北京 上海 km

# 获取附近位置
GEORADIUS city 116.40 39.90 100 km
```

**使用场景**: 附近的人、打车距离计算

## 四、总结

Redis提供了丰富的数据结构,每种结构都有其特定的使用场景。在实际开发中,需要根据业务需求选择合适的数据结构,才能发挥Redis的最大价值。同时要注意Redis的内存使用,合理设置过期时间,避免内存溢出。