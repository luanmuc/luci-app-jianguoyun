#!/bin/bash
# 坚果云插件编译前置脚本 V1.2.4_FULL_SYNC 最终版
# 适配「插件集成到固件全量编译」场景，兼容CMCC A10设备
set -e

echo "======================"
echo "【坚果云插件】开始执行前置自定义脚本"
echo "======================"

# 1. 同步插件源码到编译环境
echo "正在同步插件源码到编译环境..."
mkdir -p package/luci-app-jianguoyun
cp -rf $GITHUB_WORKSPACE/* package/luci-app-jianguoyun/
rm -rf package/luci-app-jianguoyun/.github

# 2. 更新OpenWrt官方软件源
echo "正在更新OpenWrt官方软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 适配CMCC A10专属架构
echo "正在适配CMCC A10设备专属架构..."
sed -i 's/^TARGET_ARCH=.*/TARGET_ARCH=aarch64_cortex-a53/' .config 2>/dev/null || true

echo "======================"
echo "【坚果云插件】前置脚本执行完成"
echo "======================"
