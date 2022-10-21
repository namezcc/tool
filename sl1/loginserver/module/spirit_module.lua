local _IT = ITEM_TYPE
local _BIND = BIND_TYPE
local _cfg = CFG_DATA
local _log = LOG
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _cr = CHANGE_REASON

local spirit_module = {}
local spiritInfo = {}

function spirit_module:getShenQiId()
    return {
        self.shenbin_id,
        self.shenjia_id,
    }
end

function spirit_module:init()
  
	_msg_func.bind_player_proto_func(CM.CM_SPIRIT_INHERIT,self.onSpiritInherit,"ProtoInt32Array")
end

function spirit_module:initDB(data)
	
--     message DBChrSpirit
-- {
-- 	int64	cid = 1;
-- 	int32	id = 3;
-- 	int32	level = 4;
-- 	int32	attr_1 = 5;
-- 	int32	attr_2 = 6;
-- 	int32	attr_3 = 7;
-- 	int32	attr_4 = 8;
-- 	int32	attr_5 = 9;
-- }
    self._spirit = {};
    for _,v in pairs(data.spirit) do
        self._spirit[v.id] = table.cloneSimple(v);
        --self._spirit[v.id].cid = nil
        spiritInfo[#spiritInfo+1] = self._spirit[v.id]
        spiritInfo[#spiritInfo].cid = nil   
    end

    self.shenbin_id = 1001
	self.shenjia_id = 2001

	-- 发给客户端
	self:sendMsg(_sm.SM_SPIRIT_INFO,spiritInfo,"SmSpiritInfo")
end

--在initDB之后调用的
function spirit_module:afterInit()
	--self:initSpiritAttrCash()
end

function spirit_module:initSpiritAttrCash()

end

function spirit_module:onSpiritInherit(data)
    if #data.i32 < 3 then
        return
    end
    local index = data.i32[1]
    local level = data.i32[2]
    local light = data.i32[3]

    if light<1 or light>5 then
        return
    end
    -- 当前id等级是否对 
    local icfg = _cfg.spirit(index)
    if icfg == nil then
        return
    end

    local id = icfg.id
    local spirit = {}
    local attr = nil
    if not table.empty(self._spirit)  and self._spirit[id] ~= nil then
        spirit = self._spirit[id]
    else
        spirit = {["cid"]= self.cid,["id"]=id,["level"]=level,["attr_1"] =0,["attr_2"] =0,["attr_3"] =0,["attr_4"] =0,["attr_5"] =0}
    end

    if light == 1 then
        attr = spirit.attr_1
    elseif light == 2 then
        attr = spirit.attr_2
        if spirit.attr_1 ~=1 then
            return
        end
    elseif light == 3 then
        attr = spirit.attr_3
        if spirit.attr_2 ~=1 then
            return
        end
    elseif light == 4 then
        attr = spirit.attr_4
        if spirit.attr_3 ~=1 then
            return
        end
    elseif light == 5 then
        attr = spirit.attr_5
        if spirit.attr_4 ~=1 then
            return
        end
    end
    
    if level~=icfg.level or level < spirit.level then
        return        
    end

    --是否已点亮
    if attr==1  then
        return    
    end

    --扣除道具升级
    --每级5个，每个消耗道具可能不同
    local cost_item = table.clone(icfg.cost_item);
    for k, value in ipairs(cost_item) do
        if k==light then
            table.insert(cost_item[k],2,_IT.IT_ITEM)
        else
            cost_item[k][2] = 0 --id,num,bind
            table.insert(cost_item[k],2,_IT.IT_ITEM) ----id,tp,num,bind
        end
    end
    
	if self:delBagCheck(cost_item) then
        self:delBag(cost_item,_cr.CR_SPIRIT)
	end
	
    --
    if light == 1 then
        spirit.attr_1 = 1
    elseif light == 2 then
        spirit.attr_2 = 1
    elseif light == 3 then
        spirit.attr_3 = 1
    elseif light == 4 then
        spirit.attr_4 = 1
    elseif light == 5 then
        spirit.attr_5 = 1
    end
    self._spirit[id] = spirit

    --属性
    self:calcSpiritAttrById(index,id,level)
    self:updateSpiritAttr()
    self:sync_spirit_change(id)
end

function spirit_module:calcSpiritAttrById(index,id,level)
    local spirit = self._spirit
    self._spiritAttr = {}
    local attrTmp = {0,0,0,0,0}
    for i=1,index do
        local icfg = _cfg.spirit(i)
        if icfg ~= nil and icfg.id==id and icfg.level<=level then
            if spirit[i].attr_1 == 1  then
                attrTmp[1] = attrTmp[1] + icfg.cur_attr[1][3]
            end
            if spirit[i].attr_2 == 1  then
                attrTmp[2] = attrTmp[2] + icfg.cur_attr[2][3]
            end
            if spirit[i].attr_3 == 1  then
                attrTmp[3] = attrTmp[3] + icfg.cur_attr[3][3]
            end
            if spirit[i].attr_4 == 1  then
                attrTmp[4] = attrTmp[4] + icfg.cur_attr[4][3]
            end
            if spirit[i].attr_5 == 1  then
                attrTmp[5] = attrTmp[5] + icfg.cur_attr[5][3]
            end
        end
    end

    self._spiritAttr ={
        {ATTR_TYPE.ATTR_JINGSHEN, 1, attrTmp[1]},
        {ATTR_TYPE.ATTR_MINJIE, 1, attrTmp[2]},
        {ATTR_TYPE.ATTR_TIZHI, 1, attrTmp[3]},
        {ATTR_TYPE.ATTR_ZHIHUI, 1, attrTmp[4]},
        {ATTR_TYPE.ATTR_LILIANG, 1, attrTmp[5]}
    }
end

function spirit_module:updateSpiritAttr()
    self._attr[PLAYER_ATTR_SOURCE.PAS_SPIRIT] = self._spiritAttr
    self:sendAttrMsg(PLAYER_ATTR_SOURCE.PAS_SPIRIT, self._attr[PLAYER_ATTR_SOURCE.PAS_SPIRIT])

end

function spirit_module:sync_spirit_change(id)
    self:sendMsg(_sm.SM_SPIRIT_INFO,spiritInfo,"SmSpiritInfo")
    --DBChrSpirit
    local dbupdate = self._spirit[id]
	if #dbupdate > 0 then
		self:dbUpdateData(_table.TAB_mem_chr_spirit,dbupdate)
	end
end


return spirit_module