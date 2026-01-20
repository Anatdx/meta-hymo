#!/bin/bash

# Hymo WebUI Development Server

PORT=${1:-8080}

echo "🚀 Starting Hymo WebUI Development Server..."
echo "📍 Port: $PORT"
echo ""
echo "🌐 Open your browser to:"
echo "   http://localhost:$PORT"
echo "   http://127.0.0.1:$PORT"
echo ""

cd "$(dirname "$0")"

# 检查依赖
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

# 启动开发服务器
npm run dev -- --port $PORT --host 0.0.0.0
