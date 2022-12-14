local out_path2 = "../../src/share"
local lua_path = "../../bin/lua/loginserver/util"

require "split"
local conf = require "proto_db_conf"

function getCtype( sqlf_type )
    if sqlf_type == SQL_INT then
        return "int32_t"
    elseif sqlf_type == SQL_INT64 then
        return "int64_t"
    elseif sqlf_type == SQL_STRING then
        return "std::string"
    elseif sqlf_type == SQL_FLOAT then
        return "float"
    elseif sqlf_type == SQL_TIMESTAMP then
        return "std::string"
    end
end

function getCformate( sqlf_type )
    if sqlf_type == SQL_INT then
        return "%d"
    elseif sqlf_type == SQL_INT64 then
        return "%lld"
    elseif sqlf_type == SQL_STRING then
        return "'%s'"
    elseif sqlf_type == SQL_FLOAT then
        return "%f"
    elseif sqlf_type == SQL_TIMESTAMP then
        return "%s"
    end
end

function get_get_val_func( sqlf_type )
    if sqlf_type == SQL_INT then
        return "getIntValue"
    elseif sqlf_type == SQL_INT64 then
        return "getInt64Value"
    elseif sqlf_type == SQL_STRING then
        return "getStringValue"
    elseif sqlf_type == SQL_FLOAT then
        return "getDoubleValue"
    elseif sqlf_type == SQL_TIMESTAMP then
        return "getStringValue"
    end
end

function get_logic_str(type)
	if type == SQL_GT then
		return ">"
	elseif type == SQL_GTE then
		return ">="
	elseif type == SQL_LT then
		return "<"
	elseif type == SQL_LTE then
		return "<="
	elseif type == SQL_NE then
		return "<>"
	else
		return "="
	end
end

function getKeyStr( cfg,_key,noType )
    local str = ""
    for _1,kindex in ipairs(_key) do
        local finfo = cfg._field[kindex]
		local vt = finfo[2]
        if noType then
            str = str..", _"..finfo[1]
            if vt == SQL_STRING or vt == SQL_TIMESTAMP then
                str = str..".c_str()"
            end
        else
            str = str..","..getCtype(vt).." _"..finfo[1]
        end
    end
    return str
end

function getFuncStr(cfg,v,_vec)
    local fs = "void %s_%s(%s& pb,Net::MySqlDBGuard& db,char* _buff,size_t _size%s)"
	if v._type == SQL_TYPE_SELECT and not _vec then
		fs = "bool %s_%s(%s& pb,Net::MySqlDBGuard& db,char* _buff,size_t _size%s)"
	end

    local sqltype = ""
    local fname = cfg._table
    local className = "Proto::"..cfg._proto
    local keyStr = ""

	if v._name then
		fname = fname.."_"..v._name
	end

    if _vec then 
        className = "gopb::RepeatedPtrField<Proto::"..cfg._proto..">" 
    end

    if v._type == SQL_TYPE_INSERT then
        sqltype = "insert"
    elseif v._type == SQL_TYPE_DELETE then
        sqltype = "delete"
    elseif v._type == SQL_TYPE_UPDATE then
        sqltype = "update"
    elseif v._type == SQL_TYPE_SELECT then
        sqltype = "select"
        keyStr = getKeyStr(cfg,v._key or cfg._key)
    elseif v._type == SQL_TYPE_REPLACE then
        sqltype = "replace"
    end

    fs = string.format(fs,sqltype,fname,className,keyStr)
    return fs
end

function getFileStr( cfg,open )
    local str = ""
	if not open then
		str = "("
	end
    for i,v in ipairs(cfg._field) do
        if i > 1 then
            str = str..","
        end
        str = str.."`"..v[1].."`"
    end
	if not open then
		str = str..")"
	end
    return str
end

function getValueStr( cfg )
    local str = "("
    for i,v in ipairs(cfg._field) do
        if i > 1 then
            str = str..","
        end
        str = str..getCformate(v[2])
    end
    return str..")"
end

function get_k_v( f,logic )
    local str = "`%s` %s %s"
	local lg = "="
	if logic then
		lg = get_logic_str(logic[f[1]])
	end
    str = string.format(str,f[1],lg,getCformate(f[2]))
    return str
end

function getWhereStr( cfg,keys,logic )
    local str = ""
    for i,v in ipairs(keys) do
        if i > 1 then
            str = str.." AND "
        end
        str = str..get_k_v(cfg._field[v],logic)
    end
    return str
