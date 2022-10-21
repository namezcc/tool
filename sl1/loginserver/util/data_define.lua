STORAGE_TYPE = {
	ST_BAG = 1,
	ST_CHR_EQUIP = 2, 	--装备
	ST_SKILL_SOUL = 3,
	ST_CHR_BONE = 4, 	--魂骨
	ST_CHR_HUNYIN = 5, 	--魂印
	ST_BAG_EQUIP = 6, 	--装备包
	ST_BAG_MATERIAL = 7, --材料包
	ST_BAG_4 = 8,
	ST_WUHUN_HUNQI = 9,	--魂器
}

ITEM_TYPE = {
	IT_ITEM = 1,		-- 物品
	IT_EQUIP = 2,		-- 装备
	IT_BONE = 3,		-- 魂骨
	IT_NO_USE = 4,		-- (占位)
	IT_CORE = 5,		-- 魔核
	IT_ANQI = 6,		-- 暗器
	IT_HUNQI = 7,		-- 魂器

	--实例
	IT_INSTANCE_ITEM = 11,	--物品实例
	IT_INSTANCE_EQUIP = 12,
	IT_INSTANCE_BONE = 13,
	IT_INSTANCE_CORE = 15,
	IT_INSTANCE_HUNQI = 17,
}

ITEM_ID = {
	II_JINHUNBI = 1,	--金魂币
	II_JINHUNBI_2 = 2,	--银魂币
	II_JINHUNBI_3 = 3,	--铜魂币
	II_DRAW_CARD_COIN_1 = 4,
	II_DRAW_CARD_COIN_2 = 5,
	II_HUNSHI_EXP = 9,
	II_DIAMOND = 12,		--钻石
	II_BIND_DIAMOND = 13,	--绑定钻石
	II_TIANFU_POINT_1 = 14,	--天赋点1
	II_TIANFU_POINT_2 = 15,	--天赋点2
	II_TIANFU_POINT_3 = 16,	--天赋点3
	II_NHHY = 22,--凝华魂液
	II_NEILI = 23, --内力
	II_COUNTRY_GOLD_1 = 24,		--势力货币
	II_COUNTRY_GOLD_2 = 25,
	II_COUNTRY_GOLD_3 = 26,
	II_COUNTRY_GOLD_4 = 27,
	II_COUNTRY_GOLD_5 = 28,

	II_COUNTRY_1 = 51,		--势力亲密度
	II_COUNTRY_2 = 52,
	II_COUNTRY_3 = 53,
	II_COUNTRY_4 = 54,
	II_COUNTRY_5 = 55,

	II_DRAW_UP_CARD_ITEM = 202,	--活动抽奖道具
	II_DRAW_CARD_ITEM = 203,	--抽奖道具
}

ITEM_SUB_TYPE = {
	TEST = 1,
	ITEM_EXP = 9,	--经验道具
	ADD_ATTR = 104, --加属性
	ADD_BUFF = 105,	--加buff
	TILI = 106,	--体力
	NEILI = 107,	--内力
	GAO = 13001,	--镐子
	FUTOU = 13101,	--斧头
	YUGAN = 13201,	--鱼竿
	FLOWER = 14571,	--鲜花
}

--货币类型按顺序
CURRENCY_TYPE = {
	CT_JINHUNBI = 1,	--金魂币
	CT_JINHUNBI_2 = 2,	--银魂币
	CT_JINHUNBI_3 = 3,	--铜魂币
	CT_DRAW_CARD_COIN_1 = 4,	--星宇辉印
	CT_DRAW_CARD_COIN_2 = 5,	--神耀辉印
	CT_WAR_TOKEN_COIN = 6,		--战令币
	CT_FAMILY_CONTRIBUTE = 7,	--帮会贡献
	CT_NHHY = 22,	--凝华魂液
	CT_COUNTRY_GOLD_1 = 24,		--势力货币
	CT_COUNTRY_GOLD_2 = 25,
	CT_COUNTRY_GOLD_3 = 26,
	CT_COUNTRY_GOLD_4 = 27,
	CT_COUNTRY_GOLD_5 = 28,

	CT_ADD_EDN = 50,

	CT_DIAMOND = 51,		--充值钻石
	CT_BIND_DIAMOND = 52,	--绑定钻石
}

BIND_TYPE = {
	BT_UNBIND = 0,
	BT_BIND = 1,
}

