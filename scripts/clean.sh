#!/bin/bash
# 坚果云插件编译环境清理脚本 V1.2.4_FULL_SYNC 最终版
# 一键重置干净编译环境，解决重复编译冲突
set -e

echo "======================"
echo "【坚果云插件】开始清理编译环境"
echo "======================"

# 1. 清理打包临时目录与产物
echo "正在清理打包临时文件与历史产物..."
rm -rf build_tmp
rm -rf output

# 2. 清理git冗余临时文件（保留核心工作流与源码）
echo "正在清理git冗余临时文件..."
git clean -f -d -e .github/ -e scripts/ -e Makefile -e luasrc/ -e root/ -e files/ -e README.md

echo "======================"
echo "✅ 【坚果云插件】编译环境清理完成"
echo "已重置为干净的源码环境，可重新触发编译"
echo "======================"