end

function isKey( index,_key )
    for i,v in ipairs(_key) do
        if index == v then
            return true
        end
    end
    return false
end

function getSetStr( cfg,_key )
    local str = ""
    local first = nil
    for index,v in ipairs(cfg._field) do
        if isKey(index,_key) == false then
            if first then
                str = str..", "
            end
            str = str..get_k_v(v)
            first = true
        end
    end
    return str
end

function getPbValue( cfg,_key , _outKey)
    local str = "\t"

    if _key and _outKey == nil then
        for i,index in ipairs(_key) do
            if i > 1 then
                str = str..","
            end
            local v = cfg._field[index]
			local vt = v[2]
            str = str.."pb."..string.lower(v[1]).."()"
            if vt == SQL_STRING or vt == SQL_TIMESTAMP then
                str = str..".c_str()"
            end
        end
    else
        local first = nil
        for i,v in ipairs(cfg._field) do
            if _outKey == nil or isKey(i,_key) == false then
                if first then
                    str = str..","
                end
				local vt = v[2]
                first = true
                str = str.."pb."..string.lower(v[1]).."()"
                if vt == SQL_STRING or vt == SQL_TIMESTAMP then
                    str = str..".c_str()"
                end
            end
        end
    end
    return str
end

function get_insert_func( cfg,v,_vec )
    local fstr = getFuncStr(cfg,v,_vec)
    if _vec == nil then
        local str = [[
{
    %s
    db.excute(_buff);
}

]]

        local ptf = 'snprintf(_buff, _size,'
        ptf = ptf..'"INSERT INTO `'..cfg._table..'`'..getFileStr(cfg)
        if v._update then
            ptf = ptf.." VALUES "..getValueStr(cfg).." ON DUPLICATE KEY UPDATE "..getSetStr(cfg,cfg._key)..';",\n'
            ptf = ptf..getPbValue(cfg)..","..getPbValue(cfg,cfg._key,true)..");\n"
        else
            ptf = ptf.." VALUES "..getValueStr(cfg)..';",\n'
            ptf = ptf..getPbValue(cfg)..");\n"
        end
        str = string.format(str,ptf)
        fstr = fstr..str
    else
        local str = [[
{
    for(auto& v:pb)
    {
        insert_%s(v,db,_buff,_size);
    }
}

]]
        str = string.format(str,cfg._table)
        fstr = fstr..str
    end

    return fstr
end

function get_replace_func( cfg,v,_vec )
    local fstr = getFuncStr(cfg,v,_vec)
    if _vec == nil then
        local str = [[
{
    %s
    db.excute(_buff);
}

]]

        local ptf = 'snprintf(_buff, _size,'
        ptf = ptf..'"REPLACE INTO `'..cfg._table..'`'..getFileStr(cfg)
        ptf = ptf.." VALUES "..getValueStr(cfg)..';",\n'
        ptf = ptf..getPbValue(cfg)..");\n"
        str = string.format(str,ptf)
        fstr = fstr..str
    else
        local str = [[
{
    for(auto& v:pb)
    {
        replace_%s(v,db,_buff,_size);
    }
}

]]
        str = string.format(str,cfg._table)
        fstr = fstr..str
    end

    return fstr
end

function get_delete_func( cfg,v,_vec )
    local fstr = getFuncStr(cfg,v,_vec)
	local key = v._key or cfg._key
    if _vec == nil then
        local str = [[
{
    %s
    db.excute(_buff);
}

]]

        local ptf = 'snprintf(_buff, _size,'
		if #key == 0 then
			ptf = ptf..'"DELETE FROM `'..cfg._table..'`;");'
		else
			ptf = ptf..'"DELETE FROM `'..cfg._table..'` WHERE '..getWhereStr(cfg,key,v._logic)..';",'
			ptf = ptf..getPbValue(cfg,key)..");\n"
		end
        str = string.format(str,ptf)
        fstr = fstr..str
    else
        local str = [[
{
    for(auto& v:pb)
    {
        delete_%s(v,db,_buff,_size);
    }
}

]]
        str = string.format(str,cfg._table)
        fstr = fstr..str
    end

    return fstr
end

