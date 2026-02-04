#!/bin/bash

# MirageTea 构建脚本
# 用法: ./build.sh [platform]
# 支持的平台: macos, ios, android, windows, linux, web

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "🏗️ 构建 MirageTea..."

# 解析参数
PLATFORM=${1:-macos}

case $PLATFORM in
    macos)
        echo "🍎 构建 macOS 应用..."
        flutter build macos
        echo "✅ 构建完成: build/macos/Build/Products/Release/mirage_tea.app"
        ;;
    ios)
        echo "📱 构建 iOS 应用..."
        flutter build ipa
        echo "✅ 构建完成: build/ios/ipa/*.ipa"
        ;;
    android)
        echo "🤖 构建 Android APK..."
        flutter build apk --split-per-abi
        echo "✅ 构建完成: build/app/outputs/apk/*/*.apk"
        ;;
    windows)
        echo "🪟 构建 Windows 应用..."
        flutter build windows
        echo "✅ 构建完成: build/windows/runner/Release/"
        ;;
    linux)
        echo "🐧 构建 Linux 应用..."
        flutter build linux
        echo "✅ 构建完成: build/linux/x64/release/bundle/"
        ;;
    web)
        echo "🌐 构建 Web 应用..."
        flutter build web
        echo "✅ 构建完成: build/web/"
        ;;
    all)
        echo "🌍 构建所有平台..."
        flutter build macos
        flutter build ipa
        flutter build apk --split-per-abi
        flutter build windows
        flutter build linux
        flutter build web
        echo "✅ 所有平台构建完成!"
        ;;
    *)
        echo "❌ 不支持的平台: $PLATFORM"
        echo "   支持的平台: macos, ios, android, windows, linux, web, all"
        exit 1
        ;;
esac

