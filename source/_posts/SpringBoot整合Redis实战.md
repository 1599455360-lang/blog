---
title: SpringBoot整合Redis实战
categories:
  - 技术教程
tags:
  - SpringBoot
  - Redis
  - 后端技术
abbrlink: f9ce
date: 2026-04-04 18:45:00
---

## 一、环境准备

### 1.1 添加依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```

### 1.2 配置文件

```yaml
spring:
  redis:
    host: localhost
    port: 6379
    password: # 如果有密码则填写
    database: 0
    timeout: 3000
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
        max-wait: -1
```

## 二、RedisTemplate使用

### 2.1 配置RedisTemplate

```java
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(
            RedisConnectionFactory connectionFactory) {

        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        // 使用Jackson2JsonRedisSerializer来序列化和反序列化redis的value值
        Jackson2JsonRedisSerializer<Object> jackson2JsonRedisSerializer =
            new Jackson2JsonRedisSerializer<>(Object.class);

        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.activateDefaultTyping(
            LaissezFaireSubTypeValidator.instance,
            ObjectMapper.DefaultTyping.NON_FINAL
        );
        jackson2JsonRedisSerializer.setObjectMapper(om);

        // 使用StringRedisSerializer来序列化和反序列化redis的key值
        StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();

        // key采用String的序列化方式
        template.setKeySerializer(stringRedisSerializer);
        // hash的key也采用String的序列化方式
        template.setHashKeySerializer(stringRedisSerializer);
        // value序列化方式采用jackson
        template.setValueSerializer(jackson2JsonRedisSerializer);
        // hash的value序列化方式采用jackson
        template.setHashValueSerializer(jackson2JsonRedisSerializer);

        template.afterPropertiesSet();
        return template;
    }
}
```

### 2.2 基础操作

```java
@Service
public class RedisService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // 设置值
    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    // 设置值并设置过期时间
    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    // 获取值
    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    // 删除key
    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    // 判断key是否存在
    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    // 设置过期时间
    public Boolean expire(String key, long timeout, TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    // 获取过期时间
    public Long getExpire(String key) {
        return redisTemplate.getExpire(key);
    }

    // 自增
    public Long increment(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    // 自减
    public Long decrement(String key, long delta) {
        return redisTemplate.opsForValue().decrement(key, delta);
    }
}
```

## 三、缓存应用

### 3.1 使用注解缓存

#### 启用缓存

```java
@SpringBootApplication
@EnableCaching
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

#### 缓存配置

```java
@Configuration
public class CacheConfig {

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofHours(1))  // 默认过期时间1小时
            .disableCachingNullValues()     // 不缓存null值
            .serializeKeysWith(
                RedisSerializationContext.SerializationPair
                    .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(
                RedisSerializationContext.SerializationPair
                    .fromSerializer(new GenericJackson2JsonRedisSerializer()));

        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .build();
    }
}
```

#### 使用缓存注解

```java
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    // 查询时缓存
    @Cacheable(value = "user", key = "#id")
    public User getUserById(Long id) {
        System.out.println("查询数据库...");
        return userRepository.findById(id).orElse(null);
    }

    // 更新时删除缓存
    @CacheEvict(value = "user", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    // 删除时清除缓存
    @CacheEvict(value = "user", key = "#id")
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    // 新增时缓存
    @CachePut(value = "user", key = "#user.id")
    public User saveUser(User user) {
        return userRepository.save(user);
    }
}
```

### 3.2 缓存注解说明

- `@Cacheable`: 查询时使用缓存,如果缓存存在则直接返回
- `@CachePut`: 更新缓存,每次都会执行方法并将结果缓存
- `@CacheEvict`: 删除缓存
- `@Caching`: 组合多个缓存注解

## 四、分布式锁实现

### 4.1 简单分布式锁

```java
@Service
public class RedisLockService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    /**
     * 加锁
     * @param key 锁的key
     * @param value 锁的值(通常是UUID)
     * @param expireTime 过期时间
     * @param timeUnit 时间单位
     * @return 是否加锁成功
     */
    public boolean lock(String key, String value, long expireTime, TimeUnit timeUnit) {
        Boolean result = redisTemplate.opsForValue()
            .setIfAbsent(key, value, expireTime, timeUnit);
        return Boolean.TRUE.equals(result);
    }

    /**
     * 解锁
     * @param key 锁的key
     * @param value 锁的值
     * @return 是否解锁成功
     */
    public boolean unlock(String key, String value) {
        String script = "if redis.call('get', KEYS[1]) == ARGV[1] " +
                       "then return redis.call('del', KEYS[1]) " +
                       "else return 0 end";
        RedisScript<Long> redisScript = RedisScript.of(script, Long.class);
        Long result = redisTemplate.execute(redisScript, Collections.singletonList(key), value);
        return Long.valueOf(1).equals(result);
    }
}
```

### 4.2 使用分布式锁

```java
@Service
public class OrderService {

    @Autowired
    private RedisLockService redisLockService;

