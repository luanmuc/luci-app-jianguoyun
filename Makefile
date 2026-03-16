# 坚果云备份插件 V1.2.4_FULL_SYNC 最终版 核心编译配置
# 全架构通用纯脚本插件，与打包版核心代码100%同步
include $(TOPDIR)/rules.mk

# 单源唯一版本号，禁止随意修改
PKG_NAME:=luci-app-jianguoyun
PKG_VERSION:=1.2.4
PKG_RELEASE:=FULL_SYNC
PKG_ARCH:=all

PKG_MAINTAINER:=坚果云备份中心
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-jianguoyun
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI app for 坚果云备份中心
  DEPENDS:=+luci +luci-base +PACKAGE_curl:curl +PACKAGE_wget:wget +PACKAGE_iperf3:iperf3
  PKGARCH:=all
endef

define Package/luci-app-jianguoyun/description
  坚果云备份中心全功能插件，全架构通用，支持路由器配置备份、优化工具箱、广告拦截、家长控制
endef

# 纯脚本插件无需交叉编译
define Build/Compile
endef

# 安装规则，与打包脚本逻辑100%完全对齐
define Package/luci-app-jianguoyun/install
	# 1. 安装LuCI菜单与页面文件
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/tools
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/adblock
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/parent
	$(INSTALL_DATA) ./luasrc/model/cbi/jianguoyun/*.lua $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/
	$(INSTALL_DATA) ./luasrc/model/cbi/jianguoyun/tools/*.lua $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/tools/
	$(INSTALL_DATA) ./luasrc/model/cbi/jianguoyun/adblock/*.lua $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/adblock/
	$(INSTALL_DATA) ./luasrc/model/cbi/jianguoyun/parent/*.lua $(1)/usr/lib/lua/luci/model/cbi/jianguoyun/parent/
	
	# 2. 安装路由器系统文件，权限与打包版完全一致
	$(CP) ./root/* $(1)/
	chmod 755 $(1)/usr/bin/*.sh
	chmod 755 $(1)/etc/init.d/*
	
	# 3. 安装LuCI ACL权限文件
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/
	
	# 4. 安装中文翻译文件
	$(INSTALL_DIR) $(1)/usr/share/luci/i18n
	$(INSTALL_DATA) ./files/po/zh-cn/*.lmo $(1)/usr/share/luci/i18n/
endef

# 安装后钩子，与打包版逻辑100%完全对齐
define Package/luci-app-jianguoyun/postinst
#!/bin/sh
set -e
# 安装前备份用户原有配置，重装不丢配置
if [ -f "$${IPKG_INSTROOT}/etc/config/nutstore_backup" ]; then
	cp -f "$${IPKG_INSTROOT}/etc/config/nutstore_backup" "/tmp/luci-app-jianguoyun_config_backup.tar.gz"
fi
# 启用并启动守护进程，与打包版行为完全一致
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/nutstore-optimize-guard enable
	/etc/init.d/nutstore-optimize-guard restart 2>/dev/null
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

# 卸载前钩子，与打包版逻辑100%完全对齐
define Package/luci-app-jianguoyun/prerm
#!/bin/sh
set -e
# 卸载前停止并禁用守护进程，无残留进程
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/nutstore-optimize-guard stop 2>/dev/null
	/etc/init.d/nutstore-optimize-guard disable 2>/dev/null
fi
# 卸载前备份用户配置，重装可恢复
if [ -f "$${IPKG_INSTROOT}/etc/config/nutstore_backup" ]; then
	cp -f "$${IPKG_INSTROOT}/etc/config/nutstore_backup" "/tmp/luci-app-jianguoyun_config_backup.tar.gz"
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-jianguoyun))
