#!/bin/bash
# 坚果云插件编译全链路校验脚本 V1.2.4_FULL_SYNC 最终版
# 适配纯命令打包场景，提前排查所有潜在问题
set -e

echo "======================"
echo "【坚果云插件】开始执行编译全链路校验"
echo "======================"

# 1. 校验核心编译文件
echo "正在校验核心打包脚本..."
if [ ! -f "$GITHUB_WORKSPACE/scripts/build.sh" ]; then
    echo "❌ 错误：核心build.sh打包脚本不存在，编译将直接中断"
    exit 1
else
    echo "✅ 核心build.sh打包脚本校验通过"
fi

# 2. 校验插件核心编译配置
echo "正在校验核心Makefile文件..."
if [ ! -f "$GITHUB_WORKSPACE/Makefile" ]; then
    echo "❌ 错误：根目录核心Makefile文件不存在"
    exit 1
else
    echo "✅ 核心Makefile文件校验通过"
fi

# 3. 校验插件核心目录完整性
echo "正在校验插件核心目录结构..."
REQUIRED_DIRS=("luasrc" "root" "files")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$GITHUB_WORKSPACE/$dir" ]; then
        echo "❌ 错误：核心目录$dir不存在，功能将缺失"
        exit 1
    else
        echo "✅ 核心目录$dir校验通过"
    fi
done

# 4. 校验核心功能脚本完整性
echo "正在校验核心功能脚本..."
REQUIRED_SCRIPTS=("nutstore-backup.sh" "nutstore-tools-optimize.sh" "nutstore-adblock.sh" "nutstore-parent.sh")
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ ! -f "$GITHUB_WORKSPACE/root/usr/bin/$script" ]; then
        echo "⚠️  警告：核心功能脚本$script不存在，对应功能将异常"
    else
        echo "✅ 核心功能脚本$script校验通过"
    fi
done

# 5. 校验服务与权限文件
echo "正在校验服务与权限文件..."
if [ ! -f "$GITHUB_WORKSPACE/root/etc/init.d/nutstore-optimize-guard" ]; then
    echo "⚠️  警告：服务守护进程文件不存在，插件自启动功能将异常"
else
    echo "✅ 服务守护进程文件校验通过"
fi

if [ ! -f "$GITHUB_WORKSPACE/root/usr/share/rpcd/acl.d/luci-app-jianguoyun.json" ]; then
    echo "⚠️  警告：LuCI权限文件不存在，Web界面操作将异常"
else
    echo "✅ LuCI权限文件校验通过"
fi

# 6. 校验默认配置文件
echo "正在校验默认配置文件..."
if [ ! -f "$GITHUB_WORKSPACE/root/etc/config/nutstore_backup" ]; then
    echo "❌ 错误：插件默认配置文件不存在"
    exit 1
else
    echo "✅ 插件默认配置文件校验通过"
fi

echo "======================"
echo "✅ 【坚果云插件】全链路校验全部通过，可正常编译打包"
echo "======================"
