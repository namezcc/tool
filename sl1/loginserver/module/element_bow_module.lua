local _string = STRING_UTIL
local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _attr_mod = PLAYER_ATTR_SOURCE


local element_bow_module = {}

function element_bow_module:init()
	MSG_FUNC.bind_player_proto_func(CM.CM_EBOW_LEVEL_UP,self.onEBowLevelUp,"ProtoInt32")
    --MSG_FUNC.bind_player_proto_func(CM.CM_EBOW_SUIT_LV_UP,self.onEBowSuitLvUp,"ProtoInt32")
end

function element_bow_module:initDB(data)
	
    local elementbow = {}
	if _func.checkPlayerData(data.elementbow) then
		elementbow = data.elementbow
	else
		elementbow = {
			cid = self.cid,
            elementbow_lv = "0,0,0,0,0,0,0,0",
            suit_lv = 0,
		}
	end

    elementbow.ebow_lv = _string.splite_int_vec(elementbow.elementbow_lv,",")
	self._elementbow = elementbow

	self:sendEBowInfo()
end

function element_bow_module:afterInit()
	self:updateModuleAttr(_attr_mod.PAS_EBOW,true)
end

function element_bow_module:sendEBowInfo()
	self:sendMsg(_sm.SM_EBOW_INFO,self._elementbow,"SmEbowInfo")
end

function element_bow_module:updateEBowDB()
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_ebow,self._elementbow)
end


function element_bow_module:calcEbowAttr()
	local attr = {}

	local ebow = self._elementbow

	for tp, lv in ipairs(ebow.ebow_lv) do
		local cfg = _cfg.element_bow(tp,lv)
		if cfg then
			_func.combindAttr(attr,cfg.attr)
		end
	end
	return attr
end

function element_bow_module:onEBowLevelUp(d)
    -- if #d.i32 < 1 then
    --     return
    -- end
    local type = d.i32
	local ebow = self._elementbow
	local cfg = _cfg.element_bow(type,ebow.ebow_lv[type]+1)
	if cfg == nil then
		return
	end

	local chrinfo = self._chr_info
	if chrinfo.hunshi < cfg.hunshi_lv then
		return
	end

	if not self:delBagCheck(cfg.cost_item) then
		return
	end

	self:delBag(cfg.cost_item,CHANGE_REASON.CR_EBOW_LEVEL_UP)

	ebow.ebow_lv[type] = ebow.ebow_lv[type] + 1

	--激活/升级技能
	for _, v in ipairs(cfg.skill_id_lv) do
		self:updateSkill(v[1],v[2])
	end

	--套装
	ebow.suit_lv = self:getEBowSuitLv()
	
	self:sendEBowInfo()
	ebow.elementbow_lv = table.concat(ebow.ebow_lv,",");
	self:updateEBowDB()
	self:updateModuleAttr(_attr_mod.PAS_EBOW)
end

function element_bow_module:getEBowSuitLv()
	local ebow = self._elementbow
	local suitLv = ebow.ebow_lv[1]
	for i = 1, 8 do
		if ebow.ebow_lv[i]< suitLv then
			suitLv = ebow.ebow_lv[i]
		end
	end

	return suitLv	
end

-- function element_bow_module:onEBowSuitLvUp(d)
--     local ebow = self._elementbow
-- 	local cfg = _cfg.element_bow_suit(ebow.suit_lv+1)
-- 	if cfg == nil then
-- 		return
-- 	end

-- 	if not self:delBagCheck(cfg.cost_item) then
-- 		return
-- 	end

-- 	self:delBag(cfg.cost_item,CHANGE_REASON.CR_EBOW_SUIT_LV_UP)
-- 	ebow.suit_lv = ebow.suit_lv + 1

-- 	self:dbUpdateData(_table.TAB_mem_chr_ebow,ebow)
-- 	self:sendEBowInfo()
-- 	self:updateModuleAttr(_attr_mod.PAS_EBOW)
-- end

return element_bow_module