    public String createOrder(String productId) {
        String lockKey = "lock:product:" + productId;
        String lockValue = UUID.randomUUID().toString();

        try {
            // 尝试加锁
            if (redisLockService.lock(lockKey, lockValue, 10, TimeUnit.SECONDS)) {
                // 执行业务逻辑
                return doCreateOrder(productId);
            } else {
                throw new RuntimeException("系统繁忙,请稍后重试");
            }
        } finally {
            // 释放锁
            redisLockService.unlock(lockKey, lockValue);
        }
    }

    private String doCreateOrder(String productId) {
        // 创建订单逻辑
        return "ORDER_" + System.currentTimeMillis();
    }
}
```

## 五、缓存穿透、击穿、雪崩

### 5.1 缓存穿透

**问题**: 查询不存在的数据,每次都查询数据库

**解决方案**:

```java
public User getUserWithCacheBust(Long id) {
    String key = "user:" + id;

    // 1. 查询缓存
    Object value = redisTemplate.opsForValue().get(key);
    if (value != null) {
        if ("NULL".equals(value)) {
            return null;  // 防止缓存穿透
        }
        return (User) value;
    }

    // 2. 查询数据库
    User user = userRepository.findById(id).orElse(null);

    // 3. 写入缓存
    if (user != null) {
        redisTemplate.opsForValue().set(key, user, 1, TimeUnit.HOURS);
    } else {
        // 缓存空值,防止缓存穿透
        redisTemplate.opsForValue().set(key, "NULL", 5, TimeUnit.MINUTES);
    }

    return user;
}
```

### 5.2 缓存击穿

**问题**: 热点key过期,大量请求直接打到数据库

**解决方案**: 使用互斥锁

```java
public User getUserWithMutex(Long id) {
    String key = "user:" + id;
    String lockKey = "lock:user:" + id;

    // 1. 查询缓存
    User user = (User) redisTemplate.opsForValue().get(key);
    if (user != null) {
        return user;
    }

    // 2. 尝试获取锁
    try {
        if (redisLockService.lock(lockKey, "1", 10, TimeUnit.SECONDS)) {
            // 再次检查缓存(双重检查)
            user = (User) redisTemplate.opsForValue().get(key);
            if (user != null) {
                return user;
            }

            // 查询数据库
            user = userRepository.findById(id).orElse(null);

            // 写入缓存
            if (user != null) {
                redisTemplate.opsForValue().set(key, user, 1, TimeUnit.HOURS);
            }
        } else {
            // 等待一段时间后重试
            Thread.sleep(50);
            return getUserWithMutex(id);
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    } finally {
        redisLockService.unlock(lockKey, "1");
    }

    return user;
}
```

### 5.3 缓存雪崩

**问题**: 大量key同时过期

**解决方案**: 设置随机过期时间

```java
public void cacheUser(User user) {
    String key = "user:" + user.getId();

    // 随机过期时间: 1小时 ± 随机10分钟
    Random random = new Random();
    long expireTime = 60 + random.nextInt(20) - 10;

    redisTemplate.opsForValue().set(key, user, expireTime, TimeUnit.MINUTES);
}
```

## 六、实际应用案例

### 6.1 排行榜

```java
@Service
public class RankService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    private static final String RANK_KEY = "game:rank";

    // 更新分数
    public void updateScore(String userId, double score) {
        redisTemplate.opsForZSet().add(RANK_KEY, userId, score);
    }

    // 获取排名列表
    public List<Map<String, Object>> getTopN(int n) {
        Set<ZSetOperations.TypedTuple<Object>> set =
            redisTemplate.opsForZSet().reverseRangeWithScores(RANK_KEY, 0, n - 1);

        List<Map<String, Object>> result = new ArrayList<>();
        int rank = 1;
        for (ZSetOperations.TypedTuple<Object> tuple : set) {
            Map<String, Object> map = new HashMap<>();
            map.put("rank", rank++);
            map.put("userId", tuple.getValue());
            map.put("score", tuple.getScore());
            result.add(map);
        }
        return result;
    }

    // 获取用户排名
    public Long getUserRank(String userId) {
        return redisTemplate.opsForZSet().reverseRank(RANK_KEY, userId);
    }
}
```

### 6.2 限流

```java
@Service
public class RateLimitService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    /**
     * 限流
     * @param key 限流key
     * @param limit 限制次数
     * @param period 时间窗口(秒)
     * @return 是否允许访问
     */
    public boolean allowRequest(String key, int limit, int period) {
        String script =
            "local current = redis.call('incr', KEYS[1]) " +
            "if current == 1 then " +
            "  redis.call('expire', KEYS[1], ARGV[1]) " +
            "end " +
            "return current <= ARGV[2]";

        RedisScript<Boolean> redisScript = RedisScript.of(script, Boolean.class);
        Boolean result = redisTemplate.execute(
            redisScript,
            Collections.singletonList(key),
            String.valueOf(period),
            String.valueOf(limit)
        );

        return Boolean.TRUE.equals(result);
    }
}
```

## 七、总结

Spring Boot整合Redis后,可以轻松实现缓存、分布式锁、排行榜等功能。在实际应用中需要注意:
1. 合理设置过期时间
2. 处理缓存穿透、击穿、雪崩问题
3. 注意序列化方式的选择
4. 做好异常处理和降级方案