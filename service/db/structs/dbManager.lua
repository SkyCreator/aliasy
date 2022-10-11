local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local logger = require "log"
local const = require "const"

local dbManager = {}

local db = nil

function dbManager.init()
    db = mysql.connect({
        host = "127.0.0.1",
        port = 3306,
        database = "aliasy",
        user = "root",
        password = "test",
        charset = "utf8",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })
    
    if not db then
        logger.Debug("connect to mysql server failed")
        return
    end
    
    logger.Debug("connect to mysql server success")
end

function dbManager.start()
    local res = db:query("select playerIncrId from t_general")
    skynet.send(const.Game, "lua", "d2g_playerIncrId", res)
    for i = 1, res[1].playerIncrId, const.DbLoadNum do
        res = db:query("select acc, uid from t_user where id >= "..i.." and id < "..(i + const.DbLoadNum))
        skynet.send(const.Game, "lua", "d2g_start", res)
    end
end

return dbManager