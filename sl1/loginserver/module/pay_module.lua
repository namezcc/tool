local _cfg = CFG_DATA
local _sm = SM
local _func = LFUNC
local _table = TABLE_INDEX
local _net_mgr = nil

Card_Month_Id = 10
MAX_ZANZHU_LEVEL = 6
MAX_SIGN_UP_DAY	= 7

local pay_module = {}

function pay_module:isFirstPayDone()
	local first_pay = self:getRecord(RECORD_TYPE.RT_FIRST_PAY)
	if first_pay < 1 then
		return false
	end
	return true
end

function pay_module:isCardMonthPrivate()
	local now = _func.getNowSecond()
	expire_time = self:getRecord(RECORD_TYPE.RT_CART_MOTH_TIME)
	if  expire_time > now then
		return true
	end
	return false
end

function pay_module:updateSignUpInfo()
	chr_sign_up = self._chr_sign_up
	if chr_sign_up == nil then
		return
	end
	if not self._first_sign_up then
		chr_sign_up.days = chr_sign_up.days + 1
	end
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_sign_up,chr_sign_up)
	self:sendSignUpInfo()
end

function pay_module:init()
	_net_mgr = MOD.net_mgr_module

	MSG_FUNC.bind_player_proto_func(CM.CM_CHR_PAY,self.onChrPay,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_GET_CARD_MONTH_REWARD,self.onGetCardMonthReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_ZANZHU,self.onZanzhu,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_GET_SIGN_UP_REWARD,self.onGetSignUpReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_GET_FIRST_PAY_REWARD,self.onGetFirstPayReward,"ProtoInt32")
	MSG_FUNC.bind_player_proto_func(CM.CM_VIR_PLAYER_PAY,self.onChrPayEx,"PayLogVector")
end

function pay_module:initDB(data)
	
    local chr_pay = {}
	if data.chr_pay and table.getn(data.chr_pay)>0 then
		for _, value in ipairs(data.chr_pay) do
			chr_pay[value.id] = table.cloneSimple(value)
		end
	else
		chr_pay = {
			{cid = self.cid, id = 0,buy_count = 0},
		}

	end

	self._chr_pay = chr_pay
	self:sendChrPayInfo()

	self._first_sign_up = false

	local chr_sign_up = {}
	if _func.checkPlayerData(data.chr_sign_up) then
		chr_sign_up = data.chr_sign_up
	else
		chr_sign_up = {
			cid = self.cid,
			days = 1,
			state = 0,
		}
		self._first_sign_up = true
		self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_sign_up,chr_sign_up)
	end

	self._chr_sign_up = chr_sign_up
	--self:sendSignUpInfo()
end

function pay_module:afterInit()
end

function pay_module:sendSomePayInfo()
	self:sendSignUpInfo()
	self:sendCardMonthInfo()
	self:sendZanzhuInfo()
	self:sendFirstPayInfo()
end