CHANGE_REASON = {
	CR_CMD = 1,
	CR_HUNHUAN = 2, 	--魂环升级
	CR_MAKE_EQUIP = 3, 	--装备打造
	CR_MOVE_ITEM = 4,	--穿脱格子
	CR_EQUIP_STRONG = 5,	--装备强化
	CR_EQUIP_STRONG_RECYCLE = 6,	--装备强化回收
	CR_EQUIP_JINGLIAN = 7,		--装备精炼
	CR_EQUIP_STAR = 8,		--装备升星
	CR_EQUIP_STAR_RECYCLE = 9,		--装备升星回收
	CR_HUNHUAN_STRENGTH = 10,	--魂环强化
	CR_TIANFU_RESET = 11,	--重置天赋页
	CR_SPIRIT = 12, --神祇
	CR_SHENQI_QIHE = 13, --神器契合
	CR_SHENQI_STRENGTHEN = 14, --神器契合
	CR_SHENQI_STAR = 15, --神器契合
	CR_WUHUN_STRONG = 16,	--武魂强化
	CR_WUHUN_JINGHUA = 17,	--武魂进化
	CR_WUHUN_JUEXING = 18,	--武魂觉醒
	CR_WUHUN_FULING = 19,	--武魂附灵
	CR_EQUIP_FULING_ON = 20,	--装备附灵
	CR_EQUIP_FULING_OFF = 21,	--装备附灵卸下
	CR_USE_ITEM = 22,			--使用物品
	CR_TASK_RECEIVE = 23,		--接任务获得
	CR_TASK_SUBMIT = 24,		--交任务获得
	CR_GRASS_UPGRADE	= 25,	--升级仙草
	CR_BONE_STRONG = 26,		--魂骨强化
	CR_BONE_JINGLIAN = 27,		--魂骨精炼
	CR_BONE_STAR = 28,			--魂骨升星
	CR_BONE_HUNSUI = 29,		--魂骨魂髓
	CR_MONSTER_DROP = 30,		--怪物掉落
	CR_PICK_ITEM = 31,			--拾取
	CR_ITEM_COMPOSE = 32,		--物品合成
	CR_ANQI_STRONG = 33,		--暗器强化
	CR_ANQI_ORDER_UP = 34,		--暗器进阶
	CR_ANQI_SKILL_UP = 35,		--暗器技能
	CR_ANQI_JINGLIAN = 36,		--暗器精炼
	CR_ANQI_STAR = 37,			--暗器升星
	CR_OPEN_BAOXIANG = 38,		--打开宝箱
	CR_HUNQI_STRONG = 39,		--魂器强化
	CR_HUNYIN_PUTON = 40,		--穿魂印
	CR_HUNYIN_PUTDOWN = 41,		--卸魂印
	CR_EAT_DANYAO = 42,			--使用丹药
	CR_HUNYIN_UNLOCK = 43,		--解锁魂印
	CR_HUNHUAN_BREAK_STRENGTH = 44, --突破魂环等级
	CR_BONE_ORDER_UP = 45,		--魂骨升阶
	CR_ITEM_LOCK = 46,			--物品锁定
	CR_CORE_LEVEL_UP = 47,		--魔核升级
	CR_WING_STRONG = 48,		--翅膀强化
	CR_WING_ORDER = 49,			--翅膀升阶
	CR_WING_STAR = 50,			--翅膀升星
	CR_WING_FULING = 51,		--翅膀附灵
	CR_EBOW_LEVEL_UP = 52,		--元素弓升级
	CR_EBOW_SUIT_LV_UP = 53,	--元素弓套装升级
	CR_POSITION_LV_UP = 54,		--爵位升级
	CR_MEDAL_LV_UP = 55,		--勋章升级
	CR_VIT_TASK = 56,			--活跃任务
	CR_VIT_GIFT = 57,			--活跃宝箱
	CR_SHOP_BUY = 58,			--商店购买
	CR_COOK = 59,				--烹饪
	CR_NEIGONG = 60,			--玄天功
	CR_ACHIEVEMENT = 61,		--成就
	CR_COLLECTION = 62,			--采集
	CR_FISH = 63,				--钓鱼
	CR_AFFINITY_UP = 64,		--图鉴亲密度升级
	CR_ACTIVATE_JIBAN = 65,		--图鉴激活羁绊
	CR_GIVE_GIFT = 66,			--图鉴赠送礼物
	CR_INS_RECYCLE = 67,		--回收
	CR_GET_MAIL = 68,			--邮件
	CR_SERVER_MAIL = 69,		--全服邮件
	CR_LEVEL_GIFT = 70,			--等级奖励
	CR_XY_TASK_GIFT = 71,		--学院任务奖励
	CR_DRAW_CARD = 72,			--抽卡
	CR_CHR_PAY = 73,			--充值
	CR_ZANZHU = 74,				--赞助
	CR_SIGN_UP = 75,			--登陆
	CR_CREATE_FAMILY = 76,		--创建帮会
	CR_ZZ_TASK_ROUND_GIFT = 77, --宗族任务
	CR_FAMILY_ACTIVE_REWARD = 78, --帮会活跃
	CR_FAMILY_DONATE = 79,		--帮会捐献
	CR_DRESS = 80,				--时装
	CR_WAR_TOKEN = 81,			--战令
	CR_FAMILY_SEND = 82,		--帮会派遣
	CR_FAMILY_TASK = 83,		--帮会任务
	CR_FAMILY_RED_PACKET = 84,	--帮会红包
	CR_TASK_BACKSPACE = 85,		--任务回退
	CR_ITEM_DELETE = 86,		--主动删除
	CR_TIME_ADD_NHHY = 87,		--按时间增加凝华魂液
	CR_BUY_NHHY = 88,	--购买凝华魂液
	CR_MONSTER_DIG = 89, --挖怪尸体
	CR_FRIEND_SEND_FLOWER = 90,	--送花
	CR_ITEM_ADD_NHHY = 91,	--使用物品增加凝华魂液
	CR_HUNYIN_COMPOSE = 92,	--魂印合成
	CR_ITEM_COMPOSE_UNLOCK = 93,	--配方解锁
	CR_TUJIAN_SCORE_REWARD = 94, --图鉴积分奖励
	CR_HUNQI_GOD_ATTR = 95,		--魂器大师神赐属性
}
-- 错误码
ERROR_CODE = {
	ERR_FAIL = 0,			--失败
	ERR_SUCCESS = 1,		--成功
	ERR_BAG_FULL = 2,		--背包不足 p1:物品类型
	ERR_FAMILY_JOIN_CD = 3,	--加帮会cd
	ERR_FAMILY_SAME_NAME = 4,	--帮会重名
	ERR_TEAM_FAIL = 5,		--组队失败
}