function get_update_func( cfg,v,_vec )
    local fstr = getFuncStr(cfg,v,_vec)
    if _vec == nil then
        local str = [[
{
    %s
    db.excute(_buff);
}

]]

		local setfunc = getSetStr
		local valfunc = getPbValue
		local fieldtab = cfg

		if v._field and #v._field > 0 then
			setfunc = function (ftab)
				return getSetStr(ftab,{})
			end
			valfunc = function (ftab)
				return getPbValue(ftab)
			end
			fieldtab = v
		end

        local ptf = 'snprintf(_buff, _size,'
        ptf = ptf..'"UPDATE `'..cfg._table..'` SET '..setfunc(fieldtab,cfg._key)..' WHERE '..getWhereStr(cfg,cfg._key,v._logic)..';",\n'
        ptf = ptf..valfunc(fieldtab,cfg._key,true)..","..getPbValue(cfg,cfg._key)..");\n"
        str = string.format(str,ptf)
        fstr = fstr..str
    else
        local str = [[
{
    for(auto& v:pb)
    {
        update_%s(v,db,_buff,_size);
    }
}

]]
        str = string.format(str,cfg._table)
        fstr = fstr..str
    end

    return fstr
end

function get_pb_set_str( cfg,pb )
    local pb = pb or "pb"
    local str = ""
    for i,v in ipairs(cfg._field) do
        str = str..string.format('\t\t%s.set_%s(r.%s("%s"));\n',pb,string.lower(v[1]),get_get_val_func(v[2]),v[1])
    end
    return str
end

function get_pb_set_default( cfg,key )
    local pb = "pb"
    local str = ""

	local havedef = false
    for i,v in ipairs(cfg._field) do
		if v[3] then
			havedef = true
			if v[2] == SQL_STRING then
				str = str..string.format('\t\t%s.set_%s("%s");\n',pb,string.lower(v[1]),v[3])
			else
				str = str..string.format('\t\t%s.set_%s(%s);\n',pb,string.lower(v[1]),v[3])
			end
		end
    end
	if havedef then
		for _, k in ipairs(key) do
			local fv = cfg._field[k]
			str = str..string.format('\t\t%s.set_%s(_%s);\n',pb,string.lower(fv[1]),fv[1])
		end
	end
    return str
end

function get_select_func( cfg,v,_vec )
    local fstr = getFuncStr(cfg,v,_vec)
    local key = v._key or cfg._key
    local str = ""
    if _vec == nil then
        str = [[
{
    %s
    auto& r = db.query(_buff);

    if (!r.eof())
    {
%s
		return true;
    }%s
	return false;
}

]]
    else
        str = [[
{
    %s
    auto& r = db.query(_buff);

    while (!r.eof())
    {
        auto& e = *pb.Add();
%s
        r.nextRow();
    }
}

]]
    end

	local fieldstr = "*"
	local setdata = cfg
	if v._field then
		fieldstr = getFileStr(v,true)
		setdata = v
	end

	local cond = ""
	if #key > 0 then
		cond = ' WHERE '..getWhereStr(cfg,key,v._logic)
	end

    local ptf = 'snprintf(_buff, _size,'
    ptf = ptf..'"SELECT '..fieldstr..' FROM `'..cfg._table..'`'..cond..';"'
	if #key > 0 then
		ptf = ptf..getKeyStr(cfg,key,true)..");\n"
	else
		ptf = ptf..");\n"
	end

    if _vec == nil then
		local defstr = get_pb_set_default(setdata,key)
		if defstr ~= "" then
			local estr = [[
else{
%s
		return true;
	}
]]
			defstr = string.format(estr,defstr)
		end
        str = string.format(str,ptf,get_pb_set_str(setdata),defstr)
    else
        str = string.format(str,ptf,get_pb_set_str(setdata,"e"))
    end
    fstr = fstr..str

    return fstr
end

function getCppStr( cfg )
    local str = ""
    for i,v in ipairs(cfg._sql) do
        local fstr = ""
        if v._type == SQL_TYPE_INSERT then
            fstr = get_insert_func(cfg,v)
            if v._vec then
                fstr = fstr..get_insert_func(cfg,v,true)
            end
        elseif v._type == SQL_TYPE_REPLACE then
            fstr = get_replace_func(cfg,v)
            if v._vec then
                fstr = fstr..get_replace_func(cfg,v,true)
            end
        elseif v._type == SQL_TYPE_DELETE then
            fstr = get_delete_func(cfg,v)
            if v._vec then
                fstr = fstr..get_delete_func(cfg,v,true)
            end
        elseif v._type == SQL_TYPE_UPDATE then
            fstr = get_update_func(cfg,v)
            if v._vec then
                fstr = fstr..get_update_func(cfg,v,true)
            end
        elseif v._type == SQL_TYPE_SELECT then
            if v._vec == true then
                fstr = get_select_func(cfg,v,v._vec)
            else
                fstr = get_select_func(cfg,v)
            end
        end
        str = str..fstr
    end
    return str
