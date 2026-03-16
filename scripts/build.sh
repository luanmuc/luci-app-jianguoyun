#!/bin/bash
# 坚果云插件 纯命令打包脚本 V1.2.4_FULL_SYNC 最终版
# 纯shell+lua脚本插件专用，全架构通用，不拉取SDK，零依赖极速打包
set -e

# 基础配置（与Makefile版本完全同步，禁止随意修改）
export PKG_NAME="luci-app-jianguoyun"
export PKG_VERSION="1.2.4"
export PKG_RELEASE="FULL_SYNC"
export PKG_ARCH="all"
export OUTPUT_DIR="$GITHUB_WORKSPACE/output"
export BUILD_TMP_DIR="$GITHUB_WORKSPACE/build_tmp"

echo "======================"
echo "【坚果云插件】开始纯命令打包"
echo "======================"

# 1. 清理旧的打包环境
echo "正在清理旧打包环境..."
rm -rf $BUILD_TMP_DIR $OUTPUT_DIR
mkdir -p $BUILD_TMP_DIR $OUTPUT_DIR

# 2. 创建ipk标准目录结构
echo "正在创建ipk标准目录结构..."
mkdir -p $BUILD_TMP_DIR/CONTROL
mkdir -p $BUILD_TMP_DIR/usr/lib/lua/luci
mkdir -p $BUILD_TMP_DIR/usr/share/rpcd/acl.d
mkdir -p $BUILD_TMP_DIR/usr/share/luci/i18n
mkdir -p $BUILD_TMP_DIR/usr/bin
mkdir -p $BUILD_TMP_DIR/etc/config
mkdir -p $BUILD_TMP_DIR/etc/init.d

# 3. 复制插件文件到打包目录（与Makefile安装逻辑100%同步）
echo "正在同步插件核心文件..."
# 复制LuCI菜单与页面文件
cp -rf $GITHUB_WORKSPACE/luasrc/* $BUILD_TMP_DIR/usr/lib/lua/luci/
# 复制系统文件、脚本、配置、服务
cp -rf $GITHUB_WORKSPACE/root/* $BUILD_TMP_DIR/
# 复制翻译文件
cp -f $GITHUB_WORKSPACE/files/po/zh-cn/*.lmo $BUILD_TMP_DIR/usr/share/luci/i18n/ 2>/dev/null || true

# 4. 设置文件权限（与OpenWrt标准权限完全一致）
echo "正在设置文件权限..."
chmod 755 $BUILD_TMP_DIR/usr/bin/*.sh
chmod 755 $BUILD_TMP_DIR/etc/init.d/*

# 5. 生成ipk控制文件（CONTROL目录，OpenWrt官方标准）
echo "正在生成ipk控制文件..."
# 生成control核心控制文件
cat > $BUILD_TMP_DIR/CONTROL/control << EOF
Package: $PKG_NAME
Version: $PKG_VERSION-$PKG_RELEASE
Architecture: $PKG_ARCH
Priority: optional
Section: luci
Maintainer: 坚果云备份中心
License: GPL-3.0
Description: 坚果云备份中心全功能插件，全架构通用，支持路由器配置备份、优化工具箱、广告拦截、家长控制
Depends: +luci +luci-base +curl +wget +iperf3
EOF

# 生成postinst安装后钩子（与Makefile逻辑100%同步）
cat > $BUILD_TMP_DIR/CONTROL/postinst << 'EOF'
#!/bin/sh
set -e
# 安装前备份用户原有配置，重装不丢配置
if [ -f "${IPKG_INSTROOT}/etc/config/nutstore_backup" ]; then
	cp -f "${IPKG_INSTROOT}/etc/config/nutstore_backup" "/tmp/luci-app-jianguoyun_config_backup.tar.gz"
fi
# 启用并启动守护进程，刷新LuCI缓存
if [ -z "${IPKG_INSTROOT}" ]; then
	/etc/init.d/nutstore-optimize-guard enable
	/etc/init.d/nutstore-optimize-guard restart 2>/dev/null
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
EOF
chmod 755 $BUILD_TMP_DIR/CONTROL/postinst

# 生成prerm卸载前钩子（与Makefile逻辑100%同步）
cat > $BUILD_TMP_DIR/CONTROL/prerm << 'EOF'
#!/bin/sh
set -e
# 卸载前停止并禁用守护进程，无残留
if [ -z "${IPKG_INSTROOT}" ]; then
	/etc/init.d/nutstore-optimize-guard stop 2>/dev/null
	/etc/init.d/nutstore-optimize-guard disable 2>/dev/null
fi
# 卸载前备份用户配置，重装可恢复
if [ -f "${IPKG_INSTROOT}/etc/config/nutstore_backup" ]; then
	cp -f "${IPKG_INSTROOT}/etc/config/nutstore_backup" "/tmp/luci-app-jianguoyun_config_backup.tar.gz"
fi
exit 0
EOF
chmod 755 $BUILD_TMP_DIR/CONTROL/prerm

# 6. 打包生成ipk安装包
echo "正在生成ipk安装包..."
IPK_FILE_NAME="${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}.ipk"
cd $BUILD_TMP_DIR
tar -czf control.tar.gz ./CONTROL --owner=0 --group=0
tar -czf data.tar.gz ./usr ./etc --owner=0 --group=0
echo "2.0" > debian-binary
tar -czf $OUTPUT_DIR/$IPK_FILE_NAME ./debian-binary ./data.tar.gz ./control.tar.gz --owner=0 --group=0

# 7. 清理临时文件
echo "正在清理临时文件..."
rm -rf $BUILD_TMP_DIR

echo "======================"
echo "✅ 【坚果云插件】纯命令打包完成"
echo "生成安装包：$IPK_FILE_NAME"
echo "安装包已输出到output目录"
echo "======================"
