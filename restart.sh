#!/bin/bash

# Hexo 博客重启脚本
# 作者: JJ_KMR
# 功能: 重启 Hexo 博客服务器

echo "================================"
echo "  Hexo 博客重启脚本"
echo "================================"

# 检查是否有进程在运行
if lsof -ti:4000 > /dev/null 2>&1; then
    echo "[1/3] 停止现有服务器..."
    lsof -ti:4000 | xargs kill -9 2>/dev/null
    echo "✓ 服务器已停止"
else
    echo "[1/3] 没有运行中的服务器"
fi

# 清理缓存
echo "[2/3] 清理缓存并生成静态文件..."
npx hexo clean > /dev/null 2>&1
npx hexo generate > /dev/null 2>&1
echo "✓ 缓存已清理,静态文件已生成"

# 启动服务器
echo "[3/3] 启动服务器..."
nohup npx hexo server > /dev/null 2>&1 &

# 等待服务启动
sleep 3

# 检查是否启动成功
if lsof -ti:4000 > /dev/null 2>&1; then
    echo "================================"
    echo "✓ 服务器启动成功!"
    echo "访问地址: http://localhost:4000"
    echo "================================"
else
    echo "✗ 服务器启动失败"
    exit 1
fi