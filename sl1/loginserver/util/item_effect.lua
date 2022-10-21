local _cfg = CFG_DATA

local item_effect = {}

item_effect[ITEM_SUB_TYPE.TEST] = function (player,id,count,cfg)
	


	return true
end

item_effect[ITEM_SUB_TYPE.ADD_BUFF] = function (player,id,count,cfg)
	if count > 1 then
		return false
	end

	if #cfg.effect ~= 2 then
		return false
	end

	local foodcfg = _cfg.food_full_value(id)
	if foodcfg then
		if not player:eatFood(foodcfg.value) then
			return false
		end
	end

	local pb = {
		data1 = cfg.effect[1],
		data2 = cfg.effect[2],
	}

	player:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_ADD_BUFF,{list={pb}},"ProtoPairInt32Array")
	return true
end

item_effect[ITEM_SUB_TYPE.ADD_ATTR] = function (player,id,count,cfg)
	if count > 1 then
		return false
	end

	local len = #cfg.effect

	if len <= 0 or len%2 == 1 then
		return false
	end

	local foodcfg = _cfg.food_full_value(id)
	if foodcfg then
		if not player:eatFood(foodcfg.value) then
			return false
		end
	end
	
	player:sendMsgToGame(SERVER_MSG.IM_GAME_PLAYER_ADD_ATTR,{i32 = cfg.effect},"ProtoInt32Array")
	return true
end

item_effect[ITEM_SUB_TYPE.NEILI] = function (player, id, count, cfg)
	if count < 1 then
		return false
	end
	if #cfg.effect ~= 1 then
		return false
	end
	player:addNeili(cfg.effect[1] * count, true)
	return true
end

item_effect[ITEM_SUB_TYPE.TILI] = function (player, id, count, cfg)
	if count < 1 then
		return false
	end
	if #cfg.effect ~= 1 then
		return false
	end
	player:addCurrency(CURRENCY_TYPE.CT_NHHY, cfg.effect[1] * count, CHANGE_REASON.CR_ITEM_ADD_NHHY)
	return true
end

item_effect[ITEM_SUB_TYPE.ITEM_EXP] = function (player, id, count, cfg)
	if count < 1 then
		return false
	end
	if #cfg.effect ~= 1 then
		return false
	end
	local exp = cfg.effect[1]*count
	player:addExp(exp, CHANGE_REASON.CR_USE_ITEM)
	return true
end

return item_effect