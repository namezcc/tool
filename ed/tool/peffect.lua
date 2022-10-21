-- require "split"
math.randomseed(os.time())

local effect = {
{0, "NONE"},
{2, "多重投射"},
{3, "无情打击"},
{4, "分裂"},
{5, "连锁"},
{6, "技能被动释放"},
{7, "范围改变"},
{8,"生命周期改变千分比"},
{12, "元素转化"},
{13, "近射"},
{14, "远射"},
{15, "固定改变伤害"},
{16, "改变触发系数"},
{17, "回响"},
{18, "伤害回血"},
{20, "技能伤害"},
{21, "技能伤害触发异常buff"},
{22, "召唤怪物"},
{23, "范围生效buff"},
{24, "给自己加buff"},
{25, "回血"},
{26, "重生"},
{27, "增加技能等级"},
{28, "属性转换"},
{29, "释放技能消耗生命"},
{30, "击中触发buff"},
{31, "损失的生命提供伤害"},
{32, "击中额外扣血"},
{33, "击杀回血"},
{34, "伤害并附加buff"},
{35, "致死时额外判断"},
{36, "对低生命敌人伤害增加"},
{37, "增加技能充能上限"},
{38, "移动时加buff"},
{39, "没受伤加buff"},
{40, "暴击时加buff"},
{41, "技能伤害转dot"},
{42, "第几次伤害闪避"},
{43,"损失的生命增加移动速度"},
{44,"受伤超过加buff"},
{45,"增加天赋球上限"},
{46,"受击加天赋球"},
{47,"某不同天赋球消失时获得球"},
{48,"格挡时加天赋球"},
{49,"暴击时加天赋球"},
{50,"移动时加随机天赋球"},
{51,"闪避时加天赋球"},
{52,"增加所有天赋球上限"},
{53,"天赋球增加伤害"},
{54,"击杀加随机天赋球"},
{55,"打环技能额外加"},
{56,"受击随机加buff"},
{57,"击中添加对应元素buff"},
{58,"击中添加对应元素以外buff"},
{59,"暴击无视抗性"},
{60,"斩杀低生命怪"},
{61,"给技能目标加buff"},
{62,"前几次技能增加伤害"},
{63,"额外释放技能"},
{64,"增加灵魂回复"},
{65,"增加灵魂额外倍数"},
{66,"获得灵魂"},
{67,"灵魂提供额外回血"},
{68,"给敌人加buff"},
{69,"加天赋球"},
{70,"恢复已损失生命"},
{71,"设置角色状态"},
{72,"吸引角色:引力"},
{73,"异常状态造成额外伤害"},
{74,"过量治疗转成护盾"},
{75,"召唤机关"},
{76,"层数投射物设置buff"},
{77,"buff层数概率减伤"},
{78,"层数投射物增伤"},
{79,"额外范围伤害"},
{80,"设置技能属性"},
{81, "多重释放"},
{82,"dotbuff直接触发所有伤害"},
{83,"改变充能cd"},
{84,"充能一次充满"},
{85,"叠层上限"},
{86,"额外触发叠层"},
{87,"层数触发cd改变"},
{88,"叠层上限比率"},
{89,"自动满层"},
{90,"幻影"},
{91,"叠层增加范围"},

{102,"buff dot伤害"},
{103,"buff护盾"},
{104,"buff持续回血"},

{1022, "变身怪物"},
{1023, "变身人形"},
}

local evtEff = {
{0,"无"},
{1,"对目标造成伤害时 p1.>0 元素判断"},
{2,"击杀敌人时"},
{3,"造成暴击时"},
{4,"受到技能伤害时  p1.值"},
{5,"格挡时"},
{6,"闪避时"},
{7,"受到累计技能伤害 p1.值 p2.0or1 值或千分比"},
{8,"收到暴击时"},
{9,"喝药时"},
{10,"对目标造成伤害时(每个目标只触发一次)"},
{11,"触发元素异常"},
{12,"移动时"},
{13,"停止时"},
{14,"hp大于多少"},
{15,"hp小于多少"},
{16,"受到元素异常"},
{17,"受到元素伤害时"},
{18,"释放持续技能时"},
{19,"持续技能中时"},
{20,"持续技能结束时"},
{21,"获得天赋球"},
{22,"移除天赋球"},
{23,"灵魂大于"},
{24,"每受到某种元素伤害"},
{25,"天赋球满时"},
{26,"击中多少次"},
{27,"释放技能时 p1.>0 某元素"},
{28,"buff层数 p1,>=层数触发"},
{29,"受到技能伤害前"},
{30,"友方死亡"},

}