end

function getHstr( cfg )
    local str = ""
    for i,v in ipairs(cfg._sql) do
        local fs = ""
        if v._type == SQL_TYPE_SELECT then
            fs = getFuncStr(cfg,v,v._vec)..";\n"
        else
            fs = getFuncStr(cfg,v)..";\n"
            if v._vec then
                fs = fs..getFuncStr(cfg,v,true)..";\n"
            end
        end
        str = str..fs
    end
    return str.."\n"
end

function getTablePbName()
	local str = [[
TABLE_PROTO_NAME = {
%s
}
]]

	local name = ""
	for i,v in pairs(conf) do
		local s = string.format("\t[%d]=\"Proto.%s\",\n",i,v._proto)
		name = name..s
	end
	for i, v in ipairs(LOG_CONF) do
		local s = string.format("\t[%d]=\"Proto.%s\",\n",1000+i,v._proto)
		name = name..s
	end

	return string.format(str,name)
end

local desc = "//?????????????????????,?????????server/bin/tool/genProtoDb.bat ???proto_db_conf.lua?????????\n"
local desclua = "--?????????????????????,?????????server/bin/tool/genProtoDb.bat ???proto_db_conf.lua?????????\n"

function genCpp(path)

    local file_h = myfile.new()
    local file_cpp = myfile.new()
    local file_enum = myfile.new()
	local file_lua = myfile.new()

    file_h:open(path.."/proto_sql.h","w")
    file_cpp:open(path.."/proto_sql.cpp","w")
    file_enum:open(path.."/proto_table.h","w")
	file_lua:open(lua_path.."/table_index.lua","w")

	file_h:write(desc)
	file_cpp:write(desc)
	file_enum:write(desc)
	file_lua:write(desclua)

file_h:write([[
#ifndef PROTO_SQL_H
#define PROTO_SQL_H

namespace gopb = google::protobuf;
namespace Net {
    class MySqlDBGuard;
}

]])


file_cpp:write([[
#include "Server.pb.h"
#include "proto_sql.h"
#include "DBPool.h"
using namespace Net;

]])

file_enum:write([[
#ifndef PROTO_TABLE_H
#define PROTO_TABLE_H

enum TABLE_ENUM{

]])

file_lua:write([[
TABLE_INDEX = {
]])

    for k,v in pairs(conf) do
        file_h:write(getHstr(v))
        file_cpp:write(getCppStr(v))
        file_enum:write("TAB_"..v._table.."="..k..",\n")
		file_lua:write("TAB_"..v._table.."="..k..",\n")
    end
	file_enum:write("TAB_max,\n")

	for k, v in ipairs(LOG_CONF) do
		file_h:write(getHstr(v))
        file_cpp:write(getCppStr(v))
		local nk = 1000 + k
        file_enum:write("TAB_"..v._table.."="..nk..",\n")
		file_lua:write("TAB_"..v._table.."="..nk..",\n")
	end

    file_h:write("#endif")
    file_h:close()
    file_cpp:close()

    file_enum:write("};\n#endif")
    file_enum:close()

	file_lua:write("}\n")

	file_lua:write(getTablePbName())
	file_lua:write([[
REDIS_KEY = {
]])
	for i,v in pairs(conf) do
		local s = "\t[%d]={%s},\n"
		local k = ""
		for _, f in ipairs(v._rediskey) do
			k = k..string.format("\"%s\",",f)
		end
		s = string.format(s,i,k)
		file_lua:write(s)
	end
	for i,v in ipairs(LOG_CONF) do
		local s = "\t[%d]={%s},\n"
		local k = ""
		for _, f in ipairs(v._rediskey) do
			k = k..string.format("\"%s\",",f)
		end
		s = string.format(s,1000+i,k)
		file_lua:write(s)
	end
	file_lua:write("}\n")
	file_lua:close()
end

-- genCpp(out_path)
genCpp(out_path2)
print("finish ...")