TIME_DATA = {
	TICK_TIME_STAMEP = 0,	--毫秒时间戳
	TIME_STAMEP = 0,			--秒时间戳
}

TASK_CONDITION_TYPE =
{
	TCT_TALK						= 1, --聊天(param:无)
	TCT_REQ_ITEM					= 2, --持有物品(param:id:type:num)
	TCT_USE_ITEM					= 3, --使用物品(param:id:num)
	TCT_KILL_MONSTER_GROUP			= 4, --杀怪(param:id:num)
	TCT_KILL_MONSTER_LEVEL			= 5, --杀怪(param:level:num)
	TCT_PLAYER_LEVEL				= 6, --等级(param:level)
	TCT_CAIJI						= 7, --采集(param:id:num)
	TCT_DIG							= 8, --挖掘(param:id:num)
	TCT_BUILD_ITEM					= 9, --合成(param:id:num)
	TCT_COOK						= 10, --烹饪(param:id:num)
	TCT_USE_DRUG					= 11, --服丹(param:id:num)
	TCT_PASS_DUNGEON				= 12, --副本(param:id:num)
	TCT_EQUIP						= 13, --装备(param:id)
	TCT_KILL_PLAYER					= 14, --PK杀人(param:num)
	TCT_STRENGTH_EQUIP				= 15, --装备强化(param:id:num)
	TCT_HUNHUAN						= 16, --魂环等级(param:id:grade)
	TCT_SKILL_LEVEL					= 17, --技能等级(param:id:level)
	TCT_FRIENDLINES					= 18, --NPC友值(param:id:level)
	TCT_REACH_PLACE					= 19, --地点(param:id)
	TCT_READ						= 20, --阅读书籍(param:id)
	TCT_UNLOCK_MAP					= 21, --地图解锁(param:id)
	TCT_KILL_MONSTER_NUM			= 22, --杀怪(param:id:num)
	TCT_GET_ITEM					= 23, --获取道具(param:id:num)
	TCT_UPGRADE_HUNHUAN				= 24, --魂环升级次数(param:id:num)
	TCT_CLOSE_UI_WINDOW				= 25, --关闭UI界面(param:id)
	TCT_DAZUO 						= 26, --.打坐调息(param:无)
    TCT_REACH_PLACE_TIMER 			= 27, --.在指定区域停留n时间(regionid,时间)
    TCT_FOLLOW_NPC 					= 28, --.跟随npc或者被npc跟随(npcId,1:npc自动行走(玩家跟随npc)2:(npc跟随玩家行走),对话id数组(id:Id:Id))
    TCT_SELL_GOODS 					= 29, --.出售物品(id,number)
	TCT_NPC_ITEM					= 30, --.给NPC物品(npcId:itemId:itemNum)
	TCT_MONSTER_MIN_HP				= 31, --怪物最低血量(param:id)
	TCT_GET_HUNHUAN					= 32, --获得魂环(param:id)
}

