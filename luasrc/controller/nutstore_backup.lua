module("luci.controller.nutstore_backup", package.seeall)

function index()
    -- 引入依赖，容错处理
    local ok, uci = pcall(require, "luci.model.uci")
    if not ok then return end
    local cursor = uci.cursor()
    
    -- 获取菜单层级配置，默认根菜单
    local menu_level = cursor:get("nutstore_backup", "global", "menu_level") or "root"
    
    -- 动态生成主菜单路径
    local base_path
    if menu_level == "root" then
        base_path = {"admin", "nutstore_backup"}
    else
        base_path = {"admin", "services", "nutstore_backup"}
    end
    
    -- 注册主菜单
    local main_node = entry(base_path, firstchild(), _("坚果云备份中心"), 80)
    main_node.dependent = false
    main_node.acl_depends = { "luci-app-jianguoyun" } -- 绑定权限，避免403

    -- 核心备份功能菜单（动态拼接路径，无语法错误）
    entry(base_path + {"overview"}, cbi("jianguoyun/overview"), _("状态总览"), 1).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"backup"}, cbi("jianguoyun/backup"), _("备份管理"), 2).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"restore"}, cbi("jianguoyun/restore"), _("恢复管理"), 3).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"schedule"}, cbi("jianguoyun/schedule"), _("定时备份设置"), 4).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"plugin_backup"}, cbi("jianguoyun/plugin_backup"), _("插件配置备份与恢复"), 5).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"backup_advanced"}, cbi("jianguoyun/backup_advanced"), _("备份高级设置"), 6).acl_depends = { "luci-app-jianguoyun" }
    
    -- 优化工具箱菜单
    local tools_path = base_path + {"tools"}
    entry(tools_path, firstchild(), _("优化工具箱"), 10).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"mode"}, cbi("jianguoyun/tools/mode"), _("场景模式"), 1).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"network"}, cbi("jianguoyun/tools/network"), _("网络基础优化"), 2).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"qos"}, cbi("jianguoyun/tools/qos"), _("QoS带宽管理"), 3).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"wifi"}, cbi("jianguoyun/tools/wifi"), _("WiFi优化设置"), 4).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"diagnosis"}, cbi("jianguoyun/tools/diagnosis"), _("网络诊断工具"), 5).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"device_optimize"}, cbi("jianguoyun/tools/device_optimize"), _("设备专属优化"), 6).acl_depends = { "luci-app-jianguoyun" }
    entry(tools_path + {"safety"}, cbi("jianguoyun/tools/safety"), _("安全兜底设置"), 7).acl_depends = { "luci-app-jianguoyun" }
    
    -- 广告拦截中心菜单
    local adblock_path = base_path + {"adblock"}
    entry(adblock_path, firstchild(), _("广告拦截中心"), 20).acl_depends = { "luci-app-jianguoyun" }
    entry(adblock_path + {"control"}, cbi("jianguoyun/adblock/control"), _("核心控制"), 1).acl_depends = { "luci-app-jianguoyun" }
    entry(adblock_path + {"rules"}, cbi("jianguoyun/adblock/rules"), _("规则与黑白名单"), 2).acl_depends = { "luci-app-jianguoyun" }
    entry(adblock_path + {"log"}, cbi("jianguoyun/adblock/log"), _("统计与日志"), 3).acl_depends = { "luci-app-jianguoyun" }
    
    -- 家长控制中心菜单
    local parent_path = base_path + {"parent"}
    entry(parent_path, firstchild(), _("家长控制中心"), 30).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"control"}, cbi("jianguoyun/parent/control"), _("管控总控"), 1).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"device"}, cbi("jianguoyun/parent/device"), _("管控设备管理"), 2).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"rules"}, cbi("jianguoyun/parent/rules"), _("管控规则设置"), 3).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"time"}, cbi("jianguoyun/parent/time"), _("管控时间策略"), 4).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"feature"}, cbi("jianguoyun/parent/feature"), _("特征库管理"), 5).acl_depends = { "luci-app-jianguoyun" }
    entry(parent_path + {"log"}, cbi("jianguoyun/parent/log"), _("管控统计与日志"), 6).acl_depends = { "luci-app-jianguoyun" }
    
    -- 全局设置与兜底菜单
    entry(base_path + {"settings"}, cbi("jianguoyun/settings"), _("全局菜单与权限设置"), 40).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"log"}, cbi("jianguoyun/log"), _("全局运行日志中心"), 41).acl_depends = { "luci-app-jianguoyun" }
    entry(base_path + {"trouble"}, cbi("jianguoyun/trouble"), _("安全与故障排查"), 42).acl_depends = { "luci-app-jianguoyun" }
end
