#!/bin/sh
# 广告拦截中心功能脚本 V1.2.4_FULL_SYNC 最终版
set -e
UCI_CONFIG="/etc/config/nutstore_backup"
RULE_DIR="/etc/nutstore/adblock"
WHITELIST_FILE="$RULE_DIR/whitelist.txt"
RULE_FILE="$RULE_DIR/rules.txt"

load_rule_mode() {
    local mode=$1
    case $mode in
        home)
            RULE_URL="https://cdn.jsdelivr.net/gh/AdguardTeam/AdguardFilters/master/BaseFilter/filter.txt"
            echo "家用极简模式规则已加载"
            ;;
        child)
            RULE_URL="https://cdn.jsdelivr.net/gh/AdguardTeam/AdguardFilters/master/BaseFilter/filter.txt https://cdn.jsdelivr.net/gh/AdguardTeam/AdguardFilters/master/ParentalControl/filter.txt"
            echo "儿童防护模式规则已加载"
            ;;
        game)
            RULE_URL="https://cdn.jsdelivr.net/gh/AdguardTeam/AdguardFilters/master/MobileFilter/filter.txt"
            echo "游戏低延迟模式规则已加载"
            ;;
    esac
    uci set $UCI_CONFIG.adblock.rule_url="$RULE_URL"
    uci commit $UCI_CONFIG
}

update_rules() {
    mkdir -p $RULE_DIR
    local backup_file="/tmp/adblock_rules_backup.txt"
    cp $RULE_FILE $backup_file 2>/dev/null
    echo "开始更新拦截规则..."
    wget -q -O $RULE_FILE $RULE_URL
    if [ $? -ne 0 ]; then
        echo "规则更新失败，自动回滚上一版正常规则"
        cp $backup_file $RULE_FILE 2>/dev/null
        exit 1
    fi
    sort -u $RULE_FILE -o $RULE_FILE
    echo "规则更新完成，已自动去重"
    /etc/init.d/dnsmasq restart 2>/dev/null
}

add_whitelist() {
    mkdir -p $RULE_DIR
    local domain=$1
    echo "server=/$domain/#" >> $WHITELIST_FILE
    /etc/init.d/dnsmasq restart 2>/dev/null
    echo "已将 $domain 加入白名单，立即生效"
}

service_guard() {
    local enable=$(uci get $UCI_CONFIG.adblock.enable 2>/dev/null)
    if [ "$enable" = "1" ]; then
        if ! pgrep -f "dnsmasq" >/dev/null; then
            echo "DNS服务异常，自动重启"
            /etc/init.d/dnsmasq restart 2>/dev/null
        fi
    fi
}

case "$1" in
    load_mode) load_rule_mode $2 ;;
    update) update_rules ;;
    whitelist) add_whitelist $2 ;;
    guard) service_guard ;;
    *) echo "用法：nutstore-adblock.sh load_mode|update|whitelist|guard" ;;
esac
