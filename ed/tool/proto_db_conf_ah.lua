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

local conf = {
    {
        _table = "mem_unique_equip",
        _proto = "PmEquipInfo",
        _key = {1},
        _field = {
            [1] = {"id","id",SQL_INT64},
            [2] = {"owner_id","owner_id",SQL_INT},
            [3] = {"owner_sid","owner_sid",SQL_INT},
            [4] = {"base","base",SQL_INT},
            [5] = {"base_attrs","base_attrs",SQL_STRING},
            [6] = {"quality","quality",SQL_INT},
            [7] = {"affix","affix",SQL_STRING},
            [8] = {"affix_backup","affix_backup",SQL_STRING},
            [9] = {"wal","wal",SQL_INT},
            [10] = {"create_time","create_time",SQL_INT},
            [11] = {"base_affix","base_affix",SQL_STRING},
            [12] = {"level","level",SQL_INT},
            [13] = {"rune_suit","rune_suit",SQL_INT},
            [14] = {"runes","runes",SQL_STRING},
        },
        _sql = {
            {_type = SQL_TYPE_INSERT,_vec=true},
            {_type = SQL_TYPE_REPLACE,_vec=true},
            {_type = SQL_TYPE_DELETE,_vec=true},
            {_type = SQL_TYPE_UPDATE,_vec=true},
            {_type = SQL_TYPE_SELECT,_key={2,3},_vec=true},
        },
    },

}

return conf