local _cfg = CFG_DATA
local _sm = SM
local _table = TABLE_INDEX
local _msg_func = MSG_FUNC
local _string_util = STRING_UTIL
local _func = LFUNC
local _time = TIME_UTIL

local MAX_WAR_TOKEN_LEVEL = 100
local MAX_WAR_TOKEN_ROUND_EXP = 20000
local WAR_TOKEN_SEASON_DAY = 40
local WAR_TOKEN_ROUND_DAY = 7
local wartoken_module = {}

local function newWarToken(season, time, round, buy, level, exp, round_exp, free, lock)
    local rd = round or math.floor(_time.day_diff(time) / WAR_TOKEN_ROUND_DAY) + 1
    return {
        season = season,
        time = time,
        round = rd or 1,
        buy = buy or 0,
        level = level or 0,
        exp = exp or 0,
        round_exp = round_exp or 0,
        free = free or {0,0,0,0},
        lock = lock or {0,0,0,0},
    }
end

function wartoken_module:init()
	_msg_func.bind_player_proto_func(CM.CM_WAR_TOKEN_ACT,self.onWarTokenAct,"ProtoInt32Array")
end

function wartoken_module:initDB(data)
	if _func.checkPlayerData(data.war_token) then
		self._war_token = table.cloneSimple(data.war_token)
		self._war_token.free = _string_util.splite_int_vec(self._war_token.free)
		self._war_token.lock = _string_util.splite_int_vec(self._war_token.lock)
    else
		local season = 1
		local time = 1659283200		-- 2022-08-01 00:00:00，应改为开服当日的0点时间戳
		local daydif = _time.day_diff(time)
		if daydif >= WAR_TOKEN_SEASON_DAY then
			local interval = math.floor(daydif / WAR_TOKEN_SEASON_DAY)
			season = season + interval
			time = time + interval * WAR_TOKEN_SEASON_DAY * 86400
		end
        self._war_token = newWarToken(season, time)
        self:syncWarTokenInfo()
	end
end

function wartoken_module:afterInit()
    self:sendWarTokenInfo()
end

function wartoken_module:onWarTokenAct(data)
	local act = data.i32[1]	-- 1:get gift,2:buy exp
	if act == 1 then
		local level = data.i32[2]
		self:getWarTokenGift(level)
	elseif act == 2 then
		local level = data.i32[2]
		self:buyWarTokenExp(level)
	end
end

function wartoken_module:getWarTokenGift(level)
	if level < 0 or level > MAX_WAR_TOKEN_LEVEL then -- 0:all
		return
	end
	local warToken = self._war_token
	if not warToken then
		return
	end
	if level > warToken.level then
		return
	end
	local lvBegin, lvEnd = level, level
	if level == 0 then
		lvBegin, lvEnd = 1, warToken.level
	end

	for lv = lvBegin, lvEnd, 1 do
		local icfg = _cfg.war_token(lv)
		if icfg then
			local index = math.ceil(lv / 30)
			local bin = lv % 30
			if lv % 30 == 0 then
				bin = 30
			end

			if icfg.free and not _func.is_bit_on(warToken.free[index], bin) then
				if not self:addBagCheck(icfg.free) then
					break
				end
				self:addBag(icfg.free, CHANGE_REASON.CR_WAR_TOKEN)
				warToken.free[index] = _func.set_bit_on(warToken.free[index], bin)
			end

			if icfg.lock and warToken.buy > 0 and not _func.is_bit_on(warToken.lock[index], bin) then
				if not self:addBagCheck(icfg.lock) then
					break
				end
				self:addBag(icfg.lock, CHANGE_REASON.CR_WAR_TOKEN)
				warToken.lock[index] = _func.set_bit_on(warToken.lock[index], bin)
			end
		end
	end
	self._war_token = warToken
	self:syncWarTokenInfo()
	self:sendWarTokenInfo()
end

function wartoken_module:buyWarTokenExp(level)
	if level < 1 or level > MAX_WAR_TOKEN_LEVEL then
		return
	end
	if not self._war_token then
		return
	end
	if not self._war_token.season or self._war_token.season < 1 then
		return
	end
	if self._war_token.level + level > MAX_WAR_TOKEN_LEVEL then
		return
	end
	local cost = self:checkCostGold(200 * level, false)	-- 200钻石/次
	if cost then
		self:costGold(cost, CHANGE_REASON.CR_WAR_TOKEN)
		self:addWarTokenExp(level, 1)
	end
end