TASK_ROUND_TYPE = {
	TRT_HUNSHI_LV = 1,			-- 晋升至魂师等级n级
	TRT_UNLOCK_MAP = 2,			-- 解锁区域地图n块
	TRT_TELEPORT = 3,			-- 激活传送驿站或传送点n个
	TRT_BAOXIANG = 4,			-- 打开宝箱n个
	TRT_COOK = 5,				-- 烹饪获得任意料理n个
	TRT_DANYAO = 6,				-- 炼丹获得任意丹药n个
	TRT_MAKE_FTSZ = 7,			-- 锻造获得飞天神爪n个
	TRT_WUHUN_STRONG = 8,		-- 武魂强化n次
	TRT_EQUIP_STRONG = 9,		-- 装备强化n次
	TRT_HUNQI = 10, 			-- 获得任意魂器n件
	TRT_JIBAN = 11,				-- 任意伙伴羁绊达到n级
	TRT_DASHI_TASK = 12,		-- 完成任意n位大师的挑战
	TRT_DAKA_FJD = 13,			-- 激活打卡风景点n个
	TRT_NEIGONG_GRADE = 14,		-- 玄天功突破至n重
	TRT_MAKE_EQUIP_X = 15,		-- 通过锻造打造x级装备n件
	TRT_HUNQI_UPGRADE = 16,		-- 任意魂器升至n级
	TRT_SHUXING_DUNGEON = 17,	-- 通关任意属性副本n次
	TRT_FISH_NUM = 18,			-- 制作钓竿钓到任意鱼类n次
	TRT_WUHUN_JINHUA = 19,		-- 武魂进化n次
	TRT_HUNHUANG_YEAR = 20,		-- 提升任意魂环年限n次
	TRT_HUNYIN_PUTON = 21,		-- 融合魂印提升任意魂技效果n次
	TRT_TANGMEN_QCYN = 22,		-- 在前世唐门获得前尘忆念n个
	TRT_YUANSHU_UNLOCK = 23,	-- 解锁任意元素神殿n个
	TRT_EQUIP_DECOMPOSE = 24,	-- 分解装备获得升星宝石n个
	TRT_POSITION = 25,			-- 爵位升至n级
	TRT_DOUHUN = 26,			-- 参与任意斗魂n场
	TRT_SHUXINGDAN = 27,		-- 炼制任意属性丹药n枚
	TRT_GRASS_UP = 28,			-- 提升任意仙草年限n次
	TRT_NI_TAI_XIU_LIAN = 29,	-- 拟态修炼n次
	TRT_ANQI_CUILIAN = 30,		-- 暗器淬炼n次
	TRT_YUANSHU_SD = 31,		-- 解锁元素神殿n个
	TRT_WUHUN_JUEXING = 32,		-- 武魂觉醒n次
	TRT_WING_STAR = 33,			-- 外附魂骨觉醒n次
	TRT_WING_ORDER = 34,		-- 外附魂骨进化n次
	TRT_CORE_PUTON = 35,		-- 镶嵌任意魂兽魔核n颗
	TRT_YUANSHU_STONE = 36,		-- 全部元素石达到n级
	TRT_DASHI_LEVEL = 37,		-- 所有大师等级达到n级
	TRT_ANQI_JINGLIAN = 38,		-- 暗器精炼n次
	TRT_COOK_LEVEL = 39,		-- 烹饪等级达到n级
	TRT_LIANYAO_LV = 40,		-- 炼药等级达到n级
	TRT_MAKE_EQUIP_LV = 41,		-- 锻造等级达到n级
	TRT_WING_FULING = 42,		-- 外附魂骨注灵n次
	TRT_ANQI_NUM = 43,			-- 获得暗器n种
	TRT_ANQI_SKILL = 44,		-- 暗器淬毒n次
	TRT_TGLR_HUNSUI = 45,		-- 使用透骨灵刃开启魂髓n次
	TRT_DASHI_JB_X = 46,		-- x位大师羁绊达到n级
	TRT_FISH_TUJIAN = 47,		-- 解锁鱼类图鉴n个
}

TASK_WAR_TOKEN_TYPE = {
	TWTT_COST_TILI = 1,			-- 消耗体力n点
	TWTT_TASK_XY = 2,			-- 完成学院任务n次
	TWTT_KILL_OR_PK = 3,		-- 击败精英魂兽或魂师n个
	TWTT_CAIJI = 4,				-- 采集果实或草药n个
	TWTT_WAKUANG = 5,			-- 收集矿石n个
	TWTT_FISH_NUM = 6,			-- 钓鱼n条
	TWTT_GIVE_GIFT = 7,			-- 赠送NPC礼物n个
	TWTT_TASK_XS = 8,			-- 完成区域悬赏n个
	TWTT_WHD_XS = 9,			-- 武魂殿奖励n次
	TWTT_COOK_DANYAO = 10,		-- 制作料理或丹药n个
	TWTT_LIANJING = 11,			-- 炼金n次
	TWTT_TRUNK_DUNGEON = 12,	-- 主线副本n次
	TWTT_YIJI_DUNGEON = 13,		-- 遗迹副本(元素|矿洞)n次
	TWTT_MIJIN_DUNGEON = 14,	-- 秘境副本(属性|仙草)n次
	TWTT_ZM_GONGXIAN = 15,		-- 宗门贡献n点
	TWTT_ONLINE_TIME = 16,		-- 今日累计在线时长n分钟
	TWTT_TASK_ZONGMEN = 17,		-- 宗门派遣任务n次
	TWTT_JUANXIAN = 18,			-- 捐献金魂币/木材/矿石等n次
	TWTT_ZM_SHOP = 19,			-- 宗门商店购买n次
	TWTT_MEDAL = 20,			-- 勋章等级
	TWTT_QIYUAN = 21,			-- 祈愿n次
	TWTT_HSZG = 22,				-- 穿越海神之光n层
}

TASK_TYPE = {
	TTYPE_TRUNK= 1,				--主线
	TTYPE_BRANCH = 2,			--支线
	TTYPE_DAILY_XY = 3,			--学院
	TTYPE_BAOXIANG = 4,			--宝箱/突发
	TTYPE_WEEK_TDDG = 5,		--天斗悬赏
	TTYPE_WEEK_XLDG = 6,		--星罗悬赏
	--TTYPE_WEEK_WHD = 7,
	TTYPE_ZHUANJI = 8,			--传记
	TTYPE_ZONGMEN = 9,			--宗门
	TTYPE_ROUND = 10,			--宗族
	TTYPE_WAR_TOKEN = 11,		--战令
}

TASK_DATA_DEF = {
	TDD_FIRST_TRUNK_TASK = 10010,
}

TASK_STATE = {

	TSTATE_UNKNOWN = 0,
	TSTATE_DOING = 3,
	TSTATE_CAN_SUBMIT = 4,
	TSTATE_DONE = 5,
	TSTATE_FAIL = 6,

}

