m = Map("jianguoyun", translate("坚果云备份 - 备份恢复"), translate("手动执行备份和恢复操作"))

-- 手动备份
s = m:section(SimpleSection, translate("手动备份"))
o = s:option(Button, "_backup", translate("立即执行备份"))
o.inputtitle = translate("开始备份")
o.inputstyle = "apply"
o.write = function()
    -- 异步执行，不卡页面
    luci.sys.exec("/usr/bin/jianguoyun-core.sh --backup >/dev/null 2>&1 &")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "jianguoyun", "log"))
end

-- 手动恢复
s = m:section(SimpleSection, translate("手动恢复"))
o = s:option(Value, "remote_file", translate("要恢复的备份文件名"))
o.rmempty = true
o.description = translate("填写坚果云上的备份文件名，例如：openwrt_backup_20240101_030000.zip")

o = s:option(Button, "_restore", translate("立即执行恢复"))
o.inputtitle = translate("开始恢复")
o.inputstyle = "danger"
o.write = function(self, section)
    local file = m:formvalue(section..".remote_file")
    if file and file ~= "" then
        -- 异步执行，二次确认
        luci.sys.exec("/usr/bin/jianguoyun-core.sh --restore "..luci.util.shellquote(file).." >/dev/null 2>&1 &")
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "jianguoyun", "log"))
    end
end

return m
