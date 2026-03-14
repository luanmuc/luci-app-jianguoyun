include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-jianguoyun
PKG_VERSION:=1.1.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=自动打包

LUCI_TITLE:=LuCI support for Jianguoyun Backup
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+curl +wget +luci-base

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
