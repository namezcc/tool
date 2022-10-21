-- 热更逻辑
local nowindex = 111

-- if HOT_IDX == nowindex then
-- 	print("hot allready run")
-- 	return
-- end

HOT_IDX = nowindex

-- 热更的模块
local hotModule = {
	"relation_module"
}
for i,v in ipairs(hotModule) do
    ReloadModule(v)
end

-- cfg 热更
-- local hotCfg = {
-- 	-- "yaoji",
-- }
-- for i,v in ipairs(hotCfg) do
-- 	ReloadCfgData(v)
-- end

-- 静态变量热更
-- reload_const("util.table_index",{"TABLE_PROTO_NAME"})

-------------------
print("hotload")
