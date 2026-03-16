#!/bin/bash
# 坚果云插件独立编译构建脚本 V1.2.4_FULL_SYNC
# 适配CMCC A10(MT7981) aarch64_cortex-a53架构，OpenWrt 23.05稳定版SDK
set -e

# 编译环境配置
export SDK_URL="https://downloads.openwrt.org/releases/23.05.3/targets/mediatek/filogic/openwrt-sdk-23.05.3-mediatek-filogic_gcc-12.3.0_musl.Linux-x86_64.tar.xz"
export SDK_DIR="openwrt-sdk"
export PLUGIN_NAME="luci-app-jianguoyun"

echo "======================"
echo "【坚果云插件】开始构建"
echo "======================"

# 1. 下载并解压对应架构的OpenWrt SDK
echo "正在下载OpenWrt官方SDK..."
wget -q -O sdk.tar.xz $SDK_URL
mkdir -p $SDK_DIR
tar -xf sdk.tar.xz -C $SDK_DIR --strip-components=1
cd $SDK_DIR

# 2. 同步当前仓库的插件源码到SDK编译环境
echo "正在同步插件源码..."
cp -rf $GITHUB_WORKSPACE package/$PLUGIN_NAME
rm -rf package/$PLUGIN_NAME/.github  # 清理工作流冗余文件，避免编译干扰

# 3. 更新软件源
echo "正在更新官方软件源..."
./scripts/feeds update -a
./scripts/feeds install -a

# 4. 配置编译选项
echo "正在配置编译参数..."
echo "CONFIG_PACKAGE_$PLUGIN_NAME=y" > .config
make defconfig

# 5. 执行插件编译
echo "开始编译插件..."
make package/$PLUGIN_NAME/compile V=s -j$(nproc)

# 6. 整理编译产物
echo "正在整理编译产物..."
mkdir -p $GITHUB_WORKSPACE/output
cp -rf bin/packages/*/base/$PLUGIN_NAME*.ipk $GITHUB_WORKSPACE/output/

echo "======================"
echo "✅ 【坚果云插件】构建完成"
echo "ipk安装包已输出到output目录"
echo "======================"
