local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _string = STRING_UTIL
local _IT = ITEM_TYPE

-- local DRESS_STATE = {
--     unlock = 0,
--     time_limit = 1,
--     permanent = 2,
-- }
local FOREVER_VAILD_SECOND = -1 --346896000
local ONE_YEAR_SECOND = 31536000

local DRESS_TYPE = {
    head = 1,
    face = 2,
    cloth = 3,
    back = 4,
    waist = 5,
    dt_max = 5,
}

local dress_module = {}

function dress_module:init()
	MSG_FUNC.bind_player_proto_func(CM.CM_UNLOCK_DRESS,self.onUnlockDress,"ProtoInt32Array")
    MSG_FUNC.bind_player_proto_func(CM.CM_WEAR_DRESS,self.onWearDress,"ProtoInt32Array")
end

function dress_module:initDB(data)
    local dress = {}
    self._glamours = {value=0,level=0}
    for i = 1, DRESS_TYPE.dt_max do
        dress[i] = {}
    end

	if data.dress then
		for _, value in ipairs(data.dress) do
            if dress[value.type] == nil then
                dress[value.type] = {}
            end
			dress[value.type][value.id] = table.cloneSimple(value)
		end
	end
	self._dress = dress

    local dressWear = {}
	if _func.checkPlayerData(data.dress_wear) then
		dressWear = data.dress_wear
	else
		dressWear = {
			cid = self.cid,
            wear = "0,0,0,0,0",
		}
	end

    dressWear.wearInt = _string.splite_int_vec(dressWear.wear,",")
	self._dressWear = dressWear

	self:sendDressInfo()
    self:sendWearDressInfo()
end

function dress_module:afterInit()
    self:updateGlamours()
end

function dress_module:updateGlamours()
    -- local glamours = 0
    -- local now = _func.getNowSecond()
    -- for k, v in ipairs(self._dress) do
    --     for m, n in ipairs(v) do
    --         -- print(k,m,n.group,n.id)
    --         -- pb[#pb+1] = n

    --         if n.expire_time > now then
    --             local cfg = _cfg.dress(type,id)
    --             if cfg then
    --                 glamours = glamours + cfg.glamours
    --             end
                
    --         end
    --     end
    -- end

    -- local level = self:calcGlamourLevel(glamours)
    -- if self._glamours.value ~= glamours or self._glamours.level ~= level then
    --     self._glamours.value = glamours
    --     self._glamours.level = level
    --     self:sendGlamourInfo()
    -- end
    --self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_MEILI, self._glamours.level, 1, 1)
end

function dress_module:calcGlamourLevel(data)
    local i = 0
    local level = 0
    repeat
        i = i + 1
        local cfg = _cfg.glamour(i)
        if cfg then
            if data >= cfg.glamours then
                level = cfg.level
            else
                i = 9999
            end          
        end
    until (cfg==nill or i==9999)
    return level
end

function dress_module:sendGlamourInfo()
    local pb = {
        self._glamours.value,
        self._glamours.level
	}
	self:sendMsg(_sm.SM_GLAMOUR_INFO,{i32=pb},"ProtoInt32Array")
end

