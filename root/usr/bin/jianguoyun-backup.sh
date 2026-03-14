#!/bin/sh
set -eo pipefail

#########################################################################
# 【砍掉的优化全合并】全局三重重试容错函数（所有操作自动生效）
#########################################################################
retry() {
  local max_try=3
  local interval=2
  local count=0
  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ $count -lt $max_try ]; then
      echo "⚠️  操作失败，${interval}秒后重试第${count}次 | 命令：$*"
      sleep $interval
    else
      echo "❌  操作失败，已重试${max_try}次，退出码：${exit_code} | 命令：$*"
      return $exit_code
    fi
  done
  echo "✅ 操作成功 | 命令：$*"
  return 0
}

#########################################################################
# 全局配置
#########################################################################
CONFIG_FILE="/etc/config/jianguoyun"
DEFAULT_TIMEOUT=30
DEFAULT_RETRY_COUNT=3
DEFAULT_BACKUP_PATH="/tmp/upload"
DEFAULT_KEEP_COUNT=30
DEFAULT_AUTO_CYCLE=7
LOG_FILE="/var/log/jianguoyun-backup.log"

# 自动修复Windows换行符，避免脚本运行报错
sed -i 's/\r$//' "$0" 2>/dev/null

#########################################################################
# 读取UCI配置
#########################################################################
load_config() {
  BACKUP_PATH=$(uci get jianguoyun.settings.backup_path 2>/dev/null || echo "${DEFAULT_BACKUP_PATH}")
  KEEP_COUNT=$(uci get jianguoyun.settings.keep_count 2>/dev/null || echo "${DEFAULT_KEEP_COUNT}")
  AUTO_CYCLE=$(uci get jianguoyun.settings.auto_cycle 2>/dev/null || echo "${DEFAULT_AUTO_CYCLE}")
  TIMEOUT=$(uci get jianguoyun.settings.timeout 2>/dev/null || echo "${DEFAULT_TIMEOUT}")
  RETRY_COUNT=$(uci get jianguoyun.settings.retry_count 2>/dev/null || echo "${DEFAULT_RETRY_COUNT}")
  DAILY_ENABLE=$(uci get jianguoyun.auto.daily_enable 2>/dev/null || echo "0")
  DAILY_KEEP_DAYS=$(uci get jianguoyun.auto.daily_keep_days 2>/dev/null || echo "30")
}

#########################################################################
# 核心功能：手动备份
#########################################################################
do_backup() {
  load_config
  echo "=== 开始执行备份 ==="
  echo "备份路径：${BACKUP_PATH}"
  echo "保留数量：${KEEP_COUNT}"

  # 生成备份文件名
  BACKUP_NAME="jianguoyun-backup-$(date +"%Y%m%d-%H%M%S").tar.gz"
  BACKUP_FULL_PATH="${BACKUP_PATH}/${BACKUP_NAME}"

  # 创建备份目录
  retry mkdir -p "${BACKUP_PATH}"

  # 执行备份（插件所有核心配置）
  retry tar -zcvf "${BACKUP_FULL_PATH}" \
    /etc/config/jianguoyun \
    /etc/crontabs/root \
    /usr/bin/jianguoyun-backup.sh 2>/dev/null

  # 校验备份文件
  if [ -f "${BACKUP_FULL_PATH}" ]; then
    echo "✅ 备份完成：${BACKUP_FULL_PATH}"
    # 自动清理过期备份
    do_clean
  else
    echo "❌ 备份失败，文件未生成"
    return 1
  fi
}

#########################################################################
# 核心功能：清理过期备份
#########################################################################
do_clean() {
  load_config
  echo "=== 开始清理过期备份 ==="
  echo "保留数量：${KEEP_COUNT}"

  # 按时间排序，删除超出保留数量的备份
  BACKUP_LIST=$(ls -t "${BACKUP_PATH}"/jianguoyun-backup-*.tar.gz 2>/dev/null)
  BACKUP_COUNT=$(echo "${BACKUP_LIST}" | grep -v "^$" | wc -l)

  if [ ${BACKUP_COUNT} -gt ${KEEP_COUNT} ]; then
    DELETE_COUNT=$((BACKUP_COUNT - KEEP_COUNT))
    echo "⚠️  备份数量${BACKUP_COUNT}，超出保留数量，删除${DELETE_COUNT}个过期备份"
    echo "${BACKUP_LIST}" | tail -n ${DELETE_COUNT} | xargs rm -f 2>/dev/null
    echo "✅ 过期备份清理完成"
  else
    echo "✅ 备份数量${BACKUP_COUNT}，无需清理"
  fi
}

#########################################################################
# 核心功能：自动备份任务
#########################################################################
do_auto_daily() {
  echo "=== 每日自动备份 $(date +"%Y-%m-%d %H:%M:%S") ===" >> "${LOG_FILE}"
  do_backup >> "${LOG_FILE}" 2>&1
}

do_auto_full() {
  echo "=== 每月全量自动备份 $(date +"%Y-%m-%d %H:%M:%S") ===" >> "${LOG_FILE}"
  do_backup >> "${LOG_FILE}" 2>&1
}

do_auto_clean() {
  echo "=== 每日自动清理过期备份 $(date +"%Y-%m-%d %H:%M:%S") ===" >> "${LOG_FILE}"
  load_config
  do_clean >> "${LOG_FILE}" 2>&1
}

#########################################################################
# 脚本入口
#########################################################################
case "$1" in
  backup|manual)
    do_backup
    ;;
  clean)
    do_clean
    ;;
  auto_daily)
    do_auto_daily
    ;;
  auto_full)
    do_auto_full
    ;;
  auto_clean)
    do_auto_clean
    ;;
  *)
    echo "用法：$0 [backup|clean|auto_daily|auto_full|auto_clean]"
    echo "  backup/manual  执行手动备份"
    echo "  clean          清理过期备份"
    echo "  auto_daily     每日自动备份"
    echo "  auto_full      每月全量备份"
    echo "  auto_clean     自动清理过期备份"
    exit 1
    ;;
esac

exit 0
