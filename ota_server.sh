#!/bin/bash
# 星宠 OTA 更新服务器启动脚本

# 获取Tailscale IP
TAILSCALE_IP=$(ifconfig utun 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)

echo "========================================="
echo "       星宠 OTA 服务器"
echo "========================================="
echo ""
echo "Tailscale IP: $TAILSCALE_IP"
echo "本地端口: 8080"
echo ""
echo "手机访问: http://$TAILSCALE_IP:8080"
echo ""
echo "按 Ctrl+C 停止服务器"
echo "========================================="

cd "$(dirname "$0")/ota"
python3 -m http.server 8080