EQUIP_TYPE = {
	ET_YIFU = 1,		--护甲
	ET_HUJIAN = 2,		--护肩
	ET_HUWAN = 3,		--护腕
	ET_HUTUI = 4,		--护腿
	ET_JIEZHI = 5,		--戒指
	ET_XIANGLIAN = 6,	--项链
	ET_SHOUZHUO = 7,	--手镯
	ET_YAODAI = 8,		--腰带
}

--尽量少用 record,能建表就建表
RECORD_TYPE = {
	RT_BEGIN = 0,

	RT_DAILY_NEILI_BUY_COUNT = 1,	--每日购买内力次数
	RT_DAILY_AFFI_GIFT_REFRESH = 2,
	RT_DAILY_GET_CARD_REWARD = 3,	--月卡每日领奖

	
	RT_DAILY_ONLINE_TIME = 5,		--每日在线时间

	RT_DAILY_COMMON_FLAG = 6,		--每日标记

	RT_DAILY_FAMILY_DONATE_ITEM_VALUE_1 = 7,	--捐献进度
	RT_DAILY_FAMILY_DONATE_ITEM_VALUE_2 = 8,	--捐献进度
	RT_DAILY_FAMILY_DONATE_ITEM_VALUE_3 = 9,	--捐献进度
	RT_DAILY_NHHY_BUY_NUM = 10,	--凝华魂液每日购买次数

	RT_DAILY_USE_TILI = 11,		--每日使用体力

	RT_DAILY_END = 500,	--每日清空


	RT_DAILY_5_END = 1000,	--每日5点清空


	RT_WEEKLY_END = 1500,	--每周清空

	RT_WEEKLY_5_FAMILY_ACTIVE_REWARD = 1501,
	RT_WEEKLY_5_FAMILY_ACTIVE_VALUE = 1502,

	RT_WEEKLY_5_END = 2000,	--每周1,5点清空

	RT_MONTHLY_END = 3000,	--每月清空

	RT_CURRENCY_BEGIN = 3001, 	--需要跟货币类型对上
	RT_JINHUNBI = 3002,		--金魂币
	RT_JINHUNBI2 = 3003,	--银魂币
	RT_JINHUNBI3 = 3004,	--铜魂币
	RT_DRAW_CARD_COIN_1 = 3005,
	RT_DRAW_CARD_COIN_2 = 3006,
	RT_WAR_TOKEN_COIN = 3007,	--战令币
	RT_NHHY = 3022,	--凝华魂液
	RT_COUNTRY_GOLD_1 = 3024,		--势力货币
	RT_COUNTRY_GOLD_5 = 3028,
	RT_CURRENCY_END = 3050,

	RT_GRASS_GROUP_LEVEL_BEGIN = 3100,	--仙草组合等级
	RT_GRASS_GROUP_LEVEL_END = 3105,

	RT_XY_TASK_TIME = 3110,		-- 学院任务重置时间
	RT_TDDG_TASK_TIME = 3111, 	-- 天斗帝国悬赏
	RT_XLDG_TASK_TIME = 3112,	-- 星罗帝国悬赏
	RT_XY_TASK_GIFT = 3114,		-- 学院任务额外奖励领取状态
	RT_ZZ_TASK_GIFT = 3115,		-- 宗族任务轮次奖励状态(位读写)

	RT_DRAW_COUNT_BEGIN = 3120,
	RT_DRAW_COUNT_END = 3130,
	RT_DRAW_UP_COUNT_BEGIN = 3140,
	RT_DRAW_UP_COUNT_END = 3150,
	RT_DRAW_UP_FIX_BEGIN = 3160,
	RT_DRAW_UP_FIX_END = 3170,

	RT_COMMON_FLAG = 3171,		--通用标记
	RT_FAMILY_QUIT_TIME = 3172,	--退出帮会时间
	RT_FAMILY_SEND_REF_TIME = 3173,	--派遣刷新时间
	RT_FRIEND_CHARM = 3174,		--点赞魅力值
	RT_SYSTEM_OPEN = 3175,		--系统开启

	RT_COUNTRY_POWER_BEGIN = 3176,	--势力亲密度
	RT_COUNTRY_POWER_END = 3180,	--势力亲密度

	RT_LAST_NHHY_CHANGE_TIME = 3181, --最后一次凝华魂液更改时间
	RT_TOTAL_ONLINE_TIME = 3182,	--总在线时长

	RT_CART_MOTH_TIME = 3200,	--月卡时间
	RT_ZANZHU_LEVEL = 3201,		--赞助等级
	RT_FIRST_PAY = 3202,		--首充

	RT_ITEM_COMPOSE_UNLOCK_BEGIN = 3210,	--配方解锁
	RT_ITEM_COMPOSE_UNLOCK_END = 3240,	--配方解锁

	RT_EAT_FOOD_VALUE = 3250,			--饱食度
	RT_EAT_FOOD_VALUE_TIME = 3251,		--饱食度时间
}
-- 32位永久标记
COMMON_FLAG_TYPE = {
	CFT_FIRST_CREATE_FAMILY = 1,
	CFT_FIRST_JOIN_FAMILY = 2,
}
-- 每日标记
DAILY_COMMON_FLAG = {
	DCF_FAMILY_TASK_SEND = 1,
	DCF_FAMILY_TASK_DONATE = 2,
	DCF_FAMILY_TASK_SHOP_BUY = 3,

	DCF_FAMILY_TASK_ONLINE_GET = 4,
	DCF_FAMILY_TASK_SEND_GET = 5,
	DCF_FAMILY_TASK_DONATE_GET = 6,
	DCF_FAMILY_TASK_SHOP_GET = 7,

	DCF_FAMILY_DONATE_MONEY = 8,
}
-- 奖励
COMMON_REWARD_TYPE = {
	CRT_DONATE_FAMILY_MONEY_1 = 1,		--资金捐献 金魂币
	CRT_DONATE_FAMILY_MONEY_2 = 2,		--资金捐献 绑定魂钻
	CRT_DONATE_FAMILY_MONEY_3 = 3,		--资金捐献 魂钻

	CRT_DONATE_FAMILY_ITEM_1 = 4,		--物品捐献 矿
	CRT_DONATE_FAMILY_ITEM_2 = 5,		--物品捐献 石
	CRT_DONATE_FAMILY_ITEM_3 = 6,		--物品捐献 木

	CRT_FAMILY_TASK_ONLINE = 7,			--帮会在线奖励
	CRT_FAMILY_TASK_SEND = 8,			--帮会派遣
	CRT_FAMILY_TASK_DONATE = 9,			--帮会物资收集
	CRT_FAMILY_TASK_SHOP = 10,			--帮会购物
}