function pay_module:sendChrPayInfo(info)
	local pb = {}
	if info then
		pb[#pb+1] = info
	else
		for _, v in pairs(self._chr_pay) do
            pb[#pb+1] = v
		end
	end

	self:sendMsg(_sm.SM_CHR_PAY,{data=pb},"SmChrPayInfo")
end

function pay_module:sendCardMonthInfo()
	local pb = {
        get_state = self:getRecord(RECORD_TYPE.RT_DAILY_GET_CARD_REWARD),
        expire_time = self:getRecord(RECORD_TYPE.RT_CART_MOTH_TIME)
	}
	self:sendMsg(_sm.SM_CARD_MONTH_INFO,pb,"SmCardMonthInfo")
end

function pay_module:sendZanzhuInfo()
	local pb = {
		i32 = self:getRecord(RECORD_TYPE.RT_ZANZHU_LEVEL)
	}
	self:sendMsg(_sm.SM_ZANZHU_INFO,pb,"ProtoInt32")
end

function pay_module:sendFirstPayInfo()
	local pb = {
		i32 = self:getRecord(RECORD_TYPE.RT_FIRST_PAY)
	}
	self:sendMsg(_sm.SM_FIRST_PAY,pb,"ProtoInt32")
end

function pay_module:sendSignUpInfo()
	local pb = {
		self._chr_sign_up.days,
		self._chr_sign_up.state,
	}
	self:sendMsg(_sm.SM_SIGN_UP_INFO,{i32=pb},"ProtoInt32Array")
end

function pay_module:productBy(id,gold)
	if id <= 0 then
		return
	end

	local cfg = _cfg.pay_product(id)
	if cfg == nil then
		return 1
	end

	local card_time = 0
	if id == Card_Month_Id then
		local now_zero = TIME_UTIL.day_zero(_func.getNowSecond())
		card_time = self:getRecord(RECORD_TYPE.RT_CART_MOTH_TIME)
		if card_time < now_zero then
			card_time = now_zero
		end

		local diff_time = card_time - now_zero
		if diff_time > 86400 * 30 * 11 then
			return 1
		end
	end

	local chr_pay = {}
	if self._chr_pay[id] then
		chr_pay = self._chr_pay[id]
		chr_pay.id = id
	else
		chr_pay = {cid = self.cid, id = id, buy_count = 0}
		self._chr_pay[id] = chr_pay
	end

    chr_info = self._chr_info
    if chr_pay.buy_count < 1 then
		self:addGold(0, cfg.gold_bind, CHANGE_REASON.CR_CHR_PAY)
        --chr_info.gold_bind = chr_info.gold_bind + cfg.gold_bind
    end
	chr_pay.buy_count = chr_pay.buy_count + 1
    --chr_info.gold_unbind = chr_info.gold_unbind + cfg.gold_unbind
	self:addGold(cfg.gold_unbind, 0, CHANGE_REASON.CR_CHR_PAY)

	--道具奖励
	if cfg.reward then
		self:addBagOrSendMail(cfg.reward,CHANGE_REASON.CR_CHR_PAY)
	end

	self:sendChrPayInfo(chr_pay)
	--self:sendPlayerInfo()
	self:dbUpdateData(_table.TAB_mem_chr_pay,chr_pay)
	--self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
	
	if id == Card_Month_Id then
		self:updateRecord(RECORD_TYPE.RT_CART_MOTH_TIME,card_time + 86400 * 30)
		self:sendCardMonthInfo()
	elseif id == 11 or id == 12 or id == 13 then
		local buyTp = 1
		if id == 12 then
			buyTp = 2
		elseif id == 13 then
			buyTp = 3
		end
		local check = false
		if self:checkBuyWarToken(buyTp) then
			local buy = 1
			if id == 12 or id == 13 then
				buy = 2
			end
			if self:buyWarToken(buy) then
				check = true
			end
		end
		if not check then -- 直购失败,补偿等价钻石
			--self:addGold(cfg.rmb / cfg.rate, 0, CHANGE_REASON.CR_CHR_PAY)
			return 1
		end
	end

	-- ::pay_label::
	-- self:addGold(gold, 0, CHANGE_REASON.CR_CHR_PAY)
end

function pay_module:userAddGold(data)
	local gold_pay = 0
	for _, val in ipairs(data) do
		gold_pay = gold_pay + val.gold
	end
	self:addGold(gold_pay, 0, CHANGE_REASON.CR_CHR_PAY)
end

function pay_module:onChrPayEx(d)
    if #d.data <= 0 then
        return
    end

	local direct_ids = {}
	local gold_ids = {}
	for _, val in ipairs(d.data) do
		-- if self._payIds then
		-- 	local bfind = false
		-- 	for _, val_inner in ipairs(self._payIds) do
		-- 		if val.id == val_inner.id then
		-- 			bfind = true
		-- 		end
		-- 	end
		-- 	if not bfind then
		-- 		if val.product>0 then
		-- 			--直购
		-- 			direct_ids[#direct_ids+1] = val
		-- 		else
		-- 			--非直购加充值货币
		-- 			gold_ids[#gold_ids+1] = val
		-- 		end
		-- 		self._payIds[#self._payIds+1] = val
		-- 	end
		-- else
			if val.product>0 then
				--直购
				direct_ids[#direct_ids+1] = val
			else
				--非直购加充值货币
				gold_ids[#gold_ids+1] = val
			end
			val.log = self.cid
		--	self._payIds[#self._payIds+1] = val
		-- end
	end

	if table.getn(direct_ids)>0 then
		local id = 0
		for _, val in ipairs(direct_ids) do
			id = val.product
			gold = val.gold
			local r = self:productBy(id,gold)
			if r==1 then 
				--补偿钻石
				self:addGold(gold, 0, CHANGE_REASON.CR_CHR_PAY)
			end
		end
	end

	if table.getn(gold_ids)>0 then
		self:userAddGold(gold_ids)
	end
	_net_mgr:sendToDBMsg(self.db_serid,SERVER_MSG.IM_DB_UPDATE_PAY_LOG,d,"PayLogVector")
end

function pay_module:onChrPay(d)
    if d == nil or d.i32 == nil then
        return
    end
    local id = d.i32
	if id <= 0 then
		return
	end

	local now = _func.getNowSecond()
	local card_time = self:getRecord(RECORD_TYPE.RT_CART_MOTH_TIME)
	if card_time < now then
		card_time = now
	end
	if id == Card_Month_Id then
		local diff_time = card_time - now
		if diff_time > 86400 * 30 * 11 then
			return
		end
	end


	local chr_pay = {}
	if self._chr_pay[id] then
		chr_pay = self._chr_pay[id]
		chr_pay.id = id
	else
		chr_pay = {cid = self.cid, id = id, buy_count = 0}
		self._chr_pay[id] = chr_pay
	end
	
	local cfg = _cfg.pay_product(id)
	if cfg == nil then
		return
	end

    chr_info = self._chr_info
    if chr_pay.buy_count < 1 then
        chr_info.gold_bind = chr_info.gold_bind + cfg.gold_bind
    end
	chr_pay.buy_count = chr_pay.buy_count + 1
    chr_info.gold_unbind = chr_info.gold_unbind + cfg.gold_unbind

	--道具奖励
	if cfg.reward then
		if not self:addBagCheck(cfg.reward) then
			return
		end
		self:addBag(cfg.reward,CHANGE_REASON.CR_CHR_PAY)
	end
	
	self:sendChrPayInfo(chr_pay)
    self:sendPlayerInfo()
	self:dbUpdateData(_table.TAB_mem_chr_pay,chr_pay)
	self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)

	if id == Card_Month_Id then
		self:updateRecord(RECORD_TYPE.RT_CART_MOTH_TIME,card_time + 86400 * 30)
		self:sendCardMonthInfo()
	elseif id == 11 or id == 12 or id == 13 then
		local buyTp = 1
		if id == 12 then
			buyTp = 2
		elseif id == 13 then
			buyTp = 3
		end
		local check = false
		if self:checkBuyWarToken(buyTp) then
			local buy = 1
			if id == 12 or id == 13 then
				buy = 2
			end
			if self:buyWarToken(buy) then
				check = true
			end
		end
		if not check then -- 直购失败,补偿等价钻石
			self:addGold(cfg.rmb / cfg.rate, 0, CHANGE_REASON.CR_CHR_PAY)
		end
	end
end

function pay_module:onGetCardMonthReward()
	local now = _func.getNowSecond()
	local card_time = self:getRecord(RECORD_TYPE.RT_CART_MOTH_TIME)
	if card_time < now then
		return
	end

	local state = self:getRecord(RECORD_TYPE.RT_DAILY_GET_CARD_REWARD)
	if state > 0 then
		return
	end

	local cfg = _cfg.pay_product(Card_Month_Id)
	if cfg == nil then
		return
	end

	chr_info = self._chr_info
    chr_info.gold_bind = chr_info.gold_bind + cfg.gold_bind_ev
	self:sendPlayerInfo()
	self:dbUpdateData(_table.TAB_mem_chr,self._chr_info)
	self:updateRecord(RECORD_TYPE.RT_DAILY_GET_CARD_REWARD,1)
	self:sendCardMonthInfo()
end

function pay_module:onZanzhu()
	local zanzhu_lv = self:getRecord(RECORD_TYPE.RT_ZANZHU_LEVEL)
	if zanzhu_lv >= MAX_ZANZHU_LEVEL then
		return
	end

	local cfg = _cfg.zanzhu(zanzhu_lv+1)
	if cfg == nil then
		return
	end

	--扣钱
	cost_gold = self:checkCostGold(cfg.gold_unbind,false)
	if cost_gold == nil then
		return
	end
	self:costGold(cost_gold,CHANGE_REASON.CR_ZANZHU)

	--道具奖励
	if cfg.reward then
		if not self:addBagCheck(cfg.reward) then
			return
		end
		self:addBag(cfg.reward,CHANGE_REASON.CR_ZANZHU)
	end
	
	self:updateRecord(RECORD_TYPE.RT_ZANZHU_LEVEL,zanzhu_lv+1)
	self:sendZanzhuInfo()
end

function pay_module:onGetSignUpReward(d)
	if d == nil or d.i32 == nil then
        return
    end
    local day = d.i32
	if day > MAX_SIGN_UP_DAY then
		return
	end
	
	chr_sign_up = self._chr_sign_up
	if day > chr_sign_up.days then
		return
	end

	local state = chr_sign_up.state
    if _func.is_bit_on(state,day) then
        return
    end

	local cfg = _cfg.sign_up(day)
	if cfg == nil then
		return
	end
	
	if not self:addBagCheck(cfg.reward) then
		return
	end

	self:addBag(cfg.reward,CHANGE_REASON.CR_SIGN_UP)
	state=_func.set_bit_on(state,day)
    chr_sign_up.state = state
	
	self:dbUpdateData(TABLE_INDEX.TAB_mem_chr_sign_up,chr_sign_up)
	self:sendSignUpInfo()

	if self._first_sign_up then
		self._first_sign_up = false
	end
end


function pay_module:onGetFirstPayReward()
	if self:isFirstPayDone() then
		return
	end
	local cfg = _cfg.some_reward(1)
	if cfg == nil then
		return
	end
	
	if not self:addBagCheck(cfg.reward) then
		return
	end

	self:addBag(cfg.reward,CHANGE_REASON.CR_CHR_PAY)
	self:updateRecord(RECORD_TYPE.RT_FIRST_PAY,1)

	self:sendFirstPayInfo()
end

return pay_module