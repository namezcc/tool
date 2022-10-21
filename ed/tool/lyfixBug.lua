
local data = {
{id=1124988,born_sid= 5867},
{id=1171431,born_sid= 6193},
{id=4562046,born_sid= 184},
{id=1100460,born_sid= 1863},
{id=1219115,born_sid= 5511},
{id=1207915,born_sid= 5484},
{id=1109115,born_sid= 5887},
{id=1248656,born_sid= 5411},
{id=1164297,born_sid= 5867},
{id=1250847,born_sid= 6359},
{id=1163122,born_sid= 6010},




}

local rune = {
{id=1001642,born_sid= 17144}



}

local totem = {
{id=1000957,born_sid= 16355},
{id=1001018,born_sid= 16355},
{id=1000955,born_sid= 16355},
{id=1000956,born_sid= 16355},
{id=1001012,born_sid= 16355},
{id=1001013,born_sid= 16355},
{id=1001014,born_sid= 16355},
{id=1001015,born_sid= 16355},
{id=1001016,born_sid= 16355},
{id=1001017,born_sid= 16355},


}

local StorageType =
{
    ST_NO_TYPE = 0,
    ST_CHR_PUTON = 1,
    ST_CHR_BAG = 2,
    ST_HERO_PUTON = 3,
    ST_HERO_BAG = 4,
    ST_CHR_STORE_FIRST = 5,
    ST_CHR_STORE_SECOND = 6,
    ST_CHR_STORE_THREE = 7,
    ST_CHR_STORE_FOUR = 8,
    ST_CHR_STORE_FIVE = 9,
    ST_CHR_RUNE = 10,
    ST_CHR_COAT_ARM = 11,
    ST_CHR_WING_EQUIP = 12,
    ST_HERO_WING_EQUIP = 13,
    ST_CHR_EXTRA_STORA_1 = 14,
    ST_CHR_EXTRA_STORA_2 = 15,
    ST_CHR_EXTRA_STORA_3 = 16,
    ST_CHR_EXTRA_STORA_4 = 17,
    ST_CHR_EXTRA_STORA_5 = 18,
    ST_CHR_EXTRA_STORA_6 = 19,
    ST_CHR_EXTRA_STORA_7 = 20,
    ST_CHR_EXTRA_STORA_8 = 21,
    ST_CHR_EXTRA_STORA_9 = 22,
    ST_CHR_EXTRA_STORA_10 = 23,
    ST_CHR_EXTRA_STORA_11 = 24,
    ST_CHR_EXTRA_STORA_12 = 25,
    ST_CHR_EXTRA_STORA_13 = 26,
    ST_CHR_EXTRA_STORA_14 = 27,
    ST_CHR_EXTRA_STORA_15 = 28,
    ST_CHR_TOTEM = 29,
    ST_CHR_XINFA = 30,
    ST_HERO_XINFA = 31,
    ST_CROSS_BAG = 32,
    ST_CHR_SOUL_PUTON = 33,
    ST_HERO_SOUL_PUTON = 34,
    ST_CHR_STONE_PUTON_1 = 35,
    ST_CHR_STONE_PUTON_2 = 36,
    ST_HERO_STONE_PUTON_1 = 37,
    ST_HERO_STONE_PUTON_2 = 38,
    ST_ZHENFA_STONE_PUTON = 39,
    ST_CHR_MING_WEN = 40,
    ST_HERO_MING_WEN = 41,
    ST_MAX_STORAGE_TYPE = 42,
}

function pInList( tab )
    local instr = {}
    for i,v in ipairs(tab) do
        local fmt = "(%d,%d)"
        fmt = string.format(fmt,v.id,v.born_sid)
        table.insert(instr,fmt)
    end
    local sqlstr = table.concat( instr, ",")
    return sqlstr
end

function pInList2( tab )
    local instr = {}
    local insid = {}
    for i,v in ipairs(tab) do
        -- local fmt = "(%d,%d)"
        -- fmt = string.format(fmt,v.id,v.born_sid)
        table.insert(instr,v.id)
        table.insert(insid,v.born_sid)
    end
    local sqlstr = table.concat( instr, ",")
    local sql2 = table.concat( insid, ",")
    return sqlstr,sql2
end


-- pInList(data)

local BAG_INDEX = 0

function insEquip(cid,sid, _data )
    for i,v in ipairs(_data) do
        local sql = "INSERT INTO mem_chr_storage VALUES(%d,%d,2,%d,%d,%d,2,1,0,0,0);"
        sql = string.format(sql,cid,sid,BAG_INDEX,v.id,v.born_sid)
        BAG_INDEX = BAG_INDEX-1
        print(sql)
    end
end

function insRune( cid,sid,_data )
    for i,v in ipairs(_data) do
        local sql = "INSERT INTO mem_chr_storage VALUES(%d,%d,2,%d,%d,%d,3,1,0,0,0);"
        sql = string.format(sql,cid,sid,BAG_INDEX,v.id,v.born_sid)
        BAG_INDEX = BAG_INDEX-1
        print(sql) 
    end
end

function insTotem( cid,sid,_data)
    for i,v in ipairs(_data) do
        local sql = "INSERT INTO mem_chr_storage VALUES(%d,%d,2,%d,%d,%d,7,1,0,0,0);"
        sql = string.format(sql,cid,sid,BAG_INDEX,v.id,v.born_sid)
        BAG_INDEX = BAG_INDEX-1
        print(sql)
    end
