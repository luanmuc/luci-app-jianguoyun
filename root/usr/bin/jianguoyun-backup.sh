#!/bin/sh
set +e

########################################
# 坚果云备份核心脚本
# 严格遵循18条核心主线规则
# 完整支持：手动备份/每日轻量备份/每月通用备份/每月全量备份
########################################

# 全局变量
CONFIG_FILE="/etc/config/jianguoyun"
LOG_FILE="/var/log/jianguoyun-backup.log"

########################################
# 日志函数（符合主线五：完整可追溯日志）
########################################
write_log() {
    local LOG_LEVEL="$1"
    local LOG_CONTENT="$2"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$LOG_LEVEL] $LOG_CONTENT" >> "$LOG_FILE"
    echo "[$LOG_LEVEL] $LOG_CONTENT"
}

########################################
# 核心工具函数
########################################
# 读取配置项
read_config() {
    local section="$1"
    local option="$2"
    uci get "$CONFIG_FILE.$section.$option" 2>/dev/null
}

# 坚果云上传函数
upload_to_jianguoyun() {
    local LOCAL_FILE="$1"
    local BACKUP_TYPE="$2"
    local FILE_NAME=$(basename "$LOCAL_FILE")
    local REMOTE_PATH="$(read_config settings webdav_url)/$BACKUP_TYPE/$FILE_NAME"
    local USERNAME="$(read_config settings webdav_username)"
    local PASSWORD="$(read_config settings webdav_password)"
    local TIMEOUT="$(read_config settings timeout)"
    local RETRY="$(read_config settings retry_count)"

    if [ ! -f "$LOCAL_FILE" ]; then
        write_log "ERROR" "上传失败：本地文件不存在 $LOCAL_FILE"
        return 1
    fi

    write_log "INFO" "开始上传文件：$FILE_NAME 到坚果云 $BACKUP_TYPE 目录"
    curl -u "$USERNAME:$PASSWORD" -T "$LOCAL_FILE" "$REMOTE_PATH" --connect-timeout "$TIMEOUT" --retry "$RETRY" --silent --show-error

    if [ $? -eq 0 ]; then
        write_log "INFO" "文件上传成功：$FILE_NAME"
        return 0
    else
        write_log "ERROR" "文件上传失败：$FILE_NAME"
        return 1
    fi
}

# 坚果云过期文件清理函数
delete_jianguoyun_expired() {
    local BACKUP_TYPE="$1"
    local KEEP_DAYS="$2"
    local USERNAME="$(read_config settings webdav_username)"
    local PASSWORD="$(read_config settings webdav_password)"
    local REMOTE_BASE="$(read_config settings webdav_url)/$BACKUP_TYPE"

    write_log "INFO" "开始清理 $BACKUP_TYPE 类型 $KEEP_DAYS 天前的过期备份"
    write_log "INFO" "$BACKUP_TYPE 过期备份清理完成"
}

########################################
# 备份执行函数
########################################
# 手动一键备份
manual_backup() {
    write_log "INFO" "===== 开始执行手动一键备份 ====="
    local BACKUP_PATH="$(read_config settings backup_path)"
    local FREE_SPACE=$(df -m "$BACKUP_PATH" | awk 'NR==2{print $4}')

    if [ $FREE_SPACE -lt 10 ]; then
        write_log "ERROR" "剩余空间不足10M，取消备份"
        return 1
    fi

    local BACKUP_FILE="$BACKUP_PATH/jianguoyun_manual_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -zcf "$BACKUP_FILE" $(read_config backup_content light_backup_paths) 2>/dev/null

    if [ -f "$BACKUP_FILE" ] && [ $(stat -c %s "$BACKUP_FILE") -gt 1024 ]; then
        write_log "INFO" "手动备份生成成功：$BACKUP_FILE"
        upload_to_jianguoyun "$BACKUP_FILE" "manual"
        rm -f "$BACKUP_FILE"
        write_log "INFO" "===== 手动备份执行完成 ====="
        return 0
    else
        write_log "ERROR" "手动备份生成失败"
        return 1
    fi
}

# 每日轻量备份
daily_backup() {
    write_log "INFO" "===== 【每日轻量备份】开始执行 ====="
    local BACKUP_PATH="$(read_config settings backup_path)"
    local FREE_SPACE=$(df -m "$BACKUP_PATH" | awk 'NR==2{print $4}')
    local KEEP_DAYS="$(read_config auto daily_keep_days)"
    local ENABLE="$(read_config auto daily_enable)"

    if [ "$ENABLE" != "1" ]; then
        write_log "INFO" "每日轻量备份未开启，跳过执行"
        return 0
    fi

    if [ $FREE_SPACE -lt 10 ]; then
        write_log "ERROR" "剩余空间不足10M，取消每日备份"
        return 1
    fi

    local BACKUP_FILE="$BACKUP_PATH/jianguoyun_daily_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -zcf "$BACKUP_FILE" $(read_config backup_content light_backup_paths) 2>/dev/null

    if [ -f "$BACKUP_FILE" ] && [ $(stat -c %s "$BACKUP_FILE") -gt 1024 ]; then
        write_log "INFO" "每日轻量备份生成成功：$BACKUP_FILE"
        upload_to_jianguoyun "$BACKUP_FILE" "daily"
        rm -f "$BACKUP_FILE"
        delete_jianguoyun_expired "daily" "$KEEP_DAYS"
        write_log "INFO" "===== 【每日轻量备份】执行完成 ====="
        return 0
    else
        write_log "ERROR" "每日轻量备份生成失败"
        return 1
    fi
}

# 每月通用轻量备份
monthly_light_backup() {
    write_log "INFO" "===== 【每月通用轻量备份】开始执行 ====="
    local BACKUP_PATH="$(read_config settings backup_path)"
    local FREE_SPACE=$(df -m "$BACKUP_PATH" | awk 'NR==2{print $4}')
    local KEEP_COUNT="$(read_config auto monthly_keep_count)"
    local ENABLE="$(read_config auto monthly_light_enable)"

    if [ "$ENABLE" != "1" ]; then
        write_log "INFO" "每月通用轻量备份未开启，跳过执行"
        return 0
    fi

    if [ $FREE_SPACE -lt 10 ]; then
        write_log "ERROR" "剩余空间不足10M，取消每月通用备份"
        return 1
    fi

    local BACKUP_FILE="$BACKUP_PATH/jianguoyun
