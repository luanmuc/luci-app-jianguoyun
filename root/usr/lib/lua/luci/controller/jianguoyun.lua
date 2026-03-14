module("luci.controller.jianguoyun", package.seeall)

function index()
    entry({"admin", "services", "jianguoyun"}, cbi("jianguoyun"), _("坚果云备份"), 100).dependent = true
    entry({"admin", "services", "jianguoyun", "backup"}, call("action_backup"), nil).leaf = true
    entry({"admin", "services", "jianguoyun", "clean"}, call("action_clean"), nil).leaf = true
end

function action_backup()
    luci.sys.call("/usr/bin/jianguoyun-backup.sh backup > /tmp/jianguoyun-backup.log 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/jianguoyun"))
end

function action_clean()
    luci.sys.call("/usr/bin/jianguoyun-backup.sh clean > /tmp/jianguoyun-clean.log 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/jianguoyun"))
end