-- 离线事件
OFFLINE_EVENT = {
	ON_GET_LIKE = 1,
	ON_GET_FLOWER = 2,
}

PLAYER_ATTR_SOURCE = {
	PAS_JOB = 1, --职业
	PAS_LEVEL = 2, --等级
	PAS_HUNHUAN_1 = 3, --魂环1
	PAS_HUNHUAN_2 = 4, --魂环2
	PAS_HUNHUAN_3 = 5, --魂环3
	PAS_HUNHUAN_4 = 6, --魂环4
	PAS_HUNHUAN_5 = 7, --魂环5
	PAS_HUNHUAN_6 = 8, --魂环6
	PAS_HUNHUAN_7 = 9, --魂环7
	PAS_HUNHUAN_8 = 10, --魂环8
	PAS_HUNHUAN_9 = 11, --魂环9
	PAS_NEIGONG = 12,	--玄天功
	PAS_TIANFU = 13,	--天赋系统
	PAS_SPIRIT = 14, --神祇
	PAS_SHENQI_QIHE = 15, --神兵契合
	PAS_SHENQI_STRENGTHEN = 16, --神器强化
	PAS_SHENQI_STAR = 17, --神器升星
	PAS_GRASS	= 18,	--仙草
	PAS_EQUIP = 19,		--装备
	PAS_LEVEL_SYS = 20, --系统固定分配等级
	PAS_BONE = 21,		--魂骨
	PAS_ANQI = 22,		--暗器
	PAS_DANYAO = 23,	--丹药
	PAS_WUHUN = 24,		--武魂
	PAS_WING = 25,		--翅膀
	PAS_EBOW = 26,		--元素弓
	PAS_POSITION = 27,	--爵位
	PAS_ACHIEVEMENT = 28, --成就
	PAS_TUJIAN = 29,	--图鉴
	PAS_MEDAL = 30,		--勋章
}

