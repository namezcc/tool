local _ST = STORAGE_TYPE
local _IT = ITEM_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _cm = CM
local _sm = SM
local _cr = CHANGE_REASON
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _func = LFUNC
local _net_mgr = nil
local _strutil = STRING_UTIL
local danyao_module = {}

function danyao_module:init()
    _net_mgr = MOD.net_mgr_module
    _msg_func.bind_player_proto_func(_cm.CM_EAT_DANYAO, self.onEatDanyao, "ProtoInt32")
end

function danyao_module:initDB(data)

end

function danyao_module:afterInit()

	self:updateDanyaoAttr()
	self:sendDanyaoInfo(0)
end


function danyao_module:getDanyao(did)
	return self._danyao[did] or 0
end

function danyao_module:updateDanyao(did,num)
	local pb = {cid=self.cid,did=did,num=num}
	if num == 0 then
		self._danyao[did] = nil
		self:dbDeleteData(_table.TAB_mem_chr_danyao,pb)
	else
		self._danyao[did] = num
		self:dbUpdateData(_table.TAB_mem_chr_danyao,pb)
	end
end

function danyao_module:addDanyao(did,num)
	local old = self._danyao[did]
	if old then
		old = old + num
	else
		old = num
	end
	self:updateDanyao(did,old)
end

function danyao_module:updateDanyaoAttr()
	local attrdata = {}
	for index, value in pairs(self._danyao) do
		local danyao = _cfg.danyao(index)
		if danyao then
			local danyaoattr = {danyao.attr[1], danyao.attr[2], danyao.attr[3]* value}
			attrdata[#attrdata+1] = danyaoattr
		end
	end
	self._attr[PLAYER_ATTR_SOURCE.PAS_DANYAO] = attrdata
	self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_DANYAO, self._attr[PLAYER_ATTR_SOURCE.PAS_DANYAO])
end

function danyao_module:sendDanyaoInfo(danyaoid)

	local danyao = {}
	if danyaoid == 0 then
		for i, v in pairs(self._danyao) do
			local danyaoinfo = {
				did = i,
				num = v,
			}
			danyao[#danyao + 1] = danyaoinfo
		end
	else
		local danyaoinfo = {
			did = danyaoid,
			num = self:getDanyao(danyaoid),
		}
		danyao[#danyao + 1] = danyaoinfo
	end

	self:sendMsg(_sm.SM_DANYAO_INFO, {danyao = danyao}, "SmDanyaoInfo")
end

function danyao_module:onEatDanyao(data)
	local did = data.i32
    local chr_info = self._chr_info

	local cfg = _cfg.danyao_cost(did,chr_info.hunshi)
	if cfg == nil then
		return
	end

	local num = self:getDanyao(did)
	if num >= cfg.num then
		return
	end

	local cost = {}
	cost[#cost+1] = _func.make_cfg_item_one(did,_IT.IT_ITEM,1)
	if self:delBagCheck(cost) == false then
		return
	end

	self:delBag(cost,_cr.CR_EAT_DANYAO)
	self:addDanyao(did, 1)
	self:updateDanyaoAttr()
	self:sendDanyaoInfo(did)
	self:updateProgressByType(TASK_CONDITION_TYPE.TCT_USE_DRUG, did, 1)
end

return danyao_module