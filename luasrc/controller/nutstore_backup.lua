module("luci.controller.nutstore_backup", package.seeall)

function index()
    local uci = require "luci.model.uci".cursor()
    local menu_level = uci:get("nutstore_backup", "global", "menu_level") or "root"
    
    -- 主菜单注册
    local main_node
    if menu_level == "root" then
        -- 根菜单显示
        main_node = entry({"admin", "nutstore_backup"}, firstchild(), _("坚果云备份中心"), 80)
        main_node.dependent = false
    else
        -- 服务菜单内显示
        main_node = entry({"admin", "services", "nutstore_backup"}, firstchild(), _("坚果云备份中心"), 60)
        main_node.dependent = false
    end

    -- 核心备份功能菜单（正确写法，无语法错误）
    entry({"admin", "nutstore_backup", "overview"}, cbi("jianguoyun/overview"), _("状态总览"), 1)
    entry({"admin", "nutstore_backup", "backup"}, cbi("jianguoyun/backup"), _("备份管理"), 2)
    entry({"admin", "nutstore_backup", "restore"}, cbi("jianguoyun/restore"), _("恢复管理"), 3)
    entry({"admin", "nutstore_backup", "schedule"}, cbi("jianguoyun/schedule"), _("定时备份设置"), 4)
    entry({"admin", "nutstore_backup", "plugin_backup"}, cbi("jianguoyun/plugin_backup"), _("插件配置备份与恢复"), 5)
    entry({"admin", "nutstore_backup", "backup_advanced"}, cbi("jianguoyun/backup_advanced"), _("备份高级设置"), 6)
    
    -- 优化工具箱菜单
    local tools_node = entry({"admin", "nutstore_backup", "tools"}, firstchild(), _("优化工具箱"), 10)
    entry({"admin", "nutstore_backup", "tools", "mode"}, cbi("jianguoyun/tools/mode"), _("场景模式"), 1)
    entry({"admin", "nutstore_backup", "tools", "network"}, cbi("jianguoyun/tools/network"), _("网络基础优化"), 2)
    entry({"admin", "nutstore_backup", "tools", "qos"}, cbi("jianguoyun/tools/qos"), _("QoS带宽管理"), 3)
    entry({"admin", "nutstore_backup", "tools", "wifi"}, cbi("jianguoyun/tools/wifi"), _("WiFi优化设置"), 4)
    entry({"admin", "nutstore_backup", "tools", "diagnosis"}, cbi("jianguoyun/tools/diagnosis"), _("网络诊断工具"), 5)
    entry({"admin", "nutstore_backup", "tools", "device_optimize"}, cbi("jianguoyun/tools/device_optimize"), _("设备专属优化"), 6)
    entry({"admin", "nutstore_backup", "tools", "safety"}, cbi("jianguoyun/tools/safety"), _("安全兜底设置"), 7)
    
    -- 广告拦截中心菜单
    local adblock_node = entry({"admin", "nutstore_backup", "adblock"}, firstchild(), _("广告拦截中心"), 20)
    entry({"admin", "nutstore_backup", "adblock", "control"}, cbi("jianguoyun/adblock/control"), _("核心控制"), 1)
    entry({"admin", "nutstore_backup", "adblock", "rules"}, cbi("jianguoyun/adblock/rules"), _("规则与黑白名单"), 2)
    entry({"admin", "nutstore_backup", "adblock", "log"}, cbi("jianguoyun/adblock/log"), _("统计与日志"), 3)
    
    -- 家长控制中心菜单
    local parent_node = entry({"admin", "nutstore_backup", "parent"}, firstchild(), _("家长控制中心"), 30)
    entry({"admin", "nutstore_backup", "parent", "control"}, cbi("jianguoyun/parent/control"), _("管控总控"), 1)
    entry({"admin", "nutstore_backup", "parent", "device"}, cbi("jianguoyun/parent/device"), _("管控设备管理"), 2)
    entry({"admin", "nutstore_backup", "parent", "rules"}, cbi("jianguoyun/parent/rules"), _("管控规则设置"), 3)
    entry({"admin", "nutstore_backup", "parent", "time"}, cbi("jianguoyun/parent/time"), _("管控时间策略"), 4)
    entry({"admin", "nutstore_backup", "parent", "feature"}, cbi("jianguoyun/parent/feature"), _("特征库管理"), 5)
    entry({"admin", "nutstore_backup", "parent", "log"}, cbi("jianguoyun/parent/log"), _("管控统计与日志"), 6)
    
    -- 全局设置与兜底菜单
    entry({"admin", "nutstore_backup", "settings"}, cbi("jianguoyun/settings"), _("全局菜单与权限设置"), 40)
    entry({"admin", "nutstore_backup", "log"}, cbi("jianguoyun/log"), _("全局运行日志中心"), 41)
    entry({"admin", "nutstore_backup", "trouble"}, cbi("jianguoyun/trouble"), _("安全与故障排查"), 42)
end
