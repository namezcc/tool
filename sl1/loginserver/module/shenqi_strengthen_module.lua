local _IT = ITEM_TYPE
local _BIND = BIND_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _cr = CHANGE_REASON

local shenqi_strengthen_module = {}

function shenqi_strengthen_module:init()
  
	_msg_func.bind_player_proto_func(CM.CM_SHENQI_STRENGTHEN,self.onShenQiStrengthen,"ProtoInt32Array")
end

function shenqi_strengthen_module:initDB(data)
	self._stren = {};
	for k,v in pairs(data.shenqi_strengthen) do
		self._stren[v.id] = table.cloneSimple(v);
		self._stren[v.id].cid = nil   
	end
end

--在initDB之后调用的
function shenqi_strengthen_module:afterInit()
	-- 发给客户端
	local shenqi_data = {}
	shenqi_data["type"] = SHENQI_UP_TYPE.SUT_QIHE
	if self._stren[self.shenbin_id]~=nil then
		table.insert(shenqi_data,self._stren[self.shenbin_id])
	end
	if self._stren[self.shenjia_id]~=nil then
		table.insert(shenqi_data,self._stren[self.shenjia_id])
	end
	self:sendMsg(_sm.SM_SHENQI_DATA_INFO,shenqi_data,"SmShenQiDataInfo")
end

function shenqi_strengthen_module:onShenQiStrengthen()
	if #data.i32 < 32 then
        return
    end
    local index = data.i32[1]
    local level = data.i32[2]

    local icfg = _cfg.shenqi_strengthen(index)
    if icfg == nil then
        return
    end

	local id = icfg.id
	if id ~= self.shenbin_id and id~= shenjia_id then
		return
	end
	
	if icfg.level ~= level then
		return
	end

	--扣除道具升级
	local cost_item = table.clone(icfg.cost_item);
	table.insert(cost_item,2,_IT.IT_ITEM)
    
	if self:delBagCheck(cost_item) then
        self:delBag(cost_item,_cr.CR_SHENQI_STRENGTHEN)
	end

	if self._stren[id] == nil then
		self._stren = {["id"]=id,["level"]=level}
	else
		self._stren[id].level = level
	end

    --属性
    self:calcStrenAttrById(index,id,level)
    self:updateStrenAttr()
    self:sync_stren_change(id)
end

function shenqi_strengthen_module:calcStrenAttrById(index,id,level)
	self._strenAttr = {}
    local attrTmp = {}
    for i=1,index do
        local icfg = _cfg.shenqi_strengthen(i)
        if icfg ~= nil and icfg.id==id and icfg.level<=level then
			local cur_attr = icfg.cur_attr
			for k, v in pairs(cur_attr) do
				if attrTmp[k] == nil then
					attrTmp[k] = {v[k][1],v[k][2],0}
				end
				attrTmp[k] ={v[k][1],v[k][2],attrTmp[k][3] + v[k][3]} 
			end
        end
    end

    self._strenAttr = attrTmp
end

function shenqi_strengthen_module:updateStrenAttr()
	self._attr[PLAYER_ATTR_SOURCE.PAS_SHENQI_STRENGTHEN] = self._strenAttr
    self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_SHENQI_STRENGTHEN, self._attr[PLAYER_ATTR_SOURCE.PAS_SHENQI_STRENGTHEN])
end

function shenqi_strengthen_module:sync_stren_change(id)
	self:sendMsg(_sm.SM_SHENQI_DATA_INFO,self._stren[id],"SmShenQiDataInfo")
    local dbupdate = self._stren[id]
    local count = 0
    for key, value in pairs(dbupdate) do
        count = count + 1
    end
	if count > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_shenqi_strengthen,dbupdate)
	end
end

return shenqi_strengthen_module