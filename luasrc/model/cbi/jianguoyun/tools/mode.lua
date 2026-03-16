m = Map("nutstore_backup", translate("场景模式"), translate("一键切换家用全场景优化模式，自动联动对应功能"))

s = m:section(TypedSection, "tools", translate("一键场景模式"))
s.anonymous = true

o = s:option(ListValue, "scene_mode", translate("选择场景模式"))
o:value("home", translate("家用通用模式"))
o:value("game", translate("游戏/直播低延迟模式"))
o:value("wifi", translate("穿墙信号增强模式"))
o:value("energy", translate("节能模式"))
o.default = "home"
o.rmempty = false

o2 = s:option(Button, "apply_scene", translate("一键应用场景模式"))
o2.inputstyle = "apply"
o2.write = function(self, section)
    local mode = m:get(section, "scene_mode")
    luci.sys.call("/usr/bin/nutstore-tools-optimize.sh scene "..mode)
    luci.http.redirect(luci.dispatcher.build_url("admin", "nutstore_backup", "tools", "mode"))
end

s2 = m:section(TypedSection, "tools", translate("优化效果对比"))
s2.anonymous = true
o3 = s2:option(Button, "speedtest_before", translate("优化前测速"))
o3.inputstyle = "button"
o3.write = function()
    luci.sys.call("/usr/bin/nutstore-tools-optimize.sh speedtest before > /tmp/speedtest_before.log")
end
o4 = s2:option(Button, "speedtest_after", translate("优化后测速"))
o4.inputstyle = "button"
o4.write = function()
    luci.sys.call("/usr/bin/nutstore-tools-optimize.sh speedtest after > /tmp/speedtest_after.log")
end
o5 = s2:option(TextValue, "speedtest_result", translate("测速结果"))
o5.readonly = true
o5.rows = 4
o5.cfgvalue = function()
    local before = nixio.fs.readfile("/tmp/speedtest_before.log") or "未测速"
    local after = nixio.fs.readfile("/tmp/speedtest_after.log") or "未测速"
    return "优化前：\n"..before.."\n优化后：\n"..after
end

s3 = m:section(TypedSection, "tools", translate("规则冲突检测"))
s3.anonymous = true
o6 = s3:option(Button, "check_conflict", translate("一键检测优化规则冲突"))
o6.inputstyle = "apply"
o6.write = function()
    luci.sys.call("/usr/bin/nutstore-tools-optimize.sh check_conflict > /tmp/conflict_check.log")
    luci.http.redirect(luci.dispatcher.build_url("admin", "nutstore_backup", "tools", "mode"))
end

return m