function dress_module:sendWearDressInfo()
    local pb = {}
    for _, v in pairs(self._dressWear.wearInt) do
        pb[#pb+1] = v
    end
	self:sendMsg(_sm.SM_WEAR_DRESS,{i32=pb},"ProtoInt32Array")
end

function dress_module:sendDressInfo(info)
	local pb = {}
	if info then
		pb[#pb+1] = info
	else
		for _, v in pairs(self._dress) do
            for _, n in pairs(v) do
                pb[#pb+1] = n
            end
		end
	end

	self:sendMsg(_sm.SM_DRESS_INFO,{data=pb},"SmDressInfo")
end

function dress_module:unlockDress(type,id,access)
    local card = {
        cid = self.cid,
        type = type,
        id = id,
        expire_time = 0,
    }
    if self._dress[type] == nil then
        self._dress[type] = {}
    end

    local cfg = _cfg.dress(type,id)
	if cfg==nil then
		return
	end

    local cost = {}
    local now = _func.getNowSecond()
    if access==1 then --体验卡
        if self._dress[type][id]~=nil then
            if self._dress[type][id].expire_time == -1 then
                --消耗一张时装券，返还25%时装券
                if cfg.item[1][1] == nil then
                    return
                end
                cost[1] = _func.make_cfg_item_one(cfg.try_id,_IT.IT_ITEM,1)
                --cost[2] = _func.make_cfg_item_one(cfg.item[1][1],_IT.IT_ITEM,1)
                if not self:delBagCheck(cost) then
                    return
                end
                self:delBag(cost,CHANGE_REASON.CR_DRESS)

                local add = {}
                for k, v in ipairs(cfg.item) do
                    local item_id = v[1]
                    local num = math.ceil(v[3] * cfg.return_rate*0.01)
                    add[#add+1] = _func.make_cfg_item_one(item_id,_IT.IT_ITEM,num)
                end
                if not self:addBagCheck(add) then
                    return
                end
                self:addBag(add,CHANGE_REASON.CR_DRESS)
                card.expire_time = -1
            else
                --限时解锁
                cost[1] = _func.make_cfg_item_one(cfg.try_id,_IT.IT_ITEM,1)
                if not self:delBagCheck(cost) then
                    return
                end
                self:delBag(cost,CHANGE_REASON.CR_DRESS)
                card.expire_time = now + 86420 * 30
            end
        else
            --限时解锁
            cost[1] = _func.make_cfg_item_one(cfg.try_id,_IT.IT_ITEM,1)
            if not self:delBagCheck(cost) then
                return
            end
            self:delBag(cost,CHANGE_REASON.CR_DRESS)
            card.expire_time = now + 86420 * 30
        end
    elseif access==2 then --时装券或魂钻
        if self._dress[type][id]~=nil then
            if self._dress[type][id].expire_time == -1 then
                return
            elseif self._dress[type][id].expire_time > 0 then
                --扣券或者钱 有折扣
                --永久解锁
                local cost = {}
                for k, v in ipairs(cfg.item) do
                    local item_id = v[1]
                    local num = math.ceil(v[3] * cfg.cheap_rate*0.01)
                    cost[#cost+1] = _func.make_cfg_item_one(item_id,_IT.IT_ITEM,num)
                end
                if self:delBagCheck(cost) then
                    self:delBag(cost,CHANGE_REASON.CR_DRESS)
                else
                    cheap = math.ceil(cfg.gold*cfg.cheap_rate*0.01)
                    cost_gold = self:checkCostGold(cheap)
                    if cost_gold == nil then
                        return
                    end
                    self:costGold(cost_gold,CHANGE_REASON.CR_DRESS)
                end
                card.expire_time = -1--now + FOREVER_VAILD_SECOND
            end
        else
            --扣券或者钱
            --永久解锁
            if self:delBagCheck(cfg.item) then
	            self:delBag(cfg.item,CHANGE_REASON.CR_DRESS)
            else
                cost_gold = self:checkCostGold(cfg.gold)
	            if cost_gold == nil then
		            return
	            end
                self:costGold(cost_gold,CHANGE_REASON.CR_DRESS)
            end
            card.expire_time = -1--now + FOREVER_VAILD_SECOND
        end
    else
        return   
    end

    self._dress[type][id] = card
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_DRESS, 1, 1)
    return true
end

function dress_module:onUnlockDress(data)
    if #data.i32 < 3 then
        return
    end
    local type = data.i32[1]
    local id = data.i32[2]
    local access = data.i32[3] --1体验卡 解锁后是限时 2时装券或魂钻 解锁后是永久
    if not self:unlockDress(type,id,access) then
        return
    end

    local dress = self._dress[type][id]
    self:sendDressInfo(dress)
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_dress,dress)
    self:updateGlamours()
end

function dress_module:onWearDress(data)
    if #data.i32 < 3 then
        return
    end
    local type  = data.i32[1]
    local id = data.i32[2]
    if id <= 0 then
        return
    end
    local action = data.i32[3] --1穿戴2脱下
    dressWear = self._dressWear

    local tmp = dressWear.wearInt[type]

    if action == 1 then
        if id == tmp then
            return
        else
            dressWear.wearInt[type] = id
            --self:updateRecord(RECORD_TYPE.RT_DRESS_ID,id)
        end
    elseif action == 2 then
        dressWear.wearInt[type] = 0
        --self:updateRecord(RECORD_TYPE.RT_DRESS_ID,0)
    else
        return
    end  

    dressWear.wear = table.concat(dressWear.wearInt,",");
    self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_dress_wear,self._dressWear)
    self:sendWearDressInfo()
end

return dress_module