ATTR_TYPE = {
	ATTR_MAX_HP = 1,--血量
	ATTR_HP = 2,--当前血量 配属性用不到
	ATTR_P_ATTACK = 3,--基础物理攻击
	ATTR_M_ATTACK = 4,--基础魔法攻击
	ATTR_P_DEF = 5,--基础物理防御
	ATTR_M_DEF = 6,--基础魔法防御
	ATTR_IGNORE_BASIC_ELE_DEF_RATIO = 7,--基础元素穿透
	ATTR_IGNORE_FENG_DEF_RATIO = 8,--风元素穿透
	ATTR_IGNORE_LEI_DEF_RATIO = 9,--雷元素穿透
	ATTR_IGNORE_DU_DEF_RATIO = 10,--毒元素穿透
	ATTR_IGNORE_SHUI_DEF_RATIO = 11,--水元素穿透
	ATTR_IGNORE_HUO_DEF_RATIO = 12,--火元素穿透
	ATTR_IGNORE_TU_DEF_RATIO = 13,--土元素穿透
	ATTR_IGNORE_SHENG_DEF_RATIO = 14,--圣元素穿透
	ATTR_IGNORE_AN_DEF_RATIO = 15,--暗元素穿透
	ATTR_BASIC_ELE_DEF_RATIO = 16,--基础元素抗性
	ATTR_FENG_DEF_RATIO = 17,--风元素抗性
	ATTR_LEI_DEF_RATIO = 18,--雷元素抗性
	ATTR_DU_DEF_RATIO = 19,--毒元素抗性
	ATTR_SHUI_DEF_RATIO = 20,--水元素抗性
	ATTR_HUO_DEF_RATIO = 21,--火元素抗性
	ATTR_TU_DEF_RATIO = 22,--土元素抗性
	ATTR_SHENG_DEF_RATIO = 23,--圣元素抗性
	ATTR_AN_DEF_RATIO = 24,--暗元素抗性
	ATTR_P_DODGE = 25,--基础物理闪避
	ATTR_M_DODGE = 26,--基础魔法躲避
	ATTR_P_VP = 27,--基础物理暴击
	ATTR_M_VP = 28,--基础魔法暴击
	ATTR_P_STRENGTH = 29, --物理攻击强度
	ATTR_M_STRENGTH = 30, --魔法攻击强度
	ATTR_TIZHI = 31,	--体质
	ATTR_LILIANG = 32,	--力量
	ATTR_MINJIE = 33,  --敏捷
	ATTR_ZHIHUI = 34,  --智慧
	ATTR_JINGSHEN = 35,	--精神
	ATTR_P_VP_RATIO = 36, --物理暴击率
	ATTR_M_VP_RATIO = 37, --魔法暴击率
	ATTR_ANTI_P_VP_RATIO = 38, --抗物理暴击率
	ATTR_ANTI_M_VP_RATIO = 39, --抗魔法暴击率
	ATTR_ANTI_P_VP = 40,--抗基础物理暴击
	ATTR_ANTI_M_VP = 41,--抗基础魔法暴击
	ATTR_ANTI_P_DODGE = 42, --物理准确
	ATTR_ANTI_M_DODGE = 43, --魔法命中
	ATTR_ANTI_P_DEF = 44,--基础物理穿透
	ATTR_ANTI_M_DEF = 45,--基础魔法穿透
	ATTR_P_DODGE_RATIO = 46, --物理闪避率
	ATTR_M_DODGE_RATIO = 47, --魔法躲避率
	ATTR_ANTI_P_DODGE_RATIO = 48, --抗物理闪避率
	ATTR_ANTI_M_DODGE_RATIO = 49, --抗魔法躲避率
	ATTR_MAIN_1 = 50, --第一主属性
	ATTR_MAIN_2 = 51, --第二主属性
	ATTR_MAIN_3 = 52, --第三主属性
	ATTR_MAIN_4 = 53, --第四主属性
	ATTR_MAIN_5 = 54, --第五主属性
	ATTR_MAIN_6 = 55, --第六主属性
	ATTR_MAIN_7 = 56, --第七主属性
	ATTR_MAIN_8 = 57, --第八主属性
	ATTR_MAIN_9 = 58, --第九主属性
	ATTR_MAIN_10 = 59, --第十主属性
	ATTR_MAIN_11 = 60, --第十一主属性
	ATTR_ATTACK_SPEED = 61, --攻击速度
	ATTR_MOVE_SPEED = 62, --移动速度
	ATTR_HUNLI = 63, --魂力
	ATTR_HUNLI_RECOVER = 64, --魂力恢复
	ATTR_MOVE_SPEED_SKY = 65,--空中移动速度
	ATTR_MOVE_SPEED_SEA = 66, --水下移动速度
	ATTR_P_M_ATTACK = 67,--物理魔法攻击增加
	ATTR_P_RED = 68, --物理减伤
	ATTR_M_RED = 69, --魔法减伤

}

SHOP_LIMIT_TYPE = {
	SLT_NONE = 0,		--无限购
	SLT_DAY = 1,		--日限购
	SLT_WEEK = 2,		--周限购
	SLT_MONTH = 3,		--月限购
	SLT_LIFE = 4,		--终身限购
	SLT_SEASON = 5,		--战令赛季限购
}

SHOP_OPEN_CONDITION = {
	SOC_USE_TILI = 1,	--使用体力
	SOC_SYSTEM_OPEN = 2,--系统开启
}

SYSTEM_OPEN_CONDITION = {
	SOC_LEVEL = 1,		--等级
	SOC_TASK = 2,		--任务
}

SYSTEM_UNLOCK_TYPE = {
	SUT_HUNHUAN = 2,	--魂环
	SUT_WUHUN = 3,		--武魂
	SUT_BONE = 15,		--魂骨
	SUT_HUNYIN = 16,	--魂印
}

COUNTRY_TYPE = {
	CT_TDDG = 1,		--天斗帝国
	CT_XLDG = 2,		--星罗帝国
	CT_WHSD = 3,		--武魂圣殿
	CT_SLZD = 4,		--杀戮之都
	CT_HSD = 5,			--海神岛
}

MAX_PET_NUM = 50
SHENQI_UP_TYPE =
{
	SUT_QIHE = 1,
	SUT_STRENGTHEN = 2,
	SUT_STAR = 3,
}

BAOXIANG_STATE = {
	LOCK = 1,
	CAN_OPEN = 2,
	OPENED = 3,
}

