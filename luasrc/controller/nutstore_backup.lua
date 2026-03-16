module("luci.controller.nutstore_backup", package.seeall)

function index()
    local uci = require "luci.model.uci".cursor()
    local menu_level = uci:get("nutstore_backup", "global", "menu_level") or "root"
    
    local root_path
    if menu_level == "root" then
        root_path = {"admin", "nutstore_backup"}
        entry(root_path, firstchild(), _("坚果云备份中心"), 80).dependent = false
    else
        root_path = {"admin", "services", "nutstore_backup"}
        entry(root_path, firstchild(), _("坚果云备份中心"), 60).dependent = false
    end
    
    -- 核心备份功能菜单（锁定结构，零改动）
    entry(root_path..{"overview"}, cbi("jianguoyun/overview"), _("状态总览"), 1)
    entry(root_path..{"backup"}, cbi("jianguoyun/backup"), _("备份管理"), 2)
    entry(root_path..{"restore"}, cbi("jianguoyun/restore"), _("恢复管理"), 3)
    entry(root_path..{"schedule"}, cbi("jianguoyun/schedule"), _("定时备份设置"), 4)
    entry(root_path..{"plugin_backup"}, cbi("jianguoyun/plugin_backup"), _("插件配置备份与恢复"), 5)
    entry(root_path..{"backup_advanced"}, cbi("jianguoyun/backup_advanced"), _("备份高级设置"), 6)
    
    -- 优化工具箱菜单（锁定结构，零改动）
    entry(root_path..{"tools"}, firstchild(), _("优化工具箱"), 10)
    entry(root_path..{"tools", "mode"}, cbi("jianguoyun/tools/mode"), _("场景模式"), 1)
    entry(root_path..{"tools", "network"}, cbi("jianguoyun/tools/network"), _("网络基础优化"), 2)
    entry(root_path..{"tools", "qos"}, cbi("jianguoyun/tools/qos"), _("QoS带宽管理"), 3)
    entry(root_path..{"tools", "wifi"}, cbi("jianguoyun/tools/wifi"), _("WiFi优化设置"), 4)
    entry(root_path..{"tools", "diagnosis"}, cbi("jianguoyun/tools/diagnosis"), _("网络诊断工具"), 5)
    entry(root_path..{"tools", "device_optimize"}, cbi("jianguoyun/tools/device_optimize"), _("设备专属优化"), 6)
    entry(root_path..{"tools", "safety"}, cbi("jianguoyun/tools/safety"), _("安全兜底设置"), 7)
    
    -- 广告拦截中心菜单（锁定结构，零改动）
    entry(root_path..{"adblock"}, firstchild(), _("广告拦截中心"), 20)
    entry(root_path..{"adblock", "control"}, cbi("jianguoyun/adblock/control"), _("核心控制"), 1)
    entry(root_path..{"adblock", "rules"}, cbi("jianguoyun/adblock/rules"), _("规则与黑白名单"), 2)
    entry(root_path..{"adblock", "log"}, cbi("jianguoyun/adblock/log"), _("统计与日志"), 3)
    
    -- 家长控制中心菜单（锁定结构，零改动）
    entry(root_path..{"parent"}, firstchild(), _("家长控制中心"), 30)
    entry(root_path..{"parent", "control"}, cbi("jianguoyun/parent/control"), _("管控总控"), 1)
    entry(root_path..{"parent", "device"}, cbi("jianguoyun/parent/device"), _("管控设备管理"), 2)
    entry(root_path..{"parent", "rules"}, cbi("jianguoyun/parent/rules"), _("管控规则设置"), 3)
    entry(root_path..{"parent", "time"}, cbi("jianguoyun/parent/time"), _("管控时间策略"), 4)
    entry(root_path..{"parent", "feature"}, cbi("jianguoyun/parent/feature"), _("特征库管理"), 5)
    entry(root_path..{"parent", "log"}, cbi("jianguoyun/parent/log"), _("管控统计与日志"), 6)
    
    -- 全局设置与兜底菜单（锁定结构，零改动）
    entry(root_path..{"settings"}, cbi("jianguoyun/settings"), _("全局菜单与权限设置"), 40)
    entry(root_path..{"log"}, cbi("jianguoyun/log"), _("全局运行日志中心"), 41)
    entry(root_path..{"trouble"}, cbi("jianguoyun/trouble"), _("安全与故障排查"), 42)
end
