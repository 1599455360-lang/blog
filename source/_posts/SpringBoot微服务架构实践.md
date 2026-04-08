---
title: SpringBoot微服务架构实践
categories:
  - 技术教程
tags:
  - SpringBoot
  - 微服务
  - 后端技术
abbrlink: '807'
date: 2026-04-01 18:45:00
---

## 一、微服务架构概述

微服务架构是一种将单一应用程序划分成一组小的服务的方法,每个服务运行在自己的进程中,服务之间通过轻量级通信机制进行协作。

### 1.1 微服务特点

- **服务小而独立**: 每个服务专注于单一业务功能
- **独立部署**: 每个服务可以独立部署和扩展
- **技术多样性**: 不同服务可以使用不同的技术栈
- **松耦合**: 服务之间依赖最小化
- **去中心化**: 数据库、治理等去中心化

### 1.2 微服务优缺点

**优点:**
- 灵活性和可扩展性高
- 技术栈自由
- 故障隔离
- 团队独立性强

**缺点:**
- 系统复杂度增加
- 分布式事务处理困难
- 运维成本高
- 服务间通信复杂

## 二、Spring Boot微服务核心组件

### 2.1 服务注册与发现

使用Spring Cloud Netflix Eureka:

#### Eureka Server

```java
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

配置文件:

```yaml
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

#### Eureka Client

```java
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

配置文件:

```yaml
server:
  port: 8081

spring:
  application:
    name: user-service

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

### 2.2 服务间通信

#### RestTemplate

```java
@Service
public class OrderService {

    @Autowired
    private RestTemplate restTemplate;

    @LoadBalanced
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    public User getUserById(Long userId) {
        String url = "http://user-service/api/users/" + userId;
        return restTemplate.getForObject(url, User.class);
    }
}
```

#### OpenFeign

```java
@FeignClient(name = "user-service")
public interface UserClient {

    @GetMapping("/api/users/{id}")
    User getUserById(@PathVariable("id") Long id);
}

@Service
public class OrderService {

    @Autowired
    private UserClient userClient;

    public User getUserById(Long userId) {
        return userClient.getUserById(userId);
    }
}
```

### 2.3 负载均衡

使用Spring Cloud LoadBalancer:

```java
@Configuration
public class LoadBalancerConfig {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

自定义负载均衡策略:

```java
@Configuration
public class CustomLoadBalancerConfig {

    @Bean
    ReactorServiceInstanceLoadBalancer randomLoadBalancer(
            Environment environment,
            LoadBalancerClientFactory loadBalancerClientFactory) {

        String serviceId = environment.getProperty(LoadBalancerClientFactory.PROPERTY_NAME);
        return new RandomLoadBalancer(
            loadBalancerClientFactory.getLazyProvider(serviceId, ServiceInstanceListSupplier.class),
            serviceId
        );
    }
}
```

### 2.4 服务网关

使用Spring Cloud Gateway:

```java
@SpringBootApplication
public class GatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}
```

配置文件:

```yaml
server:
  port: 8080

spring:
  application:
    name: gateway-service
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=1

        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

### 2.5 配置中心

使用Spring Cloud Config:

#### Config Server

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

配置文件:

```yaml
server:
  port: 8888

spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        git:
          uri: https://github.com/your-repo/config-repo
          search-paths: config
          username: your-username
          password: your-password
```

#### Config Client

```yaml
spring:
  application:
    name: user-service
  cloud:
    config:
      uri: http://localhost:8888
      profile: dev
      label: master
```

### 2.6 服务熔断与降级

使用Resilience4j:

```java
@Service
public class OrderService {

    @Autowired
    private UserClient userClient;

    @CircuitBreaker(name = "userService", fallbackMethod = "getUserFallback")
    public User getUserById(Long userId) {
        return userClient.getUserById(userId);
    }

    public User getUserFallback(Long userId, Exception e) {
        User user = new User();
        user.setId(userId);
        user.setName("默认用户");
        return user;
    }
}
```

配置文件:

```yaml
resilience4j:
  circuitbreaker:
    configs:
      default:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 10000
        permittedNumberOfCallsInHalfOpenState: 3
    instances:
      userService:
        baseConfig: default
```

## 三、分布式事务解决方案

