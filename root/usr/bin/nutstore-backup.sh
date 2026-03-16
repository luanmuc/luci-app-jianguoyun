#!/bin/sh
# 坚果云备份核心脚本 V1.2.4_STABLE 修复版
# 全容错处理，无参数不会执行异常逻辑
set -e

# 全局配置
UCI_CONFIG="/etc/config/nutstore_backup"
BACKUP_FILE="/tmp/nutstore_backup.tar.gz"
LOG_FILE="/tmp/nutstore_backup.log"

# 备份配置函数
backup_config() {
    echo "【$(date "+%Y-%m-%d %H:%M:%S")】开始备份路由器配置" | tee "$LOG_FILE"
    if sysupgrade -b "$BACKUP_FILE"; then
        echo "【$(date "+%Y-%m-%d %H:%M:%S")】备份完成，备份文件：$BACKUP_FILE" | tee -a "$LOG_FILE"
    else
        echo "【$(date "+%Y-%m-%d %H:%M:%S")】备份失败" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# 恢复配置函数
restore_config() {
    local restore_file="$1"
    if [ -z "$restore_file" ] || [ ! -f "$restore_file" ]; then
        echo "错误：恢复文件不存在"
        exit 1
    fi
    echo "【$(date "+%Y-%m-%d %H:%M:%S")】开始恢复配置，恢复文件：$restore_file" | tee "$LOG_FILE"
    if sysupgrade -r "$restore_file"; then
        echo "【$(date "+%Y-%m-%d %H:%M:%S")】配置恢复完成" | tee -a "$LOG_FILE"
    else
        echo "【$(date "+%Y-%m-%d %H:%M:%S")】配置恢复失败" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# 主逻辑，参数校验
case "$1" in
    backup)
        backup_config
        ;;
    restore)
        restore_config "$2"
        ;;
    *)
        echo "用法："
        echo "  nutstore-backup.sh backup          备份路由器配置"
        echo "  nutstore-backup.sh restore [文件路径]  从指定文件恢复配置"
        exit 0
        ;;
esac
