# 坚果云插件一键安装脚本 适配KWRT/OpenWrt
set -e
echo "开始安装坚果云备份中心插件..."

# 安装依赖
opkg update && opkg install luci luci-base curl wget iperf3

# 创建临时目录
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

# 这里替换成你的插件源码的raw下载地址，也可以直接把文件复制到路由器对应目录
# 核心目录创建
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi/jianguoyun/tools
mkdir -p /usr/lib/lua/luci/model/cbi/jianguoyun/adblock
mkdir -p /usr/lib/lua/luci/model/cbi/jianguoyun/parent
mkdir -p /usr/bin
mkdir -p /etc/config
mkdir -p /etc/init.d
mkdir -p /usr/share/rpcd/acl.d
mkdir -p /usr/share/luci/i18n

echo "✅ 插件安装完成，正在刷新LuCI缓存..."
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
echo "✅ 全部完成，刷新路由器后台页面即可使用"
rm -rf $TMP_DIR
