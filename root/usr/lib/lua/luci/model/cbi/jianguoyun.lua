m = Map("jianguoyun", _("坚果云备份"), _("坚果云WebDAV备份与恢复插件，支持自动备份、定时任务、过期清理"))

-- 基础设置
s = m:section(TypedSection, "settings", _("基础设置"))
s.anonymous = true

o = s:option(Value, "backup_path", _("备份路径"), _("备份文件存放的目录"))
o.default = "/tmp/upload"
o.rmempty = false

o = s:option(Value, "keep_count", _("备份保留数量"), _("最多保留的备份文件数量，超出自动删除"))
o.datatype = "uinteger"
o.default = 30
o.rmempty = false

o = s:option(Value, "timeout", _("操作超时时间"), _("操作超时时间，单位秒"))
o.datatype = "uinteger"
o.default = 30
o.rmempty = false

o = s:option(Value, "retry_count", _("重试次数"), _("操作失败后的重试次数"))
o.datatype = "uinteger"
o.default = 3
o.rmempty = false

-- 自动任务设置
s = m:section(TypedSection, "auto", _("自动任务设置"))
s.anonymous = true

o = s:option(Flag, "daily_enable", _("启用每日自动备份"), _("每天凌晨2点自动执行备份"))
o.default = 1
o.rmempty = false

o = s:option(Value, "daily_keep_days", _("每日备份保留天数"), _("每日备份的保留天数"))
o.datatype = "uinteger"
o.default = 30
o.rmempty = false
o:depends("daily_enable", 1)

-- 手动操作
s = m:section(SimpleSection, _("手动操作"))
s.template = "cbi/tblsection"

o = s:option(Button, "_backup", _("立即备份"))
o.inputtitle = _("执行手动备份")
o.inputstyle = "apply"
o.write = function()
    luci.sys.call("/usr/bin/jianguoyun-backup.sh backup > /tmp/jianguoyun-backup.log 2>&1")
end

o = s:option(Button, "_clean", _("清理过期备份"))
o.inputtitle = _("执行清理")
o.inputstyle = "reset"
o.write = function()
    luci.sys.call("/usr/bin/jianguoyun-backup.sh clean > /tmp/jianguoyun-clean.log 2>&1")
end

return m