end

function psetEquip( cid,sid,_data )
    local str = pInList(_data)
    local sql = "SELECT * FROM mem_chr_storage WHERE `type`=2 AND (id,born_sid)IN(%s);"
    local sql2 = "SELECT * FROM mem_unique_equip WHERE (id,born_sid)IN(%s);"

    local sql_1 = "SELECT * FROM mem_chr_storage WHERE `type`=2 AND `id`=%d AND `born_sid`=%d;"
    local sql_2 = "SELECT * FROM mem_unique_equip WHERE `id`=%d AND `born_sid`=%d;"
    local sql_3 = "UPDATE mem_unique_equip SET `owner`=%d,`sid`=%d WHERE `id`=%d AND `born_sid`=%d;"
    local sql_4 = "SELECT * FROM mem_family_storage WHERE `id`=%d AND `born_sid`=%d;"

    print(string.format(sql,str))

    for i,v in ipairs(_data) do
        print(string.format(sql_1,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_2,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_3,cid,sid,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_4,v.id,v.born_sid))
    end
end

function psetRune( cid,sid,_data )
    local str = pInList(_data)
    local sql = "SELECT * FROM mem_unique_rune WHERE (id,born_sid)IN(%s);"
    local sql2 = "UPDATE mem_unique_rune SET owner_cid=%d,owner_sid=%d WHERE (id,born_sid)IN(%s);"

    local sql_1 = "SELECT * FROM mem_chr_storage WHERE `type`=3 AND `id`=%d AND `born_sid`=%d;"
    local sql_2 = "SELECT * FROM mem_unique_rune WHERE `id`=%d AND `born_sid`=%d;"
    local sql_3 = "UPDATE mem_unique_rune SET `owner_cid`=%d,`owner_sid`=%d WHERE `id`=%d AND `born_sid`=%d;"

    for i,v in ipairs(_data) do
        print(string.format(sql_1,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_2,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_3,cid,sid,v.id,v.born_sid))
    end

    -- print(string.format(sql,str))
    -- print(string.format(sql2,cid,sid,str))
end

function psetTotem( cid,sid,_data )
    local sql_1 = "SELECT * FROM mem_chr_storage WHERE `type`=7 AND `id`=%d AND `born_sid`=%d;"
    local sql_2 = "SELECT * FROM mem_unique_totem WHERE `id`=%d AND `born_sid`=%d;"
    local sql_3 = "UPDATE mem_unique_totem SET `owner_cid`=%d,`owner_sid`=%d WHERE `id`=%d AND `born_sid`=%d;"

    for i,v in ipairs(_data) do
        print(string.format(sql_1,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_2,v.id,v.born_sid))
    end
    for i,v in ipairs(_data) do
        print(string.format(sql_3,cid,sid,v.id,v.born_sid))
    end
end

function resetFamilySlot(fid,fsid,_data,begindex)
    local sql = "INSERT INTO mem_family_storage VALUES(%d,%d,%d,%d,%d);"
    local slot = begindex or 0
    print(string.format("DELETE FROM mem_family_storage WHERE family_id=%d AND family_sid=%d;",fid,fsid))
    for i,v in ipairs(_data) do
        print(string.format(sql,fid,fsid,slot,v.id,v.born_sid))
        slot = slot + 1
    end
end

function deleteRepeat(_data)
    local tab = {}

    for i,v in ipairs(_data) do
        tab[v.id] = v.born_sid
    end

    for k,v in pairs(tab) do
        print(string.format("{id=%d,born_sid= %d},",k,v))
    end
end

function genBuff( tab )
    local str1 = 'SELECT * FROM mem_chr_record WHERE cid=%d AND sid=%d AND type=200001 AND (param&(1<<4))>0 AND (cid,sid)NOT IN(SELECT cid,sid FROM mem_chr_buff WHERE cid=%d AND sid=%d AND is_hero=1 AND id = 7201);'
    local str = 'INSERT INTO mem_chr_buff VALUES(%d,%d,1,7201,306502417,-1);'
    local str2 = 'INSERT INTO mem_chr_buff SELECT cid,sid,1,7201,306502417,-1 FROM mem_chr_record WHERE cid=%d AND sid=%d AND type=200001 AND (param&(1<<4))>0 AND (cid,sid)NOT IN(SELECT cid,sid FROM mem_chr_buff WHERE cid=%d AND sid=%d AND is_hero=1 AND id = 7201);'

    -- for i,v in ipairs(tab) do
    --     local cid = v[1]
    --     local sid = v[2]
    --     print(string.format(str1,cid,sid,cid,sid))
    -- end

    -- for i,v in ipairs(tab) do
    --     local cid = v[1]
    --     local sid = v[2]
    --     print(string.format(str,cid,sid))
    -- end

    for i,v in ipairs(tab) do
        local cid = v[1]
        local sid = v[2]
        print(string.format(str2,cid,sid,cid,sid))
    end
end


BAG_INDEX = 48
local cid = 1279
local sid = 184

-- deleteRepeat(data)

-- psetEquip(cid,sid,data)
-- psetRune(cid,sid,rune)
-- psetTotem(cid,sid,totem)

-- insEquip(cid,sid,data)
-- insRune(cid,sid,rune)
-- insTotem(cid,sid,totem)
-- 011011011
-- resetFamilySlot(2,221,data,319)

local buff = {
{2007  ,  2842},
{1509  ,  7966},


}

genBuff(buff)