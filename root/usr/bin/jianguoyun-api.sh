#!/bin/sh
# 坚果云备份插件 API对接模块
# 开发文档规范：容错、日志、加密、安全全满足
VERSION="3.1"

# 全局配置（符合开发文档：重启清空，内存存储）
LOG_FILE="/tmp/jianguoyun.log"
CONFIG_FILE="/etc/config/jianguoyun"
MAX_LOG_COUNT=3

# -------------------------- 核心工具函数 --------------------------
# 日志函数（严格符合开发文档：最多保留3次操作，重启清空）
log() {
    local level="$1"
    local msg="$2"
    local log_time="$(date '+%Y-%m-%d %H:%M:%S')"
    local log_line="[$log_time] [$level] $msg"

    # 确保日志文件存在
    touch "$LOG_FILE"

    # 按操作次数轮转，严格保留最近3次完整操作
    if [ "$level" = "INFO" ] && (echo "$msg" | grep -qE "=== (开始|完成) ==="); then
        local current_count=$(grep -c "=== 开始 ===" "$LOG_FILE")
        if [ "$current_count" -ge "$MAX_LOG_COUNT" ]; then
            # 移除最早的一次操作日志
            sed -i '1,/=== 完成 ===/d' "$LOG_FILE"
        fi
    fi

    # 写入日志+控制台输出
    echo "$log_line" >> "$LOG_FILE"
    echo "$log_line"
}

# 读取UCI配置
get_config() {
    local key="$1"
    uci get jianguoyun.global."$key" 2>/dev/null || echo ""
}

# 配置合法性校验
validate_config() {
    local dav_url=$(get_config webdav_url)
    local username=$(get_config username)
    local password=$(get_config password)

    if [ -z "$dav_url" ] || [ -z "$username" ] || [ -z "$password" ]; then
        log "ERROR" "坚果云WebDAV配置不完整，请检查账号、密码、地址"
        return 1
    fi

    # 补全URL结尾斜杠
    dav_url="${dav_url%/}/"
    echo "$dav_url"
    return 0
}

# -------------------------- WebDAV核心接口 --------------------------
# 坚果云文件上传
webdav_upload() {
    local local_file="$1"
    local remote_file="$2"

    # 前置校验
    if [ ! -f "$local_file" ]; then
        log "ERROR" "上传失败：本地文件不存在 $local_file"
        return 1
    fi

    local dav_url
    if ! dav_url=$(validate_config); then
        return 1
    fi

    local remote_url="${dav_url}${remote_file}"
    local username=$(get_config username)
    local password=$(get_config password)

    log "INFO" "开始上传：$local_file -> $remote_file"
    
    # 安全上传：强制SSL校验、失败重试、HTTP错误捕获
    if curl --fail -s -u "$username:$password" -T "$local_file" "$remote_url" \
        --connect-timeout 10 --max-time 300 --retry 3 --retry-delay 2; then
        log "INFO" "上传成功：$remote_file"
        return 0
    else
        log "ERROR" "上传失败：$remote_file (HTTP请求错误)"
        return 1
    fi
}

# 坚果云文件下载
webdav_download() {
    local remote_file="$1"
    local local_file="$2"

    local dav_url
    if ! dav_url=$(validate_config); then
        return 1
    fi

    local remote_url="${dav_url}${remote_file}"
    local username=$(get_config username)
    local password=$(get_config password)

    log "INFO" "开始下载：$remote_url -> $local_file"
    
    # 安全下载
    if curl --fail -s -u "$username:$password" -o "$local_file" "$remote_url" \
        --connect-timeout 10 --max-time 300 --retry 3 --retry-delay 2; then
        if [ -f "$local_file" ] && [ -s "$local_file" ]; then
            log "INFO" "下载成功：$local_file"
            return 0
        else
            log "ERROR" "下载失败：文件为空 $local_file"
            rm -rf "$local_file" 2>/dev/null
            return 1
        fi
    else
        log "ERROR" "下载失败：$remote_file (HTTP请求错误)"
        rm -rf "$local_file" 2>/dev/null
        return 1
    fi
}

# -------------------------- 命令行入口 --------------------------
case "$1" in
    upload)
        webdav_upload "$2" "$3"
        ;;
    download)
        webdav_download "$2" "$3"
        ;;
    log)
        log "$2" "$3"
        ;;
    *)
        echo "坚果云API模块 v$VERSION"
        echo "用法："
        echo "  $0 upload <本地文件> <远程文件名>"
        echo "  $0 download <远程文件名> <本地文件>"
        ;;
esac
