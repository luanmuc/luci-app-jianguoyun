m = Map("jianguoyun", translate("坚果云备份 - 基础设置"), translate("配置坚果云WebDAV账号和基础备份参数"))

s = m:section(NamedSection, "global", "jianguoyun", translate("全局设置"))

o = s:option(Flag, "enabled", translate("启用插件"))
o.default = 0
o.rmempty = false

o = s:option(Value, "webdav_url", translate("WebDAV地址"))
o.default = "https://dav.jianguoyun.com/dav/"
o.rmempty = false

o = s:option(Value, "username", translate("坚果云账号（邮箱）"))
o.rmempty = false

o = s:option(Value, "password", translate("应用密码"))
o.password = true
o.rmempty = false
o.description = translate("请使用坚果云官网「安全设置」中生成的「应用密码」，不是登录密码")

o = s:option(Flag, "encrypt", translate("加密备份文件"))
o.default = 1
o.rmempty = false
o.description = translate("开启后，备份文件将使用你的应用密码加密，忘记密码无法恢复")

o = s:option(Value, "backup_path", translate("备份路径"))
o.default = "/etc/config"
o.rmempty = false
o.description = translate("要备份的目录/文件，多个路径用空格分隔")

o = s:option(Flag, "autobackup", translate("启用自动备份"))
o.default = 0
o.rmempty = false

o = s:option(Value, "backup_cron", translate("自动备份定时规则"))
o.default = "0 3 * * *"
o:depends("autobackup", 1)
o.description = translate("Cron表达式，格式：分 时 日 月 周，默认每天凌晨3点执行")

o = s:option(Flag, "log_enable", translate("启用日志"))
o.default = 1
o.rmempty = false

o = s:option(Value, "log_max_count", translate("日志最大保留操作次数"))
o.default = 3
o:depends("log_enable", 1)
o.datatype = "uinteger"

-- 保存后自动更新定时任务
m.on_after_commit = function()
    luci.sys.exec("/usr/bin/jianguoyun-core.sh --set-cron >/dev/null 2>&1")
end

return m