function wartoken_module:addWarTokenExp(addon, type)
	local tp = type or 2 -- 1:add level,2:add limit_exp
	if tp ~= 1 and tp ~= 2 then
		return
	end
	if not self._war_token then
		return
	end
	if not self._war_token.season or self._war_token.season < 1 then
		return
	end
	local warToken = self._war_token
	if not warToken then
		return
	end
	if warToken.level == MAX_WAR_TOKEN_LEVEL then
		return
	end

	if tp == 1 then
		local nLv = warToken.level + addon
		if nLv > MAX_WAR_TOKEN_LEVEL then
			nLv = MAX_WAR_TOKEN_LEVEL
		end

		local oldExp = 0
		if warToken.level > 0 then
			local oldCfg = _cfg.war_token(warToken.level)
			if not oldCfg then
				return
			end
			oldExp = oldCfg.exp
		end

		local newCfg = _cfg.war_token(nLv)
		if not newCfg then
			return
		end

		self._war_token.level = nLv
		self._war_token.exp = self._war_token.exp + newCfg.exp - oldExp
	else
		if tp == 2 then
			if warToken.round_exp + addon > MAX_WAR_TOKEN_ROUND_EXP then -- 每周任务获得战令经验上限
				addon = MAX_WAR_TOKEN_ROUND_EXP - warToken.round_exp
			end
			self._war_token.round_exp = self._war_token.round_exp + addon
		end

		self._war_token.exp = self._war_token.exp + addon
		for lv = warToken.level + 1, MAX_WAR_TOKEN_LEVEL, 1 do
			local icfg = _cfg.war_token(lv)
			if not icfg or icfg.exp > self._war_token.exp then
				break
			end
			self._war_token.level = lv
		end
	end
	self:syncWarTokenInfo()
	self:sendWarTokenInfo()
end

function wartoken_module:checkAndResetWartoken()
    if not self._war_token then
        return
    end
	if not self._war_token.season or self._war_token.season < 1 then
		return
	end
    local ddif = _time.day_diff(self._war_token.time)
    if ddif <= 0 then
        return
    elseif ddif >= WAR_TOKEN_SEASON_DAY then
        local interval = math.floor(ddif / WAR_TOKEN_SEASON_DAY)
        local round = math.floor((ddif % WAR_TOKEN_SEASON_DAY) / WAR_TOKEN_ROUND_DAY) + 1
        self:resetWartoken(2, round, interval)
        self:resetTaskWarToken(3)
		self:clearShopLimitCount(SHOP_LIMIT_TYPE.SLT_SEASON)
    else
        local round = math.floor(ddif / WAR_TOKEN_ROUND_DAY) + 1
        if round ~= self._war_token.round then
            self:resetWartoken(1, round)
            self:resetTaskWarToken(2)
        else
            self:resetTaskWarToken(1)
        end
    end
end

function wartoken_module:resetWartoken(type,round,interval)
    local tp = type or 1 -- 1:new week,2:new season
    local rd = round or 1
    if rd < 1 then
        rd = 1
    end
    if not self._war_token then
        return
    end
	if not self._war_token.season or self._war_token.season < 1 then
		return
	end
    if tp == 1 then
        self._war_token.round = rd
        self._war_token.round_exp = 0
    else
        self:syncWarTokenInfo()
        local itv = interval or 1
        local season = self._war_token.season + itv
        local time = self._war_token.time + itv*WAR_TOKEN_SEASON_DAY*86400
        self._war_token = newWarToken(season, time, rd)
    end
	self:syncWarTokenInfo()
    self:sendWarTokenInfo()
end

function wartoken_module:checkBuyWarToken(type)
	if type ~= 1 and type ~= 2 and type ~= 3 then --type 1:(buy)0->1, 2:0->2, 3:1->2
		return false
	end
	if not self._war_token then
		return false
	end
	if not self._war_token.season or self._war_token.season < 1 then
		return false
	end
	if type == 1 or type == 2 then
		if self._war_token.buy ~= 0 then
			return false
		end
	elseif self._war_token.buy ~= 1 then
		return false
	end
	return true
end

function wartoken_module:buyWarToken(buy)
	if buy ~= 1 and buy ~= 2 then
		return false
	end
	if not self._war_token then
		return false
	end
	if not self._war_token.season or self._war_token.season < 1 then
		return false
	end
	if buy == 1 and self._war_token.buy ~= 0 then
		return false
	end
	if buy == 2 and self._war_token.buy == 2 then
		return false
	end
	self._war_token.buy = buy
	if buy == 2 then
		self:addWarTokenExp(10,1) --教皇令直升10级
	end
	self:syncWarTokenInfo()
	self:sendWarTokenInfo()
	return true
end

function wartoken_module:sendWarTokenInfo()
	local warToken = table.clone(self._war_token)
	if not warToken or not warToken.season or warToken.season < 1 then
		return
	end
	self:sendMsg(_sm.SM_WAR_TOKEN_INFO, warToken, "SmWarToken")
end

function wartoken_module:syncWarTokenInfo()
	local warToken = table.clone(self._war_token)
	if not warToken or not warToken.season or warToken.season < 1 then
		return
	end
	local db = warToken
    db.cid = self.cid
    db.free = table.concat(warToken.free, ":")
    db.lock = table.concat(warToken.lock, ":")

    self:dbUpdateData(_table.TAB_mem_chr_war_token, db)
end

return wartoken_module