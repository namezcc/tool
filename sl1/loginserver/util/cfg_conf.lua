-- 只需填一个位置
-- 需要导入的表
local cfgfile = {
	"item",
	"level",
	"task",
	"equip",
	"job",
	"hunhuan",
	"hunhuan_init",
	"spirit",
	"shenqi_qihe",
	"shenqi_star",
	"shenqi_strengthen",
	"neigong_grade",
	"equip_jinglian",
	"equip_jinglian_suit",
	"hunhuan_strength",
	"equip_fuling_slot",
	"bone",
	"bone_strong",
	"bone_jinglian",
	"bone_star",
	"bone_hunsui",
	"monster",
	"common_group_drop",
	"hunyin",
	"hunhuan_description",
	"core",
	"baoxiang",
	"baoxiang_refresh",
	"item_compose",
	"anqi",
	"hunqi",
	"hunqi_god_attr",
	"danyao",
	"danyao_cost",
	"skill2",
	"hunyin_slot",
	"wuhun",
	"hunhuan_break",
	"bone_hunsui_unlock",
	"hunqi_level",
	"bone_order_upgrade",
	"wing_strong",
	"wing_fuling",
	"exp_item",
	"element_bow_suit",
	"medal",
	"vit_task",
	"vit_gift",
	"shop_mall",
	"shop_common",
	"cook",
	"index_number",
	"achievement",
	"achievement_task",
	"collection_self",
	"tujian",
	"tujian_npc",
	"tujian_monster",
	"tujian_baibao",
	"tujian_map",
	"tujian_story",
	"vit_total_gift",
	"mail",
	"position_reward",
	"hunshiroad",
	"pay_product",
	"task_random",
	"draw_up_active",
	"zanzhu",
	"zanzhu_tequan",
	"sign_up",
	"some_reward",
	"task_group",
	"task_baoxiang",
	"task_branch",
	"task_zhuanji",
	"common_reward",
	"zz_task",
	"zz_task_round_reward",
	"war_token",
	"task_war_token",
	"family_donate_item",
	"family_send",
	"glamour",
	"map",
	"map_monster",
	"hunshi_name",
	"tili",
	"new_open",
	"shili_level",
	"hunyin_level",
	"dungeon",
	"item_compose_unlock",
	"food_full_value",
	"map_explore",
}

-- 多级的table -> 对应单条数据
local nmapconf = {
	["wuhun_jinhua"] = {"job","level"},
	["wuhun_juexing"] = {"job","level"},
	["wuhun_strong"] = {"job","level"},
	["equip_strong"] = {"type","level"},
	["equip_strong_attr"] = {"equip_job","type","level"},
	["equip_jinglian"] = {"type","level"},
	["equip_star"] = {"type","order","level"},
	["equip_star_attr"] = {"type","level"},
	["grass_level"] = {"type","level"},
	["grass_star"] = {"type","star"},
	["grass_group"] = {"group","level"},
	["neigong_level"] = {"type","level"},
	["tianfu"] = {"branch","page"},
	["tianfu_point"] = {"branch","page","index"},
	["hunhuan_description"] = {"hunhuanindex","job"},
	["core_level"] = {"order","level"},
	["anqi_strong"] = {"id","level"},
	["anqi_order"] = {"id","level"},
	["anqi_skill"] = {"id","level"},
	["anqi_jinglian"] = {"id","level"},
	["anqi_star"] = {"id","level"},
	["bone_hunsui_attr"] = {"id","level"},
	["hunqi_strong_attr_level"] = {"id","level"},
	["danyao_cost"] = {"itemid","hunshi"},
	["life_skill"] = {"type","level"},
	["bone_strong_attr"] = {"equip_job","type","level"},
	["hunyin_slot"] = {"hunhuan_id", "num"},
	["hunhuan_break"] = {"job", "level"},
	["hunqi_strong_attr_rand"] = {"type","attr_type" ,"level"},
	["wing_star"] = {"job", "level"},
	["wing_fuling_attr"] = {"id", "level"},
	["wing_star_skill"] = {"job", "level"},
	["wing_order"] = {"job", "level"},
	["element_bow"] = {"type","level"},
	["position"] = {"level","star"},
	["tujian_affinity"] = {"id","affi_lv"},
	["tujian_jiban"] = {"id","jb_lv"},
	["tujian_cognition"] = {"id","cogni_lv"},
	["tujian_gift"] = {"id","index"},
	["family_build_level"] = {"type","level"},
	["family_active_reward"] = {"type","id"},
	["dress"] = {"type","id"},
	["tujian_score"] ={"group","type","quality","level"},
	["hunqi_master_attr"] = {"type","qulity","level"},
}

-- 多级table -> 对应vec 一组数据
-- [tabname] = {key1,...}
local nmapvecconf = {
	["drop_group"] = {"group_id"},
	["hunqi_strong_attr"] = {"group"},
	["bone_suit"] = {"type"},
	["anqi_suit"] = {"type","qulity"},
	["bone_num_suit"] = {"id"},
	["hunqi_base_attr"] = {"type"},
	["hunqi_suit"] = {"id"},
	["fish_drop"] = {"group"},
	["tujian_gift_group"] = {"id"},
	["tujian_gift_group_item"] ={"group"},
	["draw_group"] = {"group"},
	["draw_pool"] = {"pool_id"},
	["draw_rate_func"] = {"id"},
}



local i = "i" 	-- P_Int,
local s = "s" 	-- P_String,
local v = "v" 	-- P_Vec,
local t = "t" 	-- P_Table,
local vv = "vv" 	-- P_VecVec,
local vt = "vt" 	-- P_VecTable,
local ct = "ct" 	-- P_ComplexTable,

-- 表需要导出的字段,可以在配置表里配置,也可以在这里配置
--["tabname"] = { fname = "type",...}
-- 示例
-- equip_jinglian_suit = {
-- 	level = i,
-- 	attr_def = vv,
-- 	attr_atk = vv,
-- }
local needfield = {
}




local allfile = {}
for i, f in ipairs(cfgfile) do
	allfile[f] = true
end
for k, v in pairs(nmapconf) do
	allfile[k] = true
end
for k, v in pairs(nmapvecconf) do
	allfile[k] = true
end

cfgfile = {}

for f, _ in pairs(allfile) do
	cfgfile[#cfgfile+1] = f
end

return {
	cfgfile = cfgfile,
	nmapconf = nmapconf,
	nmapvecconf = nmapvecconf,
	needfield = needfield,
}