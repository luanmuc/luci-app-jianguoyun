m = Map("jianguoyun", translate("坚果云备份 - 日志查看"), translate("查看插件运行日志，路由器重启后日志自动清空"))

s = m:section(SimpleSection)
o = s:option(TextValue, "_log")
o.rows = 20
o.readonly = true
o.cfgvalue = function()
    local log = luci.sys.exec("cat /tmp/jianguoyun.log 2>/dev/null")
    return log ~= "" and log or "暂无日志"
end

o = s:option(Button, "_clear_log", translate("清空日志"))
o.inputtitle = translate("立即清空")
o.inputstyle = "reset"
o.write = function()
    luci.sys.exec("echo '' > /tmp/jianguoyun.log")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "jianguoyun", "log"))
end

return m
