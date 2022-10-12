local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local logger = require "log"
local const = require "const"

local dbManager = {}
dbManager.db = nil

function dbManager.init()
    dbManager.db = mysql.connect({
        host = "127.0.0.1",
        port = 3306,
        database = "aliasy",
        user = "root",
        password = "test",
        charset = "utf8mb4",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })
    
    if not dbManager.db then
        logger.Debug("connect to mysql server failed")
        return
    end
    
    logger.Debug("connect to mysql server success")
end

function dbManager.start()
    local data
    local res = dbManager.db:query("select playerIncrId, unionIncrId from t_general")
    
    skynet.send(const.Game, "lua", "d2g_playerIncrId", res[1].playerIncrId)
    
    for i = 1, res[1].playerIncrId, const.DbLoadNum do
        data = dbManager.db:query("select account, uid, roleData from t_user where id >= "..i.." and id < "..(i + const.DbLoadNum))
        skynet.send(const.Game, "lua", "d2g_start", data)
    end

    skynet.send(const.Union, "lua", "d2u_unionIncrId", res[1].unionIncrId)

    for i = 1, res[1].unionIncrId, const.DbLoadNum do
        data = dbManager.db:query("select unid, baseData from t_union where id >= "..i.." and id < "..(i + const.DbLoadNum))
        skynet.send(const.Union, "lua", "d2u_start", data)
    end

end

return dbManager