### 3.1 Seata

#### AT模式

```java
@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private AccountClient accountClient;

    @Autowired
    private StorageClient storageClient;

    @GlobalTransactional(name = "create-order")
    public void createOrder(Order order) {
        // 创建订单
        orderMapper.insert(order);

        // 扣减库存
        storageClient.decrease(order.getProductId(), order.getCount());

        // 扣减余额
        accountClient.decrease(order.getUserId(), order.getMoney());
    }
}
```

### 3.2 消息最终一致性

```java
@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    @Transactional
    public void createOrder(Order order) {
        // 创建订单
        orderMapper.insert(order);

        // 发送消息到MQ
        OrderMessage message = new OrderMessage();
        message.setOrderId(order.getId());
        message.setUserId(order.getUserId());
        message.setMoney(order.getMoney());

        rocketMQTemplate.sendMessageInTransaction(
            "order-group",
            "order-topic",
            MessageBuilder.withPayload(message).build(),
            null
        );
    }
}
```

## 四、链路追踪

### 4.1 Spring Cloud Sleuth + Zipkin

添加依赖:

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
```

配置文件:

```yaml
spring:
  zipkin:
    base-url: http://localhost:9411
  sleuth:
    sampler:
      probability: 1.0  # 采样率100%
```

## 五、API文档

### 5.1 Swagger/Knife4j

```java
@Configuration
@EnableKnife4j
public class SwaggerConfig {

    @Bean
    public Docket api() {
        return new Docket(DocumentationType.SWAGGER_2)
            .apiInfo(apiInfo())
            .select()
            .apis(RequestHandlerSelectors.basePackage("com.example.controller"))
            .paths(PathSelectors.any())
            .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
            .title("用户服务API")
            .description("用户服务接口文档")
            .version("1.0")
            .build();
    }
}
```

## 六、监控与运维

### 6.1 Spring Boot Admin

```java
@SpringBootApplication
@EnableAdminServer
public class AdminApplication {
    public static void main(String[] args) {
        SpringApplication.run(AdminApplication.class, args);
    }
}
```

### 6.2 Prometheus + Grafana

添加依赖:

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

配置文件:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  metrics:
    tags:
      application: ${spring.application.name}
```

## 七、安全认证

### 7.1 Spring Security + OAuth2

```java
@Configuration
@EnableResourceServer
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {

    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
            .antMatchers("/api/public/**").permitAll()
            .antMatchers("/api/**").authenticated()
            .and()
            .csrf().disable();
    }
}
```

### 7.2 JWT Token

```java
@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return Jwts.builder()
            .setClaims(claims)
            .setSubject(userDetails.getUsername())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 10))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
    }

    public String extractUsername(String token) {
        return Jwts.parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
    }
}
```

## 八、Docker容器化

### 8.1 Dockerfile

```dockerfile
FROM openjdk:11-jdk-slim
VOLUME /tmp
COPY target/user-service.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### 8.2 Docker Compose

```yaml
version: '3'

services:
  eureka-server:
    image: eureka-server:latest
    ports:
      - "8761:8761"

  user-service:
    image: user-service:latest
    ports:
      - "8081:8081"
    environment:
      - EUREKA_SERVER=http://eureka-server:8761/eureka/
    depends_on:
      - eureka-server

  order-service:
    image: order-service:latest
    ports:
      - "8082:8082"
    environment:
      - EUREKA_SERVER=http://eureka-server:8761/eureka/
    depends_on:
      - eureka-server
      - user-service

  gateway:
    image: gateway:latest
    ports:
      - "8080:8080"
    environment:
      - EUREKA_SERVER=http://eureka-server:8761/eureka/
    depends_on:
      - eureka-server
```

## 九、总结

Spring Boot为构建微服务架构提供了完整的解决方案。通过整合Spring Cloud全家桶,可以快速构建一个完整的微服务系统。在实际应用中,需要根据业务需求选择合适的技术组件,并注意:
1. 服务的拆分粒度
2. 分布式事务处理
3. 服务容错和降级
4. 统一配置管理
5. 链路追踪和监控
6. 安全认证和授权

微服务架构虽然带来了灵活性,但也增加了系统复杂度,需要权衡利弊后再做选择。