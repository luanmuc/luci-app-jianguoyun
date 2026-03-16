#!/bin/bash
# 坚果云插件云编译前置脚本 V1.2.4_FULL_SYNC 最终版
# 100%适配现有build.yml配置，严格遵守不修改工作流主线铁律
set -e

echo "======================"
echo "【坚果云插件】开始执行前置自定义脚本"
echo "======================"

# 1. 将当前仓库插件源码同步到编译环境package目录
echo "正在同步插件源码到编译环境..."
mkdir -p package/luci-app-jianguoyun
cp -rf $GITHUB_WORKSPACE/* package/luci-app-jianguoyun/
rm -rf package/luci-app-jianguoyun/.github  # 清理工作流冗余文件，避免编译干扰

# 2. 更新OpenWrt官方软件源
echo "正在更新OpenWrt官方软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 适配CMCC A10(MT7981)专属架构
echo "正在适配CMCC A10设备专属架构..."
sed -i 's/^TARGET_ARCH=.*/TARGET_ARCH=aarch64_cortex-a53/' .config 2>/dev/null || true

echo "======================"
echo "【坚果云插件】前置脚本执行完成"
echo "======================"
