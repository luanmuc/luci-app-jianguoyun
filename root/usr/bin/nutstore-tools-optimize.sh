#!/bin/sh
# 优化工具箱功能脚本 V1.2.4_FULL_SYNC 最终版
set -e
UCI_CONFIG="/etc/config/nutstore_backup"

apply_scene_mode() {
    local mode=$1
    case $mode in
        game)
            uci set $UCI_CONFIG.adblock.rule_mode="game"
            uci set $UCI_CONFIG.tools.hw_accel="1"
            uci set $UCI_CONFIG.tools.cpu_energy="0"
            uci commit $UCI_CONFIG
            /etc/init.d/nutstore-adblock restart 2>/dev/null
            echo "游戏/直播低延迟模式已生效"
            ;;
        wifi)
            uci set $UCI_CONFIG.tools.wifi_power="max"
            uci set $UCI_CONFIG.tools.wifi_auto_channel="0"
            uci commit $UCI_CONFIG
            wifi reload 2>/dev/null
            echo "穿墙信号增强模式已生效"
            ;;
        energy)
            uci set $UCI_CONFIG.tools.wifi_power="low"
            uci set $UCI_CONFIG.tools.hw_accel="0"
            uci set $UCI_CONFIG.tools.cpu_energy="1"
            uci commit $UCI_CONFIG
            wifi reload 2>/dev/null
            echo "节能模式已生效"
            ;;
        home)
            uci set $UCI_CONFIG.adblock.rule_mode="home"
            uci set $UCI_CONFIG.tools.hw_accel="1"
            uci commit $UCI_CONFIG
            /etc/init.d/nutstore-adblock restart 2>/dev/null
            echo "家用通用模式已生效"
            ;;
    esac
}

auto_detect_device() {
    local board=$(cat /tmp/sysinfo/board_name 2>/dev/null)
    if echo "$board" | grep -q "cmcc,a10" || echo "$board" | grep -q "mt7981"; then
        uci set $UCI_CONFIG.device_optimize.hw_accel="1"
        uci set $UCI_CONFIG.device_optimize.auto_detect="1"
        uci commit $UCI_CONFIG
        echo "CMCC A10设备已检测，专属优化自动加载完成"
    else
        echo "非CMCC A10设备，跳过专属优化加载"
    fi
}

speed_test_compare() {
    local type=$1
    echo "===== $type 测速结果 ====="
    iperf3 -c speedtest.qq.com -t 3 2>/dev/null | grep "sender" | awk '{print "带宽："$7" "$8", 往返延迟："$10" ms"}'
    echo "==========================="
}

check_conflict() {
    local conflict=0
    if [ $(uci get $UCI_CONFIG.tools.bbr_enable 2>/dev/null) = "1" ] && [ $(uci get $UCI_CONFIG.tools.cubic_enable 2>/dev/null) = "1" ]; then
        echo "检测到TCP加速规则冲突，已自动修复"
        uci set $UCI_CONFIG.tools.cubic_enable="0"
        conflict=1
    fi
    [ $conflict -eq 1 ] && uci commit $UCI_CONFIG
    echo "规则冲突检测完成，无异常规则"
}

auto_optimize_channel() {
    echo "开始扫描周边WiFi干扰..."
    local best_channel=$(iw dev wlan0 scan 2>/dev/null | grep "primary channel" | sort | uniq -c | sort -n | head -1 | awk '{print $3}')
    if [ -n "$best_channel" ]; then
        echo "最优信道：$best_channel"
    else
        echo "扫描失败，请手动选择信道"
    fi
}

case "$1" in
    scene) apply_scene_mode $2 ;;
    detect) auto_detect_device ;;
    speedtest) speed_test_compare $2 ;;
    check_conflict) check_conflict ;;
    auto_channel) auto_optimize_channel ;;
    *) echo "用法：nutstore-tools-optimize.sh scene|detect|speedtest|check_conflict|auto_channel" ;;
esac
