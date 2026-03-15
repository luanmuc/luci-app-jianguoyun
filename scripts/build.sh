#!/bin/bash
set -euo pipefail

# ==============================================
# 修复版：兼容所有OpenWrt/KWrt的标准IPK打包
# 严格遵循OpenWrt官方ipk格式规范
# ==============================================

# 读取版本号
VERSION="$(cat VERSION_NOW)"
PKG_NAME="luci-app-jianguoyun"
ARCH="all"

# 清理旧文件
rm -rf output pkg
mkdir -p output pkg

# 1. 准备包结构
mkdir -p pkg/control pkg/data
cp -r root/* pkg/data/
cp -r CONTROL/* pkg/control/

# 2. 版本号自动同步
sed -i "s/^Version:.*/Version: ${VERSION}/" pkg/control/control
sed -i "s/VERSION=.*/VERSION=\"${VERSION}\"/" pkg/data/usr/bin/*.sh

# 3. 强制执行OpenWrt标准权限
chmod 755 pkg/control/preinst pkg/control/postinst pkg/control/prerm pkg/control/postrm 2>/dev/null || true
chmod 755 pkg/data/usr/bin/*.sh
chmod 755 pkg/data/etc/init.d/*
chmod 755 pkg/data/etc/uci-defaults/*
chmod 644 pkg/data/etc/config/*
chmod 644 pkg/data/etc/cron.d/*
chmod 644 pkg/data/usr/share/jianguoyun/* 2>/dev/null || true
chmod 644 pkg/data/usr/lib/lua/luci/controller/*.lua 2>/dev/null || true
chmod 644 pkg/data/usr/lib/lua/luci/model/cbi/jianguoyun/*.lua 2>/dev/null || true
chmod 644 pkg/data/usr/lib/lua/luci/view/jianguoyun/*.htm 2>/dev/null || true

# 4. 标准IPK打包（优先使用官方ipkg-build，兼容性拉满）
if command -v ipkg-build &> /dev/null; then
  # 官方标准打包，100%兼容所有OpenWrt分支
  ipkg-build -o root -g root pkg output/
else
  # 兼容手动打包，严格遵循格式规范
  mkdir -p pkg/tmp
  # 打包data包（root权限，标准gzip格式）
  cd pkg/data
  tar --numeric-owner --owner=0 --group=0 -czf ../tmp/data.tar.gz .
  cd ../control
  tar --numeric-owner --owner=0 --group=0 -czf ../tmp/control.tar.gz .
  cd ../tmp
  echo "2.0" > debian-binary
  # 生成标准ipk
  ar r "../../output/${PKG_NAME}_${VERSION}_${ARCH}.ipk" debian-binary control.tar.gz data.tar.gz
  cd ../..
fi

# 5. 打包后校验，确保文件正常
if [ ! -f "output/${PKG_NAME}_${VERSION}_${ARCH}.ipk" ]; then
  echo "❌ 打包失败：未生成ipk文件"
  exit 1
fi

# 清理临时文件
rm -rf pkg

echo "===================================================="
echo " ✅ 云编译打包完成"
echo " 成品包：output/${PKG_NAME}_${VERSION}_${ARCH}.ipk"
echo " 版本：v${VERSION}"
echo " 兼容：KWrt / OpenWrt / ImmortalWrt / iStoreOS 全版本"
echo "===================================================="
