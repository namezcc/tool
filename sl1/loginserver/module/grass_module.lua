local _table = TABLE_INDEX
local _cm = CM
local _sm = SM
local _cfg = CFG_DATA
local _msg_func = MSG_FUNC
local _func = LFUNC
local _record = RECORD_TYPE
local _str_util = STRING_UTIL
local _attr_mod = PLAYER_ATTR_SOURCE

local GRASS_MAX = {
    TYPE = 9,
    GROUP = 5,
}

local grass_module = {}

local function newGrass(cid,type,years,level,star,attr)
    return {
        cid = cid,
        type = type,
        years = years,
        level = level,
        star = star,
        attr = attr,
    }
end

local function getGrass(grass)
    return {
        cid = grass.cid,
        type = grass.type,
        years = grass.years,
        level = grass.level,
        star = grass.star,
        attr = _str_util.splite_int_vec(grass.attr),
    }
end

function grass_module:init()
    _msg_func.bind_player_proto_func(_cm.CM_GRASS_UPGRADE, self.onGrassUpgrade, "ProtoInt32Array")
end

function grass_module:initDB(data)
    self._grass = {}
    if data.grass ~= nil then
        for _, value in ipairs(data.grass) do
            self._grass[value.type] = getGrass(value)
        end
    end
end

function grass_module:afterInit()
    self:sendGrassInfo(0)
    self:updateModuleAttr(_attr_mod.PAS_GRASS,true)
end

