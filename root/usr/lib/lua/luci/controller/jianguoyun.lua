module("luci.controller.jianguoyun", package.seeall)

function index()
    entry({"admin", "services", "jianguoyun"}, firstchild(), _("坚果云备份"), 90).dependent = false
    entry({"admin", "services", "jianguoyun", "basic"}, cbi("jianguoyun/basic"), _("基础设置"), 1)
    entry({"admin", "services", "jianguoyun", "backup"}, cbi("jianguoyun/backup"), _("备份恢复"), 2)
    entry({"admin", "services", "jianguoyun", "log"}, cbi("jianguoyun/log"), _("日志查看"), 3)
    entry({"admin", "services", "jianguoyun", "status"}, template("jianguoyun/status"), _("运行状态"), 4)
end
