#!/bin/sh
# 坚果云备份核心脚本 V1.2.4_FULL_SYNC 最终版
set -e
backup_config() {
    echo "【坚果云备份】开始备份路由器配置"
    sysupgrade -b /tmp/nutstore_backup.tar.gz
    echo "【坚果云备份】备份完成"
    echo "$(date "+%Y-%m-%d %H:%M:%S") 备份完成" > /tmp/nutstore_backup.log
}
restore_config() {
    echo "【坚果云备份】开始恢复配置"
    sysupgrade -r $1
    echo "【坚果云备份】恢复完成"
    echo "$(date "+%Y-%m-%d %H:%M:%S") 配置恢复完成" > /tmp/nutstore_backup.log
}
case "$1" in
    backup) backup_config ;;
    restore) restore_config $2 ;;
    *) echo "用法：nutstore-backup.sh backup|restore [备份文件路径]" ;;
esac
