SQL_INT = 1
SQL_INT64 = 2
SQL_STRING = 3
SQL_FLOAT = 4
SQL_TIMESTAMP = 5

SQL_TYPE_INSERT = 1
SQL_TYPE_DELETE = 2
SQL_TYPE_UPDATE = 3
SQL_TYPE_SELECT = 4
SQL_TYPE_REPLACE = 5

SQL_GT = 1		-- >
SQL_GTE = 2		-- >=
SQL_LT = 3		-- <
SQL_LTE = 4		-- <=
SQL_NE = 5		-- <>


--[[
[表id] =
_table:表名
_proto:协议名
_key:表的主键 _field 的index值 # = [1]
_rediskey:redis的键 除了 cid 之外的 {协议字段名...}
_field:{
	[1] = {表字段,数据类型,默认值(默认不填)}
	...
}
_sql:{
	_type:sql操作,
	_vec:是否多条数据,
	_key:sql的主键同上面的key,
	_update: insert 时是否加 ON DUPLICATE KEY UPDATE
	_field:{...} 同上 只更新指定字段
	_logic:{key=SQL_GT..} 指定where 时的逻辑运算符,默认都是 =
	_name:函数名后缀
},
...
]]

-- 新表不能再中间插入,只能往最后添加！！！,数据会错乱！！！

