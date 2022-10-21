local _IT = ITEM_TYPE
local _BIND = BIND_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _cr = CHANGE_REASON

local shenqi_star_module = {}

function shenqi_star_module:init()
  
	_msg_func.bind_player_proto_func(CM.CM_SHENQI_STAR,self.onShenQiStar,"ProtoInt32Array")
end

function shenqi_star_module:initDB(data)
	self._star = {}
	for k,v in pairs(data.shenqi_star) do
		self._star[v.id] = table.cloneSimple(v)
		self._star[v.id].cid = nil   
	end
end

--在initDB之后调用的
function shenqi_star_module:afterInit()
	-- 发给客户端
	local shenqi_data = {}
	shenqi_data["type"] = SHENQI_UP_TYPE.SUT_QIHE
	if self._star[self.shenbin_id]~=nil then
		table.insert(shenqi_data,self._star[self.shenbin_id])
	end
	if self._star[self.shenjia_id]~=nil then
		table.insert(shenqi_data,self._star[self.shenjia_id])
	end
	self:sendMsg(_sm.SM_SHENQI_DATA_INFO,shenqi_data,"SmShenQiDataInfo")
end

function shenqi_star_module:onShenQiStar()
	if #data.i32 < 32 then
        return
    end
    local index = data.i32[1]
    local level = data.i32[2]

    local icfg = _cfg.shenqi_qihe(index)
    if icfg == nil then
        return
    end

	local id = icfg.id
	if id ~= self.shenbin_id and id ~= self.shenjia_id then
		return
	end
	if icfg.level ~= level then
		return
	end

	--扣除道具升级
	local cost_item = table.clone(icfg.cost_item);
	table.insert(cost_item,2,_IT.IT_ITEM)
    
	if self:delBagCheck(cost_item) then
        self:delBag(cost_item,_cr.CR_SHENQI_STAR)
	end

	--
	-- local icfg2 = _cfg.shenqi_qihe(index+1)
    -- if icfg2 ~= nil then
    --     index = index + 1
	-- 	level = level + 1
    -- end

	if self._star[id] == nil then
		self._star[id] = {["id"]=id,["level"]=level}
	else
		self._star[id].level = level
	end

    --属性
    self:calcStarAttrById(index,id,level)
    self:updateStarAttr()
    self:sync_star_change(id)
end

function shenqi_star_module:calcStarAttrById(index,id,level)
	self._starAttr = {}
    local attrTmp = {}
    for i=1,index do
        local icfg = _cfg.shenqi_star(i)
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

    self._starAttr = attrTmp
end

function shenqi_star_module:updateStarAttr()
	self._attr[PLAYER_ATTR_SOURCE.PAS_SHENQI_STAR] = self._starAttr
    self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_SHENQI_STAR, self._attr[PLAYER_ATTR_SOURCE.PAS_SHENQI_STAR])
end

function shenqi_star_module:sync_star_change(id)
	self:sendMsg(_sm.SM_SHENQI_DATA_INFO,self._star[id],"SmShenQiDataInfo")
    local dbupdate = self._star[id]
    local count = 0
    for key, value in pairs(dbupdate) do
        count = count + 1
    end
	if count > 0 then
		self:dbUpdateDataVector(_table.TAB_mem_chr_shenqi_star,dbupdate)
	end
end

return shenqi_star_module