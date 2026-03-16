#!/bin/bash
# 坚果云插件编译环境清理脚本 V1.2.4_FULL_SYNC 最终版
# 适配独立SDK编译场景，一键重置干净编译环境
set -e

echo "======================"
echo "【坚果云插件】开始清理编译环境"
echo "======================"

# 1. 清理SDK解压目录与下载的SDK压缩包
echo "正在清理SDK相关文件..."
rm -rf openwrt-sdk
rm -f sdk.tar.xz

# 2. 清理编译产物output目录
echo "正在清理历史编译产物..."
rm -rf output

# 3. 清理临时文件与缓存
echo "正在清理临时文件与缓存..."
rm -rf tmp
rm -rf .config
rm -rf feeds.conf.default

# 4. 清理git临时文件
echo "正在清理git冗余临时文件..."
git clean -f -d -e .github/ -e scripts/ -e Makefile -e luasrc/ -e root/ -e files/ -e README.md

echo "======================"
echo "✅ 【坚果云插件】编译环境清理完成"
echo "已重置为干净的源码环境，可重新触发编译"
echo "======================"
