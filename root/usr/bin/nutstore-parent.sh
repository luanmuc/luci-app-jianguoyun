#!/bin/sh
# 家长控制中心功能脚本 V1.2.4_FULL_SYNC 最终版
set -e
UCI_CONFIG="/etc/config/nutstore_backup"
WHITELIST_DIR="/etc/nutstore/parent"

load_control_mode() {
    local mode=$1
    local temp_time=$2
    case $mode in
        study)
            uci set $UCI_CONFIG.parent.mode="study"
            uci set $UCI_CONFIG.parent.allow_list="钉钉 腾讯课堂 学而思 国家中小学智慧教育平台"
            uci set $UCI_CONFIG.parent.block_list="游戏 视频 社交 直播"
            uci commit $UCI_CONFIG
            echo "网课学习模式已生效"
            ;;
        holiday)
            uci set $UCI_CONFIG.parent.mode="holiday"
            uci set $UCI_CONFIG.parent.daily_limit="2h"
            uci commit $UCI_CONFIG
            echo "假期娱乐模式已生效"
            ;;
        temp)
            uci set $UCI_CONFIG.parent.temp_pass="$temp_time"
            uci commit $UCI_CONFIG
            echo "临时放行 $temp_time 小时已生效"
            ;;
        full)
            uci set $UCI_CONFIG.parent.mode="whitelist_only"
            uci commit $UCI_CONFIG
            echo "全管控模式已生效，仅白名单可访问"
            ;;
    esac
}

set_cycle_time() {
    local weekday_time=$1
    local weekend_time=$2
    uci set $UCI_CONFIG.parent.weekday_time="$weekday_time"
    uci set $UCI_CONFIG.parent.weekend_time="$weekend_time"
    uci commit $UCI_CONFIG
    echo "循环时段管控规则已设置完成"
}

generate_weekly_report() {
    echo "===== 上网行为周报 ====="
    echo "统计周期：$(date -d "7 days ago" +%Y-%m-%d) 至 $(date +%Y-%m-%d)"
    echo "-------------------------"
    grep "PARENT_CONTROL" /var/log/messages 2>/dev/null | awk '{print $8}' | sort | uniq -c | sort -rn | head -10
    echo "=========================="
}

import_online_class_whitelist() {
    mkdir -p $WHITELIST_DIR
    cat > $WHITELIST_DIR/online_class_whitelist.txt << 'EOF'
# 钉钉
.dingtalk.com
.alicdn.com
# 腾讯课堂
.ke.qq.com
.tencent.com
# 学而思
.xueersi.com
# 国家中小学智慧教育平台
.zxx.edu.cn
EOF
    echo "主流网课平台白名单已一键导入完成"
}

admin_whitelist_check() {
    local admin_ip=$(uci get $UCI_CONFIG.parent.admin_ip 2>/dev/null)
    if [ -n "$admin_ip" ]; then
        iptables -I INPUT -s $admin_ip -j ACCEPT 2>/dev/null
        iptables -I FORWARD -s $admin_ip -j ACCEPT 2>/dev/null
    fi
}

service_guard() {
    local enable=$(uci get $UCI_CONFIG.parent.enable 2>/dev/null)
    if [ "$enable" = "1" ]; then
        admin_whitelist_check
    fi
}

case "$1" in
    load_mode) load_control_mode $2 $3 ;;
    set_time) set_cycle_time "$2" "$3" ;;
    report) generate_weekly_report ;;
    import_class) import_online_class_whitelist ;;
    admin_check) admin_whitelist_check ;;
    guard) service_guard ;;
    *) echo "用法：nutstore-parent.sh load_mode|set_time|report|import_class|admin_check|guard" ;;
esac
