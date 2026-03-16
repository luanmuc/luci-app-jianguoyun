m = Map("nutstore_backup", translate("状态总览"), translate("坚果云备份中心全局状态与运行概览"))

s = m:section(TypedSection, "global", translate("全局版本信息"))
s.anonymous = true
o = s:option(DummyValue, "version", translate("当前版本"))
o.value = "V1.2.4_FULL_SYNC"

s2 = m:section(TypedSection, "global", translate("核心功能运行状态"))
s2.anonymous = true
o2 = s2:option(DummyValue, "backup_status", translate("最近备份状态"))
o2.cfgvalue = function()
    local log = nixio.fs.readfile("/tmp/nutstore_backup.log") or "暂无备份记录"
    return log
end

return m
