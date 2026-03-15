#!/bin/bash
set -e

# ========== 固定构建逻辑（严禁修改） ==========
BUILD_DIR=$(mktemp -d)
mkdir -p "${BUILD_DIR}/CONTROL"
cp -r ./root/* "${BUILD_DIR}/"

# ========== 可修改区域（版本信息） ==========
cat > "${BUILD_DIR}/CONTROL/control" <<EOF
Package: luci-app-jianguoyun
Version: 3.1
Architecture: all
Section: luci
Priority: optional
Maintainer: luanmuc
Description: Jianguoyun Backup Plugin for OpenWrt
Depends: luci-base, curl, wget
Source: https://github.com/luanmuc/luci-app-jianguoyun
EOF

# ========== 固定权限与打包逻辑（不动） ==========
chmod 755 "${BUILD_DIR}/CONTROL"
find "${BUILD_DIR}" -type d -exec chmod 755 {} \;
find "${BUILD_DIR}" -name "*.sh" -exec chmod 755 {} \;
find "${BUILD_DIR}" -name "*.lua" -exec chmod 644 {} \;

# 关键替换：用 dpkg-deb 打包，Ubuntu 自带，永远不会缺依赖
mkdir -p output
dpkg-deb -b "${BUILD_DIR}" output/luci-app-jianguoyun_3.1_all.ipk
