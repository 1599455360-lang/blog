---
title: SpringBoot自动装配原理
categories:
  - 技术教程
tags:
  - SpringBoot
  - 后端技术
abbrlink: c3d0
date: 2026-04-07 18:45:00
---

## 一、什么是自动装配

Spring Boot的自动装配是指根据项目中的依赖自动配置Spring应用的功能。它消除了传统Spring应用中大量的XML配置,让开发者可以"开箱即用"。

## 二、@SpringBootApplication注解

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

这个注解是一个组合注解:

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = {
    @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
    @Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
    // ...
}
```

核心注解:
- `@SpringBootConfiguration`: 标识这是一个配置类
- `@EnableAutoConfiguration`: 开启自动配置
- `@ComponentScan`: 组件扫描

## 三、@EnableAutoConfiguration原理

### 3.1 注解定义

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import(AutoConfigurationImportSelector.class)
public @interface EnableAutoConfiguration {
    String ENABLED_OVERRIDE_PROPERTY = "spring.boot.enableautoconfiguration";

    Class<?>[] exclude() default {};

    String[] excludeName() default {};
}
```

### 3.2 AutoConfigurationImportSelector

核心逻辑在`AutoConfigurationImportSelector`类中:

```java
@Override
public String[] selectImports(AnnotationMetadata annotationMetadata) {
    if (!isEnabled(annotationMetadata)) {
        return NO_IMPORTS;
    }
    AutoConfigurationEntry autoConfigurationEntry = getAutoConfigurationEntry(annotationMetadata);
    return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
}
```

## 四、spring.factories文件

Spring Boot会在启动时扫描所有jar包中的`META-INF/spring.factories`文件:

```properties
# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
org.springframework.boot.autoconfigure.aop.AopAutoConfiguration,\
org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration,\
org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration
```

## 五、条件注解

Spring Boot使用条件注解来决定是否装配某个Bean:

### 5.1 常用条件注解

```java
@ConditionalOnClass(DataSource.class)  // 类路径中存在DataSource类时生效
@ConditionalOnBean(DataSource.class)   // 容器中存在DataSource Bean时生效
@ConditionalOnMissingBean              // 容器中不存在某个Bean时生效
@ConditionalOnProperty                 // 配置属性满足条件时生效
@ConditionalOnWebApplication           // 是Web应用时生效
```

### 5.2 示例: DataSourceAutoConfiguration

```java
@Configuration(proxyBeanMethods = false)
@ConditionalOnClass({ DataSource.class, EmbeddedDatabaseType.class })
@ConditionalOnMissingBean(type = "io.r2dbc.spi.ConnectionFactory")
@EnableConfigurationProperties(DataSourceProperties.class)
@Import({ DataSourcePoolMetadataProvidersConfiguration.class,
          DataSourceInitializationConfiguration.class })
public class DataSourceAutoConfiguration {

    @Configuration(proxyBeanMethods = false)
    @Conditional(EmbeddedDatabaseCondition.class)
    @ConditionalOnMissingBean({ DataSource.class, XADataSource.class })
    @Import(EmbeddedDataSourceConfiguration.class)
    protected static class EmbeddedDatabaseConfiguration {
    }
}
```

## 六、自定义Starter

### 6.1 创建配置类

```java
@Configuration
@ConditionalOnClass(MyService.class)
@EnableConfigurationProperties(MyProperties.class)
public class MyAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public MyService myService() {
        return new MyService();
    }
}
```

### 6.2 配置属性类

```java
@ConfigurationProperties(prefix = "my.service")
public class MyProperties {
    private String name;
    private int age;
    // getter and setter
}
```

### 6.3 创建spring.factories

在`resources/META-INF/spring.factories`中添加:

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.example.MyAutoConfiguration
```

## 七、自动装配流程

1. **启动类加载**: 扫描@SpringBootApplication注解
2. **导入选择器**: 通过@Import导入AutoConfigurationImportSelector
3. **加载配置**: 读取spring.factories文件中的配置类
4. **条件过滤**: 根据条件注解过滤不满足条件的配置
5. **注册Bean**: 将满足条件的Bean注册到Spring容器

## 八、禁用自动装配

### 8.1 排除特定配置

```java
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class Application {
    // ...
}
```

### 8.2 配置文件禁用

```properties
spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
```

## 九、总结

Spring Boot的自动装配机制大大简化了Spring应用的配置工作。通过`@EnableAutoConfiguration`注解和条件注解的组合,实现了按需加载配置的智能化机制。理解自动装配原理,有助于我们更好地使用Spring Boot,并能够开发自定义的Starter组件。