function grass_module:calcGrassAttr()
    local grass = self._grass
    if grass == nil then
        return
    end
    local attr = {}
    for _, value in pairs(grass) do
        local lvattr = {}
        if value.type > 0 and value.level > 0 then
            lvattr[#lvattr+1] = {ATTR_TYPE.ATTR_TIZHI,1,value.attr[1]}
            lvattr[#lvattr+1] = {ATTR_TYPE.ATTR_LILIANG,1,value.attr[2]}
            lvattr[#lvattr+1] = {ATTR_TYPE.ATTR_MINJIE,1,value.attr[3]}
            lvattr[#lvattr+1] = {ATTR_TYPE.ATTR_ZHIHUI,1,value.attr[4]}
            lvattr[#lvattr+1] = {ATTR_TYPE.ATTR_JINGSHEN,1,value.attr[5]}

            _func.combindAttr(attr, lvattr)
        end
        if value.type > 0 and value.star > 0 then
            local stCfg = _cfg.grass_star(value.type, value.star)
            if stCfg ~= nil and stCfg.attr ~= nil then
                _func.combindAttr(attr, stCfg.attr)
            end
        end
    end
    for group = 1, GRASS_MAX.GROUP, 1 do
        local level = self:getRecord(_record.RT_GRASS_GROUP_LEVEL_BEGIN+group)
        if level > 0 then
            local gpCfg = _cfg.grass_group(group,level)
            if gpCfg ~= nil and gpCfg.attr ~= nil then
                _func.combindAttr(attr, gpCfg.attr)
            end
        end
    end
    return attr
end

function grass_module:onGrassUpgrade(data)
    local param = data.i32[1]  --1.level,2.star,3.group
    local type = data.i32[2]

    if param ~= 1 and param ~= 2 and param ~= 3 then
        return
    end

    if param == 1 then
        self:grassLevelUpgrade(type)
    elseif param == 2 then
        self:grassStarUpgrade(type)
    elseif param == 3 then
        self:grassGroupUpgrade(type)
    end
end

function grass_module:grassLevelUpgrade(type)
    if type < 1 or type > GRASS_MAX.TYPE then
        return
    end
    local grass = self._grass[type]
    if grass == nil then--激活仙草
        local iCfg = _cfg.grass_level(type, 0)
        if iCfg == nil then
            return
        end
        if not self:delBagCheck(iCfg.item) then
            return
        end

        self:delBag(iCfg.item,CHANGE_REASON.CR_GRASS_UPGRADE)

        local attr = {0,0,0,0,0}
        for _, v in pairs(iCfg.max_attr) do
            if v[1] == ATTR_TYPE.ATTR_TIZHI then
                attr[1] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_LILIANG then
                attr[2] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MINJIE then
                attr[3] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_ZHIHUI then
                attr[4] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_JINGSHEN then
                attr[5] = v[3]
            end
        end
        self._grass[type] = newGrass(self.cid, type, iCfg.years, 1, 0, attr)
    else
        local iCfg = _cfg.grass_level(grass.type, grass.level)
        if iCfg == nil then
            return
        end

        if grass.years >= iCfg.years then
            iCfg = _cfg.grass_level(grass.type, grass.level+1)
            if iCfg == nil then
                return
            end
            grass.level = grass.level + 1
            self._grass[type].level = grass.level
        end

        if not self:delBagCheck(iCfg.item) then
            return
        end

        local maxAttr = {}
        local maxAttrNum = 0
        for _, v in pairs(iCfg.max_attr) do
            maxAttrNum = maxAttrNum + v[3]

            if v[1] == ATTR_TYPE.ATTR_TIZHI then
                maxAttr[1] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_LILIANG then
                maxAttr[2] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_MINJIE then
                maxAttr[3] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_ZHIHUI then
                maxAttr[4] = v[3]
            elseif v[1] == ATTR_TYPE.ATTR_JINGSHEN then
                maxAttr[5] = v[3]
            end
        end

        local curAttr = {}
        local curAttrNum = 0
        local attrDiff = {}
        local attrDiffIndex = {}
        for i = 1, 5, 1 do
            curAttrNum = curAttrNum + grass.attr[i]
            curAttr[i] = grass.attr[i]
            attrDiff[i] = maxAttr[i] - curAttr[i]
            if attrDiff[i] > 0 then
                attrDiffIndex[#attrDiffIndex+1] = i
            end
        end

        if #attrDiffIndex < 1 or curAttrNum >= maxAttrNum then
            return
        end

        local addNum = iCfg.attr_num / iCfg.count   --单次增加属性点
        if (maxAttrNum - curAttrNum) % iCfg.count ~= 0 then
            addNum = iCfg.attr_num / iCfg.count + iCfg.attr_num % iCfg.count
        end
        addNum = math.ceil(addNum)
        if addNum > maxAttrNum - curAttrNum then
            addNum = maxAttrNum - curAttrNum
        end

        while addNum > 0 do
            local minNum = addNum / #attrDiffIndex
            minNum = math.floor(minNum)
            if minNum < 1 then
                minNum = 1
            end
            local randNum = math.random(minNum,addNum)
            local index = math.random(1,#attrDiffIndex)--随机升级属性项

            if attrDiff[attrDiffIndex[index]] >= randNum then
                attrDiff[attrDiffIndex[index]] = attrDiff[attrDiffIndex[index]] - randNum
            else
                local leftNum = randNum - attrDiff[attrDiffIndex[index]]
                attrDiff[attrDiffIndex[index]] = 0
                table.remove(attrDiffIndex,index)
                local bgindex = index + 1
                if bgindex > #attrDiffIndex then
                    bgindex = 1
                end

                while leftNum > 0 do
                    if attrDiff[attrDiffIndex[bgindex]] >= leftNum then
                        attrDiff[attrDiffIndex[bgindex]] = attrDiff[attrDiffIndex[bgindex]] - leftNum
                        leftNum = 0
                        break
                    else
                        leftNum = leftNum - attrDiff[attrDiffIndex[bgindex]]
                        attrDiff[attrDiffIndex[bgindex]] = 0
                        table.remove(attrDiffIndex,bgindex)
                        bgindex = bgindex + 1
                        if bgindex > #attrDiffIndex then
                            bgindex = 1
                        end
                    end
                end
            end
            addNum = addNum - randNum
        end

        self:delBag(iCfg.item,CHANGE_REASON.CR_GRASS_UPGRADE)

        grass.attr[1] = maxAttr[1] - attrDiff[1]
        grass.attr[2] = maxAttr[2] - attrDiff[2]
        grass.attr[3] = maxAttr[3] - attrDiff[3]
        grass.attr[4] = maxAttr[4] - attrDiff[4]
        grass.attr[5] = maxAttr[5] - attrDiff[5]
        self._grass[type].attr = grass.attr

        --years
        for _, v in ipairs(iCfg.item) do
            grass.years = grass.years + iCfg.addon * v[3]
        end
        self._grass[type].years = grass.years

        if grass.years >= iCfg.years then
            local nCfg = _cfg.grass_level(grass.type, grass.level+1)
            if nCfg ~= nil then
                grass.level = grass.level + 1
                self._grass[type].level = grass.level
            end
        end
        self:updateTaskRoundProgress(TASK_ROUND_TYPE.TRT_GRASS_UP, 0, 1)
    end

    self:updateModuleAttr(_attr_mod.PAS_GRASS)
    self:sendGrassInfo(type)
    self:syncGrassChange(type)
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_GRASS, self._grass[type].years / 10000, 1, 1)
end

function grass_module:grassStarUpgrade(type)
    if type < 1 or type > GRASS_MAX.TYPE then
        return
    end
    local grass = self._grass[type]
    if grass == nil then
        return
    end
    local iCfg = _cfg.grass_star(type, grass.star + 1)
    if iCfg == nil or #iCfg.cost == 0 then
        return
    end

    if not self:delBagCheck(iCfg.cost) then
        return
    end

    self:delBag(iCfg.cost,CHANGE_REASON.CR_GRASS_UPGRADE)
    self._grass[type].star = grass.star+1

    self:updateModuleAttr(_attr_mod.PAS_GRASS)
    self:sendGrassInfo(type)
    self:syncGrassChange(type)
end

function grass_module:grassGroupUpgrade(group)
    if group < 1 or group > GRASS_MAX.GROUP then
        return
    end
    local grass = self._grass
    if grass == nil then
        return
    end

    local level = self:getRecord(_record.RT_GRASS_GROUP_LEVEL_BEGIN+group)
    local iCfg = _cfg.grass_group(group, level + 1)
    if iCfg == nil or #iCfg.param == 0 then
        return
    end
    for _, value in pairs(iCfg.param) do
        if value[2] > grass[value[1]].level then
            return
        end
    end

    if iCfg.skill > 0 then
        --激活/升级技能
		self:updateSkill(iCfg.skill,level+1)
    end
    self:addRecord(_record.RT_GRASS_GROUP_LEVEL_BEGIN+group,1)

    self:updateModuleAttr(_attr_mod.PAS_GRASS)
    self:sendGrassInfo(-1)
    self:updateAchievementProgress(ACHIEVEMENT_TYPE.ACH_GRASS_GROUP, group, 1)
end

function grass_module:loadGrassSkill(pdata)
    local pb = pdata.skill_level_info
    for rt = _record.RT_GRASS_GROUP_LEVEL_BEGIN+1, _record.RT_GRASS_GROUP_LEVEL_END, 1 do
        local lv = self:getRecord(rt)
        if lv > 0 then
            local iCfg = _cfg.grass_group(rt - _record.RT_GRASS_GROUP_LEVEL_BEGIN, lv)
            if iCfg ~= nil and iCfg.skill > 0 then
                pb[#pb+1] = {skill_id = iCfg.skill, level = lv, hunyin = {}}
            end
        end
    end
    pdata.skill_level_info = pb
end

function grass_module:sendGrassInfo(type)
    if type < -1 or type > GRASS_MAX.TYPE then
        return
    end
    local grass = self._grass
    if grass == nil then
        return
    end

    local grassPb = {}
    if type == 0 then
        for _, value in pairs(grass) do
            grassPb[#grassPb+1] = value
        end
    elseif type > 0 then
        grassPb[#grassPb+1] = grass[type]
    end

    local suitPb = {}
    if type <= 0 then
        for i = 1, GRASS_MAX.GROUP, 1 do
            local level = self:getRecord(_record.RT_GRASS_GROUP_LEVEL_BEGIN+i)
            if level > 0 then
                local data = {
                    group = i,
                    level = level
                }
                suitPb[#suitPb+1] = data
            end
        end
    end

    if #grassPb > 0 or #suitPb > 0 then
        self:sendMsg(_sm.SM_GRASS_INFO,{grass = grassPb, suit = suitPb},"SmGrassInfo")
    end
end

function grass_module:syncGrassChange(type)
    if type < 1 or type > GRASS_MAX.TYPE then
        return
    end
    local grass = self._grass
    if grass == nil then
        return
    end
    local dbupdate = {
        cid = grass[type].cid,
        type = grass[type].type,
        years = grass[type].years,
        level = grass[type].level,
        star = grass[type].star,
        attr = table.concat(grass[type].attr,':')
    }
    self:dbUpdateData(_table.TAB_mem_chr_grass,dbupdate)
end

return grass_module