function peffect()
    local str = "enums="
    for i,v in ipairs(effect) do
        local k = v[1]
        if k ~= 0 then
            str=str.."|"
        end
        str=str..k.."."..v[2]
    end
    print(str)

    str = "enums="

    for i,v in ipairs(evtEff) do
        local k = v[1]
        if k ~= 0 then
            str=str.."|"
        end
        str=str..k.."."..v[2]
    end
    print("\n\n");
    print(str)
end
-- peffect()


-- local tstr = "属性[l][sl:ct]"
-- print(string.match(tstr,"%[sl:(%w+)%]"))


local nowtick = 0
local max_time = 0
local stop_time = 0
local total_value = 700
local MAX_ANGRY = 1200
local old_recover = 100
local new_recover = 100

function tickToAngry( tick,recver )
    return math.floor(tick*recver/ 5000)
end

function angryToTick( angry,recover )
    return math.floor(angry*5000/recover)
end

function getRecover()
    return new_recover
end

function costAngry( angry ,addon)
    total_value = total_value + addon
    if total_value >= angry then
        total_value = total_value - angry
        return angry
    else
        local cost = total_value
        total_value = 0
        return cost
    end
end

function calcAngryMaxTime( addon , stop)
    if addon > 0 then
        if nowtick >= max_time then
            return
        end

        if stop_time > 0 and nowtick >= stop_time then
            return
        end
    end

    local needTick = 0
    local unuseTick = 0
    if stop_time > 0 then
        if nowtick > stop_time then
            needTick = max_time - stop_time
        else
            needTick = max_time - nowtick
            unuseTick = stop_time - nowtick
        end
    else
        needTick = max_time - nowtick
        if max_time > nowtick then
            unuseTick = max_time - nowtick
        end
    end

    if needTick < 0 then needTick = 0 end

    local unuseAngry = tickToAngry(unuseTick,old_recover)

    local needAngry = tickToAngry(needTick,old_recover)
    local oldAngry = MAX_ANGRY - needAngry

    if addon > 0 then
        if addon > needAngry then
            addon = needAngry
        end
    elseif addon < 0 then
        if -addon > oldAngry then
            addon = -oldAngry
        end
    end

    needAngry = needAngry - addon

    local newrecover = getRecover()
    local maxTick = angryToTick(needAngry,newrecover)

    stop_time = 0
    max_time = nowtick + maxTick

    local cost = needAngry

    if stop ~= nil then
        cost = 0
        stop_time = nowtick
        costAngry(cost,unuseAngry)
    else
        cost = costAngry(cost,unuseAngry)
        stop_time = nowtick + angryToTick(cost,newrecover)

        if stop_time == max_time then
            stop_time = 0
        end
    end

    print(string.format("now:%d  maxt:%d  stop:%d  total:%d  addon:%d cost:%d unuseAngry:%d",nowtick,max_time,stop_time,total_value,addon,cost,unuseAngry))
end

function useSkill()
    if stop_time > 0 then
        return
    end
    if nowtick >= max_time then
        print("use skill ----")
        calcAngryMaxTime(-MAX_ANGRY)
    end
end

-- local addTick = 5000
-- while(true)
-- do
--     nowtick = nowtick + addTick

--     local action = math.random(1,3)

--     if action == 1 then
--         useSkill()
--     elseif action == 2 then
--         -- addAngry
--         calcAngryMaxTime(math.random(1,5)*10)
--     elseif action == 3 then
--         -- 减少
--         calcAngryMaxTime(math.random(1,5)*-10)
--     end

--     if total_value <= 0 then
--         break
--     end
-- end

useSkill()
nowtick = 15000
calcAngryMaxTime(-MAX_ANGRY,true)
calcAngryMaxTime(-MAX_ANGRY)
