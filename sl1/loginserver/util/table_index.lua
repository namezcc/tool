--文件由配置生成,请执行server/bin/tool/genProtoDb.bat 在proto_db_conf.lua里配置
TABLE_INDEX = {
TAB_mem_chr=1,
TAB_mem_chr_storage=2,
TAB_mem_unique_equip=3,
TAB_mem_chr_hunhuan=4,
TAB_mem_chr_spirit=5,
TAB_mem_chr_shenqi_qihe=6,
TAB_mem_chr_shenqi_strengthen=7,
TAB_mem_chr_shenqi_star=8,
TAB_mem_chr_shenqi_pray=9,
TAB_mem_chr_task_trunk=10,
TAB_mem_chr_record=11,
TAB_mem_chr_neigong=12,
TAB_mem_chr_tianfu=13,
TAB_mem_chr_wuhun=14,
TAB_mem_unique_pet=15,
TAB_mem_chr_pet=16,
TAB_mem_chr_grass=17,
TAB_mem_unique_bone=18,
TAB_mem_unique_core=19,
TAB_mem_chr_item=20,
TAB_mem_chr_baoxiang_group=21,
TAB_mem_chr_baoxiang_task=22,
TAB_mem_chr_baoxiang=23,
TAB_mem_chr_anqi=24,
TAB_mem_unique_common=25,
TAB_mem_chr_danyao=26,
TAB_mem_chr_lifeskill=27,
TAB_mem_chr_equip_make=28,
TAB_mem_chr_wing=29,
TAB_mem_chr_client_record=30,
TAB_mem_chr_ebow=31,
TAB_mem_chr_position=32,
TAB_mem_chr_vit_task=33,
TAB_mem_chr_vit_gift=34,
TAB_mem_chr_shop_limit=35,
TAB_mem_chr_position_reward=36,
TAB_mem_chr_achievement=37,
TAB_mem_chr_achievement_task=38,
TAB_mem_chr_collection=39,
TAB_mem_chr_tujian=40,
TAB_mem_chr_tujian_total=41,
TAB_mem_chr_mail=42,
TAB_server_mail=43,
TAB_mem_chr_server_mail=44,
TAB_mem_chr_relation=45,
TAB_mem_chr_level_gift=46,
TAB_mem_chr_pay=47,
TAB_mem_chr_task_random=48,
TAB_mem_chr_sign_up=49,
TAB_mem_chr_task_branch=50,
TAB_mem_chr_task_zhuanji=51,
TAB_mem_family=52,
TAB_mem_family_member=53,
TAB_mem_family_apply=54,
TAB_mem_family_event=55,
TAB_mem_chr_task_round=56,
TAB_mem_chr_arena=57,
TAB_mem_chr_dress=58,
TAB_mem_chr_war_token=59,
TAB_mem_chr_task_war_token=60,
TAB_mem_chr_family_send=61,
TAB_mem_family_red_packet=62,
TAB_mem_family_red_packet_record=63,
TAB_mem_chr_dress_wear=64,
TAB_mem_chr_drow_item=65,
TAB_mem_chr_offline_event=66,
TAB_mem_chr_friend_like=67,
TAB_mem_chr_face=68,
TAB_mem_chr_collection_forever=69,
TAB_mem_chr_monster_drop=70,
TAB_mem_chr_no_redis=71,
TAB_log_draw_card=1001,
TAB_log_useitem=1002,
}
TABLE_PROTO_NAME = {
	[1]="Proto.DBChrInfo",
	[2]="Proto.DB_chr_storage",
	[3]="Proto.PmEquipInfo",
	[4]="Proto.DB_chr_hunhuan",
	[5]="Proto.DBChrSpirit",
	[6]="Proto.DBShenQiData",
	[7]="Proto.DBShenQiData",
	[8]="Proto.DBShenQiData",
	[9]="Proto.DBShenQiPray",
	[10]="Proto.DB_chr_task_trunk",
	[11]="Proto.DB_chr_record",
	[12]="Proto.DB_chr_neigong",
	[13]="Proto.DB_chr_tianfu",
	[14]="Proto.DB_chr_wuhun",
	[15]="Proto.PmPetInfo",
	[16]="Proto.DB_chr_pet",
	[17]="Proto.DB_chr_grass",
	[18]="Proto.PmBoneInfo",
	[19]="Proto.PmMonsterCoreInfo",
	[20]="Proto.DB_chr_item",
	[21]="Proto.DB_chr_baoxiang_group",
	[22]="Proto.DB_chr_baoxiang_task",
	[23]="Proto.DB_chr_baoxiang",
	[24]="Proto.DB_chr_anqi",
	[25]="Proto.MemUniqueCommon",
	[26]="Proto.DB_chr_danyao",
	[27]="Proto.DB_chr_lifeskill",
	[28]="Proto.DB_chr_equip_make",
	[29]="Proto.DB_chr_wing",
	[30]="Proto.DB_chr_client_record",
	[31]="Proto.DB_chr_elementbow",
	[32]="Proto.DB_chr_position",
	[33]="Proto.DB_chr_vit_task",
	[34]="Proto.DB_chr_vit_gift",
	[35]="Proto.DB_chr_shop_limit",
	[36]="Proto.DB_chr_position_reward",
	[37]="Proto.DB_chr_achievement",
	[38]="Proto.DB_chr_achievement_task",
	[39]="Proto.DB_chr_collection",
	[40]="Proto.DB_chr_tujian",
	[41]="Proto.DB_chr_tujian_total",
	[42]="Proto.MemChrMail",
	[43]="Proto.MemChrMail",
	[44]="Proto.DB_chr_server_mail",
	[45]="Proto.DB_chr_relation",
	[46]="Proto.DB_chr_level_gift",
	[47]="Proto.DB_chr_pay",
	[48]="Proto.DB_chr_task_random",
	[49]="Proto.DB_chr_sign_up",
	[50]="Proto.DB_chr_task_branch",
	[51]="Proto.DB_chr_task_zhuanji",
	[52]="Proto.DB_mem_family",
	[53]="Proto.DB_mem_family_member",
	[54]="Proto.DB_mem_family_apply",
	[55]="Proto.DB_mem_family_event",
	[56]="Proto.DB_chr_task_round",
	[57]="Proto.DB_chr_arena",
	[58]="Proto.DB_chr_dress",
	[59]="Proto.DB_chr_war_token",
	[60]="Proto.DB_chr_task_war_token",
	[61]="Proto.DB_mem_chr_family_send",
	[62]="Proto.DB_mem_family_red_packet",
	[63]="Proto.DB_mem_family_red_packet_record",
	[64]="Proto.DB_chr_dress_wear",
	[65]="Proto.DB_chr_drow_item",
	[66]="Proto.DB_chr_offline_event",
	[67]="Proto.DB_chr_friend_like",
	[68]="Proto.DB_chr_face",
	[69]="Proto.DB_chr_collection_forever",
	[70]="Proto.DB_chr_monster_drop",
	[71]="Proto.DB_chr_no_redis",
	[1001]="Proto.log_draw_card",
	[1002]="Proto.log_useitem",

}
REDIS_KEY = {
	[1]={},
	[2]={"storage","slot",},
	[3]={},
	[4]={"hunhuan_id",},
	[5]={},
	[6]={},
	[7]={},
	[8]={},
	[9]={},
	[10]={"tid",},
	[11]={"type",},
	[12]={},
	[13]={"branch","page",},
	[14]={},
	[15]={},
	[16]={"pid",},
	[17]={"type",},
	[18]={},
	[19]={},
	[20]={"item",},
	[21]={"group",},
	[22]={"tid",},
	[23]={"bid",},
	[24]={"id",},
	[25]={},
	[26]={"did",},
	[27]={},
	[28]={"type","id",},
	[29]={},
	[30]={"type",},
	[31]={},
	[32]={},
	[33]={"tid",},
	[34]={},
	[35]={"shop_id",},
	[36]={},
	[37]={},
	[38]={"tid",},
	[39]={"id",},
	[40]={"group","id",},
	[41]={},
	[42]={},
	[43]={},
	[44]={"id",},
	[45]={"rcid",},
	[46]={"level",},
	[47]={"id",},
	[48]={"ttype","tid",},
	[49]={},
	[50]={"tid",},
	[51]={"tid",},
	[52]={},
	[53]={},
	[54]={},
	[55]={},
	[56]={"round","tid",},
	[57]={},
	[58]={"type","id",},
	[59]={"season",},
	[60]={"tid",},
	[61]={"type",},
	[62]={},
	[63]={},
	[64]={},
	[65]={},
	[66]={},
	[67]={},
	[68]={},
	[69]={"id",},
	[70]={"monster",},
	[71]={},
	[1001]={},
	[1002]={},
}