local conf = {
    [1] = {
        _table = "mem_chr",
        _proto = "DBChrInfo",
        _key = {1},
		_rediskey = {},
        _field = {
            {"cid",SQL_INT64},
            {"sid",SQL_INT},
            {"uid",SQL_STRING},
            {"name",SQL_STRING},
            {"sex",SQL_INT},
            {"level",SQL_INT},
            {"coin",SQL_INT},
            {"diamond",SQL_INT},
            {"exp",SQL_INT64},
            {"map",SQL_INT},
			{"map_index",SQL_INT},
			{"unique_map_id",SQL_INT64},
			{"gameserver_id",SQL_INT},
            {"x",SQL_FLOAT},
            {"y",SQL_FLOAT},
            {"z",SQL_FLOAT},
			{"dir",SQL_INT},
            {"create_time",SQL_INT},
			{"delete_time",SQL_INT},
			{"back_map",SQL_INT},
			{"back_map_index",SQL_INT},
			{"back_gameserver_id",SQL_INT},
			{"back_x",SQL_FLOAT},
			{"back_y",SQL_FLOAT},
			{"back_z",SQL_FLOAT},
			{"back_unique_map_id",SQL_INT64},
			{"guide_process",SQL_INT},
			{"back_unique_id",SQL_INT},
			{"job",SQL_INT},
			{"attr_point_1",SQL_INT},
			{"attr_point_2",SQL_INT},
			{"attr_point_3",SQL_INT},
			{"attr_point_4",SQL_INT},
			{"attr_point_5",SQL_INT},
			{"hunshi",SQL_INT},
			{"attr_level",SQL_INT},
			{"xuantian1",SQL_INT},
			{"xuantian2",SQL_INT},
			{"xuantian3",SQL_INT},
			{"login_time",SQL_INT},
			{"logout_time",SQL_INT},
			{"gold_unbind",SQL_INT},
			{"gold_bind",SQL_INT},
			{"model",SQL_INT}
        },
        _sql = {
            {_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_UPDATE,_name="pos",_field={{"x",SQL_FLOAT},{"y",SQL_FLOAT},{"z",SQL_FLOAT},{"dir",SQL_INT}},_key={1}},
            {_type = SQL_TYPE_SELECT},
			{_type = SQL_TYPE_SELECT,_name="name",_field={{"cid",SQL_INT64}},_key={4}},
        },
    },
	[2] = {
		_table = "mem_chr_storage",
        _proto = "DB_chr_storage",
        _key = {1,2,3},
		_rediskey = {"storage","slot"},
        _field = {
			{"cid",SQL_INT64},
			{"storage",SQL_INT},
			{"slot",SQL_INT},
			{"type",SQL_INT},
			{"id",SQL_INT64},
			{"bind",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_DELETE,_vec = true,},
			{_type = SQL_TYPE_UPDATE,_vec = true,},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[3] = {
		_table = "mem_unique_equip",
        _proto = "PmEquipInfo",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"owner_id",SQL_INT64},
			{"base",SQL_INT},
			{"create_time",SQL_INT},
			{"bind",SQL_INT},
			{"lock",SQL_INT},
			{"strong_lv",SQL_INT},
			{"jinglian_lv",SQL_INT},
			{"star",SQL_INT},
			{"fuling_1",SQL_INT64},
			{"fuling_2",SQL_INT64},
			{"fuling_3",SQL_INT64},
			{"attr_lv",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={2}},
		}
	},
	[4] = {
		_table = "mem_chr_hunhuan",
        _proto = "DB_chr_hunhuan",
		_key = {1,2},
		_rediskey = {"hunhuan_id"},
		_field = {
			{"cid",SQL_INT64},
			{"hunhuan_id",SQL_INT},
			{"hunshi",SQL_INT},
			{"attr_1",SQL_INT},
			{"attr_2",SQL_INT},
			{"attr_3",SQL_INT},
			{"attr_4",SQL_INT},
			{"attr_5",SQL_INT},
			{"level",SQL_INT},
			{"exp",SQL_INT},
			{"hunyin_1",SQL_INT},
			{"hunyin_2",SQL_INT},
			{"hunyin_3",SQL_INT},
			{"break_level",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[5] = {
		_table = "mem_chr_spirit",
        _proto = "DBChrSpirit",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"level",SQL_INT},
			{"attr_1",SQL_INT},
			{"attr_2",SQL_INT},
			{"attr_3",SQL_INT},
			{"attr_4",SQL_INT},
			{"attr_5",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update=true},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},	
	[6] = {
		_table = "mem_chr_shenqi_qihe",
        _proto = "DBShenQiData",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"level",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update=true},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},	
	[7] = {
		_table = "mem_chr_shenqi_strengthen",
        _proto = "DBShenQiData",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"level",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update=true},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[8] = {
		_table = "mem_chr_shenqi_star",
        _proto = "DBShenQiData",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"level",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update=true},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},	
	[9] = {
		_table = "mem_chr_shenqi_pray",
        _proto = "DBShenQiPray",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"level",SQL_INT},
			{"pray_value",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update=true},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},	
	[10] = {
		_table = "mem_chr_task_trunk",
        _proto = "DB_chr_task_trunk",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[11] = {
		_table = "mem_chr_record",
        _proto = "DB_chr_record",
        _key = {1,2},
		_rediskey = {"type"},
        _field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"value",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_DELETE,_vec = true,},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[12] = {
		_table = "mem_chr_neigong",
		_proto = "DB_chr_neigong",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"grade",SQL_INT},
			{"level",SQL_STRING},
			{"ratio",SQL_STRING},
			{"neili",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = false,_key={1}},
		}
	},
	[13] = {
		_table = "mem_chr_tianfu",
		_proto = "DB_chr_tianfu",
		_key = {1,2,3},
		_rediskey = {"branch","page"},
		_field = {
			{"cid",SQL_INT64},
			{"branch",SQL_INT},
			{"page",SQL_INT},
			{"point",SQL_INT},
			{"active",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[14] = {
		_table = "mem_chr_wuhun",
		_proto = "DB_chr_wuhun",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"strong_lv",SQL_INT},
			{"strong_exp",SQL_INT},
			{"jinghua_lv",SQL_INT},
			{"juexing_lv",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[15] = {
		_table = "mem_unique_pet",
        _proto = "PmPetInfo",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"owner_id",SQL_INT64},
			{"base",SQL_INT},
			{"create_time",SQL_INT},
			{"level",SQL_INT},
			{"grade",SQL_INT},
			{"zizhi_1",SQL_INT},
			{"zizhi_2",SQL_INT},
			{"zizhi_3",SQL_INT},
			{"zizhi_4",SQL_INT},
			{"zizhi_5",SQL_INT},
			{"attr_1",SQL_INT},
			{"attr_2",SQL_INT},
			{"attr_3",SQL_INT},
			{"attr_4",SQL_INT},
			{"attr_5",SQL_INT},
			{"attr_num",SQL_INT},
			{"juexing",SQL_INT},
			{"neidan_1",SQL_INT},
			{"neidan_2",SQL_INT},
			{"neidan_3",SQL_INT},
			{"neidan_4",SQL_INT},
			{"neidan_5",SQL_INT},
			{"skill_1",SQL_INT},
			{"skill_2",SQL_INT},
			{"skill_3",SQL_INT},
			{"skill_4",SQL_INT},
			{"skill_5",SQL_INT},
			{"skill_6",SQL_INT},
			{"skill_7",SQL_INT},
			{"skill_8",SQL_INT},
			{"skill_9",SQL_INT},
			{"skill_10",SQL_INT},
			{"skill_11",SQL_INT},
			{"skill_12",SQL_INT},
			{"skill_13",SQL_INT},
			{"skill_14",SQL_INT},
			{"skill_15",SQL_INT},
			{"skill_16",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={2}},
		}
	},
	[16] = {
		_table = "mem_chr_pet",
		_proto = "DB_chr_pet",
		_key = {1},
		_rediskey = {"pid"},
		_field = {
			{"cid",SQL_INT64},
			{"pid",SQL_INT64},
			{"slot",SQL_INT},
			{"state",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[17] = {
		_table = "mem_chr_grass",
		_proto = "DB_chr_grass",
		_key = {1,2},
		_rediskey = {"type"},
		_field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"years",SQL_INT},
			{"level",SQL_INT},
			{"star",SQL_INT},
			{"attr",SQL_STRING}
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[18] = {
		_table = "mem_unique_bone",
        _proto = "PmBoneInfo",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"owner_id",SQL_INT64},
			{"base",SQL_INT},
			{"create_time",SQL_INT},
			{"bind",SQL_INT},
			{"lock",SQL_INT},
			{"strong_lv",SQL_INT},
			{"strong_exp",SQL_INT},
			{"jinglian_lv",SQL_INT},
			{"star_lv",SQL_INT},
			{"star_exp",SQL_INT},
			{"hunsui1_lv",SQL_INT},
			{"hunsui2_lv",SQL_INT},
			{"hunsui3_lv",SQL_INT},
			{"hunsui4_lv",SQL_INT},
			{"hunsui5_lv",SQL_INT},
			{"hunsui1_exp",SQL_INT},
			{"hunsui2_exp",SQL_INT},
			{"hunsui3_exp",SQL_INT},
			{"hunsui4_exp",SQL_INT},
			{"hunsui5_exp",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={2}},
		}
	},
	[19] = {
		_table = "mem_unique_core",
        _proto = "PmMonsterCoreInfo",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"owner_id",SQL_INT64},
			{"base",SQL_INT},
			{"create_time",SQL_INT},
			{"lock",SQL_INT},
			{"equip_id",SQL_INT64},
			{"exp",SQL_INT},
			{"level",SQL_INT},
			{"bind",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={2}},
		}
	},
	[20] = {
		_table = "mem_chr_item",
        _proto = "DB_chr_item",
        _key = {1,2},
		_rediskey = {"item"},
        _field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"item",SQL_INT},
			{"count",SQL_INT},
			{"bind_count",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_DELETE,_vec = true,},
			{_type = SQL_TYPE_UPDATE,_vec = true,},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[21] = {
		_table = "mem_chr_baoxiang_group",
        _proto = "DB_chr_baoxiang_group",
        _key = {1,2},
		_rediskey = {"group"},
        _field = {
			{"cid",SQL_INT64},
			{"group",SQL_INT},
			{"first_num",SQL_INT},
			{"left_num",SQL_INT},
			{"next_refresh_time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[22] = {
		_table = "mem_chr_baoxiang_task",
        _proto = "DB_chr_baoxiang_task",
        _key = {1,2},
		_rediskey = {"tid"},
        _field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[23] = {
		_table = "mem_chr_baoxiang",
        _proto = "DB_chr_baoxiang",
        _key = {1,2},
		_rediskey = {"bid"},
        _field = {
			{"cid",SQL_INT64},
			{"bid",SQL_INT},
			{"groupid",SQL_INT},
			{"type",SQL_INT},
			{"map",SQL_INT},
			{"x",SQL_FLOAT},
			{"y",SQL_FLOAT},
			{"z",SQL_FLOAT},
			{"state",SQL_INT},
			{"opennum",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}

	},
	[24] = {
		_table = "mem_chr_anqi",
        _proto = "DB_chr_anqi",
        _key = {1,2},
		_rediskey = {"id"},
        _field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"strong_lv",SQL_INT},
			{"strong_exp",SQL_INT},
			{"order_lv",SQL_INT},
			{"order_exp",SQL_INT},
			{"skill_lv",SQL_INT},
			{"jinglian_lv",SQL_INT},
			{"star_lv",SQL_INT},
			{"star_exp",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[25] = {
		_table = "mem_unique_common",
        _proto = "MemUniqueCommon",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"owner_id",SQL_INT64},
			{"type",SQL_INT},
			{"base",SQL_INT},
			{"create_time",SQL_INT},
			{"lock",SQL_INT},
			{"bind",SQL_INT},
			{"int1",SQL_INT},
			{"int2",SQL_INT},
			{"int3",SQL_INT},
			{"int4",SQL_INT},
			{"string1",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={2}},
		}
	},
	[26] = {
		_table = "mem_chr_danyao",
        _proto = "DB_chr_danyao",
		_key = {1, 2},
		_rediskey = {"did"},
		_field = {
			{"cid",SQL_INT64},
			{"did",SQL_INT},
			{"num",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[27] = {
		_table = "mem_chr_lifeskill",
        _proto = "DB_chr_lifeskill",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"equip_lv",SQL_INT},
			{"equip_exp",SQL_INT},
			{"lianzhi_lv",SQL_INT},
			{"lianzhi_exp",SQL_INT},
			{"lianjin_lv",SQL_INT},
			{"lianjin_exp",SQL_INT},
			{"cook_lv",SQL_INT},
			{"cook_exp",SQL_INT},
			{"item_make_lv",SQL_INT},
			{"item_make_exp",SQL_INT},
			{"fish_lv",SQL_INT},
			{"fish_exp",SQL_INT},

		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[28] = {
		_table = "mem_chr_equip_make",
        _proto = "DB_chr_equip_make",
		_key = {1,2},
		_rediskey = {"type","id"},
		_field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"id",SQL_INT},
			{"num",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={1}},
		}
	},
	[29] = {
		_table = "mem_chr_wing",
        _proto = "DB_chr_wing",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"strong_lv",SQL_INT},
			{"strong_exp",SQL_INT},
			{"order_lv",SQL_INT},
			{"star_lv",SQL_INT},
			{"fuling_lv",SQL_STRING,"0,0,0,0,0,0,0,0"},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[30] = {
		_table = "mem_chr_client_record",
        _proto = "DB_chr_client_record",
        _key = {1,2},
		_rediskey = {"type"},
        _field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"value",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[31] = {
		_table = "mem_chr_ebow",
        _proto = "DB_chr_elementbow",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"elementbow_lv",SQL_STRING},
			{"suit_lv",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[32] = {
		_table = "mem_chr_position",
        _proto = "DB_chr_position",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"pt_level",SQL_INT},
			{"pt_star",SQL_INT},
			{"med_lv",SQL_INT},
			{"pt_exp",SQL_INT},
			{"pt_exp_cur",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[33] = {
		_table = "mem_chr_vit_task",
        _proto = "DB_chr_vit_task",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_DELETE,_vec = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[34] = {
		_table = "mem_chr_vit_gift",
		_proto = "DB_chr_vit_gift",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"vit",SQL_INT},
			{"state",SQL_INT},
			{"total",SQL_INT},
			{"count",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[35] = {
		_table = "mem_chr_shop_limit",
        _proto = "DB_chr_shop_limit",
        _key = {1,2},
		_rediskey = {"shop_id"},
        _field = {
			{"cid",SQL_INT64},
			{"shop_id",SQL_INT},
			{"count",SQL_INT},
			{"limit_type",SQL_INT},
			{"discount_time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[36] = {
		_table = "mem_chr_position_reward",
        _proto = "DB_chr_position_reward",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"get_state",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[37] = {
		_table = "mem_chr_achievement",
        _proto = "DB_chr_achievement",
        _key = {1},
		_rediskey = {},
        _field = {
			{"cid",SQL_INT64},
			{"level",SQL_INT},
			{"point",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = false,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = false,_key={1}},
		}
	},
	[38] = {
		_table = "mem_chr_achievement_task",
		_proto = "DB_chr_achievement_task",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[39] = {
		_table = "mem_chr_collection",
        _proto = "DB_chr_collection",
        _key = {1,2},
		_rediskey = {"id"},
        _field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"num",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[40] = {
		_table = "mem_chr_tujian",
        _proto = "DB_chr_tujian",
		_key = {1,2,3},
		_rediskey = {"group","id"},
		_field = {
			{"cid",SQL_INT64},
			{"group",SQL_INT},
			{"id",SQL_INT},
			{"affinity",SQL_INT},
			{"affi_lv",SQL_INT},
			{"affi_unlock",SQL_INT},
			{"jb_lv",SQL_INT},
			{"jb_activate",SQL_INT},
			{"cognition",SQL_INT},
			{"cogni_lv",SQL_INT},
			{"unlock",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[41] = {
		_table = "mem_chr_tujian_total",
        _proto = "DB_chr_tujian_total",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"score_npc",SQL_INT},
			{"score_monster",SQL_INT},
			{"score_baibao",SQL_INT},
			{"score_map",SQL_INT},
			{"score_story",SQL_INT},
			{"level",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[42] = {
		_table = "mem_chr_mail",
        _proto = "MemChrMail",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"cid",SQL_INT64},
			{"sender",SQL_INT},
			{"title",SQL_STRING},
			{"content",SQL_STRING},
			{"reward",SQL_STRING},
			{"state",SQL_INT},
			{"reason",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_UPDATE,_field={{"state",SQL_INT}}},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={2,9},
				_logic={["time"]=SQL_GT},
			},
			{_type = SQL_TYPE_DELETE,},
			{_type = SQL_TYPE_DELETE,_name="outtime",_key={9},
				_logic = {["time"]=SQL_LT}
			},
		}
	},
	[43] = {
		_table = "server_mail",
        _proto = "MemChrMail",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT},
			{"title",SQL_STRING},
			{"content",SQL_STRING},
			{"reward",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_SELECT,_vec=true,_key={5},
				_logic={["time"]=SQL_GT},
			},
			{_type = SQL_TYPE_DELETE,_name="outtime",_key={5},
				_logic = {["time"]=SQL_LT}
			},
		}
	},
	[44] = {
		_table = "mem_chr_server_mail",
        _proto = "DB_chr_server_mail",
		_key = {1},
		_rediskey = {"id"},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={1,3},
				_logic={["time"]=SQL_GT},
			},
			{_type = SQL_TYPE_DELETE,_name="outtime",_key={3},
				_logic = {["time"]=SQL_LT}
			},
		}
	},
	[45] = {
		_table = "mem_chr_relation",
        _proto = "DB_chr_relation",
		_key = {1},
		_rediskey = {"rcid"},
		_field = {
			{"cid",SQL_INT64},
			{"rcid",SQL_INT64},
			{"type",SQL_INT},
			{"value",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update=true},
			{_type = SQL_TYPE_SELECT,_vec=true},
			{_type = SQL_TYPE_SELECT,_key={1,2}},
			{_type = SQL_TYPE_DELETE,_key={1,2}},
		}
	},
	[46] = {
		_table = "mem_chr_level_gift",
        _proto = "DB_chr_level_gift",
		_key = {1,2},
		_rediskey = {"level"},
		_field = {
			{"cid",SQL_INT64},
			{"level",SQL_INT},
			{"done",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[47] = {
		_table = "mem_chr_pay",
        _proto = "DB_chr_pay",
		_key = {1,2},
		_rediskey = {"id"},
		_field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"buy_count",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[48] = {
		_table = "mem_chr_task_random",
        _proto = "DB_chr_task_random",
		_key = {1,2,3},
		_rediskey = {"ttype","tid"},
		_field = {
			{"cid",SQL_INT64},
			{"ttype",SQL_INT},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_DELETE,_vec = true,_key={1,2,3}},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[49] = {
		_table = "mem_chr_sign_up",
        _proto = "DB_chr_sign_up",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"days",SQL_INT},
			{"state",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[50] = {
		_table = "mem_chr_task_branch",
        _proto = "DB_chr_task_branch",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[51] = {
		_table = "mem_chr_task_zhuanji",
        _proto = "DB_chr_task_zhuanji",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[52] = {
		_table = "mem_family",
		_proto = "DB_mem_family",
		_key = {1},
		_rediskey = {},
		_field = {
			{"id",SQL_INT64},
			{"level",SQL_INT},
			{"name",SQL_STRING},
			{"flag",SQL_INT},
			{"type",SQL_INT},
			{"limit",SQL_INT},
			{"auto_agree",SQL_INT},
			{"desc",SQL_STRING},
			{"notice",SQL_STRING},
			{"time",SQL_INT},
			{"power",SQL_INT64},
			{"li_lv",SQL_INT},
			{"wu_lv",SQL_INT},
			{"yu_lv",SQL_INT},
			{"min_lv",SQL_INT},
			{"yao_lv",SQL_INT},
			{"gold",SQL_INT},
			{"mine",SQL_INT},
			{"stone",SQL_INT},
			{"wood",SQL_INT},
			{"active_value",SQL_INT},
			{"build_time",SQL_INT},
			
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={}},
		}
	},
	[53] = {
		_table = "mem_family_member",
		_proto = "DB_mem_family_member",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"family_id",SQL_INT64},
			{"position",SQL_INT},
			{"nochat",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_DELETE,_name="family",_key={2}},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={}},
		}
	},
	[54] = {
		_table = "mem_family_apply",
		_proto = "DB_mem_family_apply",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"family_id",SQL_INT64},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_DELETE,_name="family",_key={2}},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={}},
		}
	},
	[55] = {
		_table = "mem_family_event",
		_proto = "DB_mem_family_event",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"family_id",SQL_INT64},
			{"id",SQL_INT},
			{"type",SQL_INT},
			{"time",SQL_INT},
			{"string1",SQL_STRING},
			{"string2",SQL_STRING},
			{"int1",SQL_INT},
			{"int2",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_DELETE},
			{_type = SQL_TYPE_DELETE,_name="family",_key={1}},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={}},
		}
	},
	[56] = {
		_table = "mem_chr_task_round",
        _proto = "DB_chr_task_round",
		_key = {1,2,3},
		_rediskey = {"round","tid"},
		_field = {
			{"cid",SQL_INT64},
			{"round",SQL_INT},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[57] = {
		_table = "mem_chr_arena",
        _proto = "DB_chr_arena",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"score",SQL_INT},
			{"win",SQL_INT},
			{"lose",SQL_INT},
			{"draw",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[58] = {
		_table = "mem_chr_dress",
        _proto = "DB_chr_dress",
		_key = {1,2,3},
		_rediskey = {"type","id"},
		_field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"id",SQL_INT},
			{"expire_time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec = true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[59] = {
		_table = "mem_chr_war_token",
        _proto = "DB_chr_war_token",
		_key = {1,2},
		_rediskey = {"season"},
		_field = {
			{"cid",SQL_INT64},
			{"season",SQL_INT},
			{"time",SQL_INT},
			{"buy",SQL_INT},
			{"level",SQL_INT},
			{"exp",SQL_INT},
			{"round",SQL_INT},
			{"round_exp",SQL_INT},
			{"free",SQL_STRING},
			{"lock",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec=false,_update = true},
			{_type = SQL_TYPE_SELECT,_vec=false,_key={1,2}},
		}
	},
	[60] = {
		_table = "mem_chr_task_war_token",
        _proto = "DB_chr_task_war_token",
		_key = {1,2},
		_rediskey = {"tid"},
		_field = {
			{"cid",SQL_INT64},
			{"tid",SQL_INT},
			{"state",SQL_INT},
			{"progress",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec=true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={1}},
		}
	},
	[61] = {
		_table = "mem_chr_family_send",
        _proto = "DB_mem_chr_family_send",
		_key = {1,2},
		_rediskey = {"type"},
		_field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"id",SQL_INT},
			{"friend1",SQL_INT},
			{"friend2",SQL_INT},
			{"friend3",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_vec=true,_update = true},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={1}},
		}
	},
	[62] = {
		_table = "mem_family_red_packet",
        _proto = "DB_mem_family_red_packet",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"family_id",SQL_INT64},
			{"id",SQL_INT},
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"num",SQL_INT},
			{"value",SQL_INT},
			{"job",SQL_INT},
			{"name",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={}},
			{_type = SQL_TYPE_DELETE,_name="all",_key={}},
			{_type = SQL_TYPE_DELETE,_key={1}},
		}
	},
	[63] = {
		_table = "mem_family_red_packet_record",
        _proto = "DB_mem_family_red_packet_record",
		_key = {1,2},
		_rediskey = {},
		_field = {
			{"family_id",SQL_INT64},
			{"id",SQL_INT},
			{"cid",SQL_INT64},
			{"value",SQL_INT},
			{"job",SQL_INT},
			{"name",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={}},
			{_type = SQL_TYPE_DELETE,_name="all",_key={}},
			{_type = SQL_TYPE_DELETE,_key={1}},
		}
	},
	[64] = {
		_table = "mem_chr_dress_wear",
        _proto = "DB_chr_dress_wear",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"wear",SQL_STRING},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[65] = {
		_table = "mem_chr_drow_item",
        _proto = "DB_chr_drow_item",
		_key = {1,2,3},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"itemid",SQL_INT},
			{"type",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_SELECT,_vec=true,_key={1}},
		}
	},
	[66] = {
		_table = "mem_chr_offline_event",
        _proto = "DB_chr_offline_event",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"type",SQL_INT},
			{"param1",SQL_INT},
			{"pi64",SQL_INT64},
			{"param2",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
			{_type = SQL_TYPE_SELECT,_vec=true},
			{_type = SQL_TYPE_DELETE},
		}
	},
	[67] = {
		_table = "mem_chr_friend_like",
        _proto = "DB_chr_friend_like",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
		},
		_sql = {
		}
	},
	[68] = {
		_table = "mem_chr_face",
        _proto = "DB_chr_face",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"face",SQL_STRING},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_UPDATE},
			{_type = SQL_TYPE_SELECT},
		}
	},
	[69] = {
		_table = "mem_chr_collection_forever",
        _proto = "DB_chr_collection_forever",
        _key = {1,2},
		_rediskey = {"id"},
        _field = {
			{"cid",SQL_INT64},
			{"id",SQL_INT},
			{"value",SQL_INT64},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT,_update = true},
			{_type = SQL_TYPE_SELECT,_vec = true,_key={1}},
		}
	},
	[70] = {
		_table = "mem_chr_monster_drop",
		_proto = "DB_chr_monster_drop",
		_key = {1},
		_rediskey = {"monster"},
		_field = {
			{"cid",SQL_INT64},
			{"monster",SQL_INT},
			{"drop",SQL_INT},
		},
		_sql = {
		}
	},
	[71] = {
		_table = "mem_chr_no_redis",
		_proto = "DB_chr_no_redis",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"mod1",SQL_INT64},
			{"mod2",SQL_INT64},
		},
		_sql = {
			{_type = SQL_TYPE_SELECT},
			{_type = SQL_TYPE_DELETE},
		}
	},
}
-- 新表不能再中间插入,只能往最后添加！！！,数据会错乱！！！

-- log的表
LOG_CONF = {
	[1] = {
		_table = "log_draw_card",
		_proto = "log_draw_card",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"item_id",SQL_INT},
			{"item_type",SQL_INT},
			{"num",SQL_INT},
			{"active",SQL_INT},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
		}
	},
	[2] = {
		_table = "log_useitem",
		_proto = "log_useitem",
		_key = {1},
		_rediskey = {},
		_field = {
			{"cid",SQL_INT64},
			{"itemid",SQL_INT},
			{"type",SQL_INT},
			{"num",SQL_INT},
			{"reason",SQL_INT},
			{"realid",SQL_INT64},
			{"time",SQL_INT},
		},
		_sql = {
			{_type = SQL_TYPE_INSERT},
		}
	},
}

return conf