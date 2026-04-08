#!/bin/bash

# Hexo 博客状态检查脚本
# 作者: JJ_KMR
# 功能: 检查 Hexo 博客服务器运行状态

echo "================================"
echo "  Hexo 博客状态检查"
echo "================================"

# 检查端口是否被占用
if lsof -ti:4000 > /dev/null 2>&1; then
    PID=$(lsof -ti:4000)
    echo "✓ 服务器正在运行"
    echo ""
    echo "进程信息:"
    echo "  - PID: $PID"
    echo "  - 端口: 4000"
    echo "  - 访问地址: http://localhost:4000"
    echo ""
    
    # 显示进程详情
    ps -p $PID -o pid,ppid,%cpu,%mem,etime,command | grep -v grep
    
    echo ""
    echo "================================"
    echo "提示:"
    echo "  - 启动: ./start.sh"
    echo "  - 停止: ./stop.sh"
    echo "  - 重启: ./restart.sh"
    echo "================================"
else
    echo "✗ 服务器未运行"
    echo ""
    echo "================================"
    echo "使用以下命令启动服务器:"
    echo "  ./start.sh"
    echo "================================"
fi