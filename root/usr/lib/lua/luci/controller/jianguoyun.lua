module("luci.controller.jianguoyun", package.seeall)

function index()
    -- 注册服务菜单，全中文显示
    entry({"admin", "services", "jianguoyun"}, cbi("jianguoyun"), "坚果云备份", 90).dependent = true
    -- 注册手动备份的执行接口
    entry({"admin", "services", "jianguoyun", "manual_backup"}, call("action_manual_backup"), nil).leaf = true
end

-- 手动备份执行接口
function action_manual_backup()
    local result = {}
    local ret = os.execute("/usr/bin/jianguoyun-backup.sh manual")
    if ret == 0 then
        result.success = true
        result.msg = "手动备份执行成功，已上传至坚果云"
    else
        result.success = false
        result.msg = "备份执行失败，请查看日志排查问题"
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json(result)
end