VITALITY_TASK_TYPE = {
	VITALITY_TASK_XY = 1,			--学院历练n次
	VITALITY_NEILI_GET = 2,			--内力提取n次
	VITALITY_JUANXIAN = 3,			--家族捐献n次
	VITALITY_FRIEND_GIFT = 4,		--伙伴赠礼n次
	VITALITY_QIFU = 5,				--祈福n次
	VITALITY_TASK_ZONGMEN= 6,		--宗门任务
	VITALITY_DUNGEON_TRUNK = 7,		--通关主线副本n次
	VITALITY_DUNGEON_ELEMENT = 8,	--通关元素副本n次
	VITALITY_DUNGEON_TIANFU = 9,	--通关天赋副本n次
	VITALITY_DUNGEON_MINE = 10,		--通关矿洞副本n次
	VITALITY_DUNGEON_GRASS = 11,	--通关仙草副本n次
	VITALITY_MONSTER_ELE_FENG = 12,	--杀怪-风系n个
	VITALITY_CAIJI_CAOYAO = 13,		--采集草药n个
	VITALITY_COOK_NUM = 14,			--烹饪n个
	VITALITY_2VS2 = 15,				--2v2活动
	VITALITY_QUESTION = 16,			--答题
	VITALITY_PVP = 17,				--PVP
	--VITALITY_CAIJI_MINE = 18,		--采集矿石n个
	--VITALITY_CAIJI_TIANFU = 19,		--采集天赋点n个
}

ACHIEVEMENT_TYPE = {
	ACH_KILL_MONSTER = 1,			--杀怪(param:元素类型)
		ACH_BUFF = 2,					--触发特效(param:buffId)
		ACH_BUFF_COUNT = 3,				--元素反应次数(param:1)
		ACH_SHOOT = 4,					--远距离命中(param:距离)
		ACH_CONTINUE_ATK = 5,			--连续攻击(param:1暴击2闪避3未命中)
		ACH_DUN_DIEJIA = 6,				--叠加护盾(param:0)
		ACH_DEAD = 7,					--死亡(param:0)
		ACH_DUN_POCHU = 8,				--破盾(param:0)
		ACH_ANQI_WSXJ = 12,				--使用无声袖箭(param:skillId)
		ACH_ANQI_FTSZ_1 = 13,			--使用飞天神爪(param:skillId)
		ACH_ANQI_ANQI_SKILL = 14,		--使用暗器技能(param:skillId)
		ACH_ANQI_FTSZ_2 = 15,			--使用飞天神爪(param:skillId)
	ACH_LEVEL = 16,					--魂师等级(param:等级)
	ACH_WUHUN_JUEXING = 17,			--武魂觉醒(param:1)
	ACH_WUHUN_JINHUA = 18,			--武魂突破(param:等阶)
	ACH_PUTON_SUIT_HUNQI = 19,		--穿戴套装魂器(param:等阶)
	ACH_PUTON_SUIT_BONE = 20,		--穿戴套装魂骨(param:年限)
	ACH_WING = 21,					--外附魂骨(param:0)
	ACH_WING_TUPO = 22,				--外附魂骨突破(param:等阶)
	ACH_ANQI_ACTIVE = 23,			--激活暗器(param:品质)
		ACH_JIBAN = 24,					--伙伴羁绊(param:伙伴数量)
		ACH_INTIMACY = 25,				--亲密度(param:0)
	ACH_POSITION = 26,				--爵位(param:爵位等级)
		ACH_WEIWANG = 27,				--威望(param:势力类型)
	ACH_GRASS = 28,					--仙草(param:年限)
	ACH_GRASS_GROUP = 29,			--仙草套装(param:group)
	ACH_DRESS = 30,					--获得时装(param:0)
		ACH_MEILI = 31,					--魅力值(param:0)
	ACH_HUNHUAN = 32,				--魂环(param:类型)
	ACH_HUNYIN = 33,				--融合魂印(param:等阶)
	ACH_PUTON_SUIT_EQUIP = 34,		--穿戴套装装备(param:等级)
	ACH_NEIGONG_GRADE = 35,			--玄天功(param:等阶)
	ACH_TIANFU = 36,				--玄天宝录(param:branch)
		ACH_COST_CURRENCY = 37,				--消耗货币(param:货币类型)
		ACH_DUNGEON_COUNT = 38,			--挑战成功副本(param:副本类型)
		ACH_HUIZHANG = 39,				--徽章(param:徽章等级)
		ACH_DOUHUN = 40,				--斗魂连胜(param:1(2v2),2(7v7))
		ACH_HSZG = 41,					--海神之光(param:aaaaa)
		ACH_NPC_JIBAN = 42,				--NPC羁绊(param:npcId)
		ACH_DUNGEON = 43,				--副本(param:副本id)
		ACH_FLY = 44,					--持续飞行(param:0)
		ACH_FLY_SPEED = 45,				--飞行速度(param:0)
		ACH_DIVING = 46,				--潜水(param:0)
}

ARENA_SIGN_UP_STATE = {
	SS_PENDING = 1,		--报名成功匹配中
	SS_REFUSED = 2,
	SS_NONE = 3,		--初始状态
	SS_WAIT_CONFIRM = 4,	--两人组队中发起报名等待队友确认
	SS_SUCCESS = 5,
	SS_QUIT = 6
}

MAX_LEVEL = 100

TEAM_STATE = {
	TS_START = 1,--刚组好队
	TS_WAIT_SIGN = 2,--发起准备报名
	TS_SIGNED = 3,--已报名匹配中
	TS_PENDED = 4,--已匹配到等待确认
	TS_SUCC = 5,--都确认进副本
}

MAP_TYPE = {
	MT_NORMAL = 1,	--普通
	MT_DUNGEON = 2,	--副本
}