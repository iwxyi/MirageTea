#!/bin/bash

# MirageTea 启动脚本
# 用法: ./run.sh [platform]
# 支持的平台: macos, ios, android, windows, linux, web

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter"
    echo "   访问 https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

# 获取依赖
echo "📦 安装依赖..."
flutter pub get

# 解析参数
PLATFORM=${1:-macos}

echo "🚀 启动 MirageTea ($PLATFORM)..."

case $PLATFORM in
    macos)
        flutter run -d macos
        ;;
    ios)
        flutter run -d ios
        ;;
    android)
        flutter run -d android
        ;;
    windows)
        flutter run -d windows
        ;;
    linux)
        flutter run -d linux
        ;;
    web)
        flutter run -d chrome
        ;;
    *)
        echo "❌ 不支持的平台: $PLATFORM"
        echo "   支持的平台: macos, ios, android, windows, linux, web"
        exit 1
        ;;
esac

