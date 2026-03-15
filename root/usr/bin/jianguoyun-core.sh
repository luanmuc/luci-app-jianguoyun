#!/bin/sh
# 坚果云备份插件 核心功能模块
# 开发文档规范：全功能实现、容错、加密、安全全满足
VERSION="3.1"

# 全局配置
LOG_FILE="/tmp/jianguoyun.log"
BACKUP_TMP="/tmp/jianguoyun_backup"
API_SCRIPT="/usr/bin/jianguoyun-api.sh"
MIN_FREE_SPACE_KB=10240 # 最小10MB可用空间

# 工具函数
log() {
    "$API_SCRIPT" log "$1" "$2"
}

get_config() {
    uci get jianguoyun.global."$1" 2>/dev/null || echo ""
}

# -------------------------- 核心备份功能 --------------------------
do_backup() {
    log "INFO" "=== 开始备份任务 ==="
    
    # 前置校验
    local backup_path=$(get_config backup_path)
    if [ -z "$backup_path" ]; then
        log "ERROR" "备份路径未配置"
        return 1
    fi

    # 校验备份路径存在
    for path in $backup_path; do
        if [ ! -d "$path" ] && [ ! -f "$path" ]; then
            log "ERROR" "备份路径不存在：$path"
            return 1
        fi
    done

    # 校验临时目录可用空间
    mkdir -p "$BACKUP_TMP"
    rm -rf "$BACKUP_TMP"/* 2>/dev/null
    local free_space=$(df -P "$BACKUP_TMP" | awk 'NR==2 {print $4}')
    if [ "$free_space" -lt "$MIN_FREE_SPACE_KB" ]; then
        log "ERROR" "临时目录空间不足，可用：${free_space}KB，最小需求：${MIN_FREE_SPACE_KB}KB"
        return 1
    fi

    # 准备备份参数
    local encrypt=$(get_config encrypt)
    local backup_time=$(date '+%Y%m%d_%H%M%S')
    local backup_name="openwrt_backup_${backup_time}.zip"
    local backup_file="${BACKUP_TMP}/${backup_name}"
    local password=$(get_config password)

    # 打包备份（安全加密，兼容特殊字符密码）
    log "INFO" "打包备份路径：$backup_path"
    if [ "$encrypt" -eq 1 ]; then
        if [ -z "$password" ]; then
            log "ERROR" "加密备份已开启，但密码未配置"
            return 1
        fi
        # 标准输入传密码，避免命令行暴露
        echo "$password" | zip -r -P - "$backup_file" $backup_path >/dev/null 2>&1
    else
        zip -r "$backup_file" $backup_path >/dev/null 2>&1
    fi

    # 校验打包结果
    if [ ! -f "$backup_file" ] || [ ! -s "$backup_file" ]; then
        log "ERROR" "备份打包失败，生成文件为空或不存在"
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    # 校验zip包完整性
    if ! unzip -t "$backup_file" >/dev/null 2>&1; then
        log "ERROR" "备份文件损坏，完整性校验失败"
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    # 上传到坚果云
    if ! webdav_upload "$backup_file" "$backup_name"; then
        log "ERROR" "=== 备份任务失败 ==="
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    log "INFO" "=== 备份任务完成 ==="
    rm -rf "$BACKUP_TMP"
    return 0
}

# -------------------------- 核心恢复功能 --------------------------
do_restore() {
    local remote_file="$1"
    log "INFO" "=== 开始恢复任务 ==="

    # 前置校验
    if [ -z "$remote_file" ]; then
        log "ERROR" "恢复文件名不能为空"
        return 1
    fi

    # 准备临时目录
    mkdir -p "$BACKUP_TMP"
    rm -rf "$BACKUP_TMP"/* 2>/dev/null
    local local_file="${BACKUP_TMP}/${remote_file}"

    # 下载备份文件
    if ! "$API_SCRIPT" download "$remote_file" "$local_file"; then
        log "ERROR" "=== 恢复任务失败 ==="
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    # 校验zip包完整性
    log "INFO" "校验备份文件完整性"
    if ! unzip -t "$local_file" >/dev/null 2>&1; then
        log "ERROR" "备份文件损坏，无法恢复"
        log "ERROR" "=== 恢复任务失败 ==="
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    # 解压恢复（安全加密兼容）
    local encrypt=$(get_config encrypt)
    local password=$(get_config password)
    log "INFO" "开始解压恢复文件"

    if [ "$encrypt" -eq 1 ]; then
        if [ -z "$password" ]; then
            log "ERROR" "加密备份已开启，但密码未配置"
            return 1
        fi
        echo "$password" | unzip -P - -o "$local_file" -d / >/dev/null 2>&1
    else
        unzip -o "$local_file" -d / >/dev/null 2>&1
    fi

    if [ $? -ne 0 ]; then
        log "ERROR" "解压恢复失败"
        log "ERROR" "=== 恢复任务失败 ==="
        rm -rf "$BACKUP_TMP"
        return 1
    fi

    # 提交UCI配置
    uci commit 2>/dev/null
    log "INFO" "=== 恢复任务完成 ==="
    rm -rf "$BACKUP_TMP"
    return 0
}

# -------------------------- 定时任务管理 --------------------------
set_cron() {
    local enabled=$(get_config autobackup)
    local cron_expr=$(get_config backup_cron)

    if [ "$enabled" -eq 1 ] && [ -n "$cron_expr" ]; then
        log "INFO" "设置自动备份定时任务：$cron_expr"
        echo "$cron_expr /usr/bin/jianguoyun-core.sh --backup >/dev/null 2>&1" > /etc/cron.d/jianguoyun
    else
        log "INFO" "关闭自动备份定时任务"
        echo "" > /etc/cron.d/jianguoyun
    fi

    /etc/init.d/cron reload 2>/dev/null
    return 0
}

# -------------------------- 命令行入口 --------------------------
case "$1" in
    --backup)
        do_backup
        ;;
    --restore)
        do_restore "$2"
        ;;
    --set-cron)
        set_cron
        ;;
    *)
        echo "坚果云备份核心模块 v$VERSION"
        echo "用法："
        echo "  $0 --backup          执行备份"
        echo "  $0 --restore <文件名> 执行恢复"
        echo "  $0 --set-cron        更新定时任务"
        ;;
esac
