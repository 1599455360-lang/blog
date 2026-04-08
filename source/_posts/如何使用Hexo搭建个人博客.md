---
title: 如何使用Hexo搭建个人博客
tags:
  - Hexo
  - 博客搭建
  - 教程
categories: 技术教程
keywords: 'Hexo,博客搭建,静态博客'
cover: /medias/featureimages/hexo.jpg
abbrlink: 7ec9
date: 2026-04-08 11:22:04
---

# 如何使用Hexo搭建个人博客

本文将详细介绍如何使用 Hexo 搭建一个功能完善的个人博客。

## 什么是Hexo？

[Hexo](https://hexo.io/) 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。

## 安装准备

在开始之前，你需要确保电脑已经安装了以下软件：

### Node.js

Hexo 基于 Node.js 开发，因此需要先安装 Node.js。

<div class="install-tip" data-tooltip="访问Node.js官网下载安装">
  <i class="fab fa-node-js"></i>
  <span>下载地址：<a href="https://nodejs.org/" target="_blank">https://nodejs.org/</a></span>
</div>

### Git

Git 用于版本控制和博客部署。

<div class="install-tip" data-tooltip="访问Git官网下载安装">
  <i class="fab fa-git-alt"></i>
  <span>下载地址：<a href="https://git-scm.com/" target="_blank">https://git-scm.com/</a></span>
</div>

## 安装Hexo

安装完 Node.js 和 Git 后，使用 npm 安装 Hexo CLI：

```bash
npm install -g hexo-cli
```

## 初始化博客

### 创建博客目录

```bash
hexo init my-blog
cd my-blog
npm install
```

### 目录结构

安装完成后，你的博客目录结构如下：

```
my-blog/
├── _config.yml    # 网站配置文件
├── package.json   # 应用程序信息
├── scaffolds      # 模板文件夹
├── source         # 存放用户资源的地方
|   ├── _drafts    # 草稿文件夹
|   └── _posts     # 文章文件夹
└── themes         # 主题文件夹
```

## 安装主题

本博客使用的是 [Matery](https://github.com/blinkfox/hexo-theme-matery) 主题，安装步骤如下：

### 克隆主题

```bash
git clone https://github.com/blinkfox/hexo-theme-matery.git themes/matery
```

### 修改配置

修改根目录下的 `_config.yml` 文件：

```yaml
theme: matery
```

## 创建文章

使用以下命令创建新文章：

```bash
hexo new post "文章标题"
```

文章会创建在 `source/_posts` 目录下。

## 本地预览

启动本地服务器预览博客：

```bash
hexo server
# 或简写
hexo s
```

浏览器访问 `http://localhost:4000` 即可预览博客。

## 部署博客

### 部署到GitHub Pages

1. 在 GitHub 创建仓库，仓库名格式为 `username.github.io`

2. 安装部署插件：

```bash
npm install hexo-deployer-git --save
```

3. 修改 `_config.yml` 配置：

```yaml
deploy:
  type: git
  repo: https://github.com/username/username.github.io.git
  branch: master
```

4. 部署博客：

```bash
hexo clean
hexo generate
hexo deploy
```

部署成功后，访问 `https://username.github.io` 即可查看你的博客。

## 常用命令

<div class="command-list">
  <div class="command-item" data-tooltip="清除缓存文件">
    <code>hexo clean</code>
    <span>清除缓存文件</span>
  </div>
  <div class="command-item" data-tooltip="生成静态文件">
    <code>hexo generate</code>
    <span>生成静态文件</span>
  </div>
  <div class="command-item" data-tooltip="启动本地服务器">
    <code>hexo server</code>
    <span>启动本地服务器</span>
  </div>
  <div class="command-item" data-tooltip="部署网站">
    <code>hexo deploy</code>
    <span>部署网站</span>
  </div>
</div>

## 总结

Hexo 是一个非常优秀的博客框架，具有以下优点：

- 快速生成静态页面
- 丰富的主题和插件
- 支持 Markdown 写作
- 易于部署和维护

希望这篇教程能帮助你快速搭建自己的博客！

<style>
.install-tip, .command-item {
  display: flex;
  align-items: center;
  padding: 15px;
  margin: 10px 0;
  background: #f8f9fa;
  border-radius: 8px;
  transition: all 0.3s ease;
  position: relative;
}

.install-tip:hover, .command-item:hover {
  background: #667eea;
  color: white;
  transform: translateX(5px);
}

.install-tip i {
  font-size: 32px;
  margin-right: 15px;
  color: #667eea;
}

.install-tip:hover i {
  color: white;
}

.install-tip a, .command-item code {
  color: #667eea;
  font-weight: bold;
}

.install-tip:hover a {
  color: white;
}

.command-item code {
  background: rgba(255,255,255,0.2);
  padding: 5px 10px;
  border-radius: 4px;
  margin-right: 15px;
}

.install-tip:hover code, .command-item:hover code {
  background: rgba(255,255,255,0.3);
  color: white;
}

.command-list {
  margin: 20px 0;
}

.install-tip::after, .command-item::after {
  content: attr(data-tooltip);
  position: absolute;
  left: 100%;
  top: 50%;
  transform: translateY(-50%);
  padding: 5px 15px;
  background: rgba(0,0,0,0.8);
  color: white;
  border-radius: 5px;
  font-size: 12px;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  margin-left: 10px;
}

.install-tip:hover::after, .command-item:hover::after {
  opacity: 1;
  visibility: visible;
}
</style>
