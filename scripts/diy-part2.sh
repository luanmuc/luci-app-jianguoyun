#!/bin/bash
# 坚果云插件云编译后置脚本 V1.2.4_FULL_SYNC 最终版
# 100%适配现有build.yml配置，严格遵守不修改工作流主线铁律
set -e

echo "======================"
echo "【坚果云插件】开始执行后置自定义脚本"
echo "======================"

# 1. 校验插件编译结果
echo "正在校验插件编译结果..."
PLUGIN_IPK=$(find ./bin -name "luci-app-jianguoyun_*.ipk" | head -1)
if [ -f "$PLUGIN_IPK" ]; then
    echo "✅ 坚果云插件编译成功，生成安装包：$(basename $PLUGIN_IPK)"
else
    echo "❌ 错误：坚果云插件编译失败，请检查源码完整性"
    exit 1
fi

# 2. 预配置CMCC A10专属网络优化参数
echo "正在配置CMCC A10专属系统优化..."
echo "net.core.default_qdisc=fq" >> ./package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> ./package/base-files/files/etc/sysctl.conf

# 3. 预配置固件默认参数
echo "正在预配置固件默认参数..."
sed -i 's/192.168.1.1/192.168.10.1/g' ./package/base-files/files/bin/config_generate
sed -i 's/OpenWrt/CMCC-A10/g' ./package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 4. 清理编译临时文件
echo "正在清理编译临时文件..."
rm -rf ./tmp/*

echo "======================"
echo "【坚果云插件】后置脚本执行完成"
echo "======================"
