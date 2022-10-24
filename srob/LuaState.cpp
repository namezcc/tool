#include "LuaState.h"
#include "Logger.h"
#include <iostream>
#include <cmath>
extern "C" {
#include "mpb.h"
}

#include "AsioPacket.h"
#include "DayTime.h"

LuaState::LuaState(int32_t id)
	: m_id(id), m_beginIndex(0), m_endIndex(0), m_commonCall(NULL),
	m_cToLBegIndex(0), m_cToLEndIndex(0), m_cTolRef(NULL), m_common_ref(0)
{
	m_L = luaL_newstate();
	luaL_openlibs(m_L);
	luaopen_pb(m_L);
	lua_settop(m_L, 0);
	open_libs();
	RegistCallFunc();
	PushSelf();
	lua_settop(m_L, 0);
}

LuaState::~LuaState()
{
	lua_close(m_L);

	if (m_commonCall)
	{
		delete[] m_commonCall;
		m_commonCall = NULL;
	}

	if (m_cTolRef)
	{
		delete[] m_cTolRef;
		m_cTolRef = NULL;
	}
}

void LuaState::RunUpdateFunc(const int64_t & dt)
{
	for(auto& ref : m_loopRef)
	{
		CallRegistFuncTpl(ref, dt);
	}
}

void LuaState::RunScript(const std::string & file)
{
	lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
	int status = luaL_loadfile(m_L, file.c_str());
	if (status)
	{
		report(m_L);
		return;
	}

	status = lua_pcall(m_L,0, LUA_MULTRET,lua_gettop(m_L)-1);
	if (status != 0)
	{
		report(m_L);
	}
}

void LuaState::RunString(const std::string & trunk)
{
	int status = luaL_dostring(m_L, trunk.c_str());
	if (status != 0)
	{
		report(m_L);
	}
}

void LuaState::initLuaCommonFunc(const std::string & name)
{
	ExitLuaClearStack _call(m_L);
	lua_getglobal(m_L, name.c_str());
	if (!lua_isfunction(m_L, -1))
	{
		LOG_ERROR("initLuaCommonFunc error can not find func %s\n", name.c_str());
		return;
	}
	m_common_ref = luaL_ref(m_L, LUA_REGISTRYINDEX);
}

void LuaState::initLToCIndex(uint32_t _began, uint32_t _end)
{
	if (_began > _end)
		std::swap(_began, _end);

	m_beginIndex = _began;
	m_endIndex = _end;
	m_commonCall = new LuaCallHandle[_end - _began];

	if (m_luaCallFunc)
	{
		m_luaCallFunc = NULL;
	}
}

void LuaState::initCToLIndex(uint32_t _began, uint32_t _end)
{
	if (_began > _end)
		std::swap(_began, _end);

	m_cToLBegIndex = _began;
	m_cToLEndIndex = _end;
	m_cTolRef = new int32_t[_end - _began];
	memset(m_cTolRef, 0, sizeof(int32_t)*(_end - _began));
}

void LuaState::bindLToCFunc(int32_t findex, const LuaCallHandle & func)
{
	if (m_commonCall == NULL)
	{
		LOG_ERROR("need call initLToCIndex  first\n");
		return;
	}

	if (findex < m_beginIndex || findex >= m_endIndex)
	{
		LOG_ERROR("bind LToc index out of rang %d\n",findex);
		return;
	}
	m_commonCall[findex] = func;
}

std::string errparam;

void LuaState::PrintError()
{
	LuaVString err;
	err.pullValue(m_L, -1);
	LOG_ERROR("Lua error: \n%s\n", err.m_val.data());
	LOG_ERROR("Lua error param: \n%s\n", errparam.data());

	if (m_error_log_func)
	{
		m_error_log_func(err.m_val,errparam);
	}
	errparam.clear();
}

bool LuaState::getRefFunc(int32_t ref)
{
	lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
	lua_rawgeti(m_L, LUA_REGISTRYINDEX, ref);
	if (!lua_isfunction(m_L, -1))
	{
		//LOG_ERROR("lua func not a function\n");
		return false;
	}
	return true;
}

void LuaState::l_message(const char *msg)
{
	LOG_ERROR("Lua error: %s\n", msg);
	if (errparam.size() > 0)
	{
		LOG_ERROR("Lua error param: %s\n", errparam.data());
	}

	if (m_error_log_func)
	{
		m_error_log_func(std::string(msg), errparam.data());
	}
	errparam.clear();
	//if (pname) lua_writestringerror("%s: ", pname);
	//lua_writestringerror("%s\n", msg);
}

//int LuaState::callFunction(lua_State* L)
//{
//	/*
//	if (lua_gettop(L) < 2)
//	{
//		std::cout << "args num < 2 " << std::endl;
//		return 0;
//	}
//	if (!lua_islightuserdata(L, 1))
//	{
//		std::cout << "get null " << std::endl;
//		return 0;
//	}
//	auto ptr = (LuaState*)lua_touserdata(L, 1);
//	if (!lua_isstring(L, 2))
//	{
//		std::cout << "error arg 2 not string " << std::endl;
//		return 0;
//	}
//	auto fname = lua_tostring(L, 2);
//	auto it = ptr->m_luaCallFunc.find(fname);
//	if (it != ptr->m_luaCallFunc.end())
//		return it->second(L);
//	*/
//	return 0;
//}

int LuaState::callFunction2(lua_State * L)
{
	if (lua_gettop(L) < 2)
	{
		printLuaFuncStack(L, "args num < 2 ");
		return 0;
	}
	if (!lua_islightuserdata(L, 1))
	{
		printLuaFuncStack(L, "get null ");
		return 0;
	}
	auto ptr = (LuaState*)lua_touserdata(L, 1);
	if (!lua_isinteger(L, 2))
	{
		printLuaFuncStack(L,"error arg 2 not int ");
		return 0;
	}

	lua_State* oldL = ptr->m_L;
	if (ptr->m_L != L)
		ptr->m_L = L;

	std::shared_ptr<void> _exit(NULL, [oldL,L,ptr](void*) {
		if (L != oldL)
			ptr->m_L = oldL;
	});

	auto findex = (int32_t)lua_tointeger(L, 2);
	ptr->m_argIndex = 2;

	if (ptr->m_commonCall != NULL && findex >= ptr->m_beginIndex && findex < ptr->m_endIndex)
	{
		if (ptr->m_commonCall[findex])
		{
			return ptr->m_commonCall[findex](ptr);
		}
		else
		{
			LOG_ERROR("common func not bind %d\n", findex);
		}
	}
	else{
		if (!ptr->m_luaCallFunc)
		{
			printLuaFuncStack(L, "not set lua call func");
			return 0;
		}
		return ptr->m_luaCallFunc(findex, ptr);
	}
	return 0;
}

int LuaState::bindLuaFunc(lua_State * L)
{
	if (lua_gettop(L) != 3)
	{
		printLuaFuncStack(L,"args num < 2 ");
		return 0;
	}
	if (!lua_islightuserdata(L, 1))
	{
		printLuaFuncStack(L,"get null ");
		return 0;
	}
	if (!lua_isinteger(L, 2))
	{
		printLuaFuncStack(L,"error arg 2 not int " );
		return 0;
	}
	if (!lua_isfunction(L, -1))
	{
		printLuaFuncStack(L,"error arg 3 not func ");
		return 0;
	}

	auto ptr = (LuaState*)lua_touserdata(L, 1);
	auto findex = (int32_t)lua_tointeger(L, 2);

	if (ptr == NULL)
	{
		printLuaFuncStack(L, "ptr == NULL ");
		return 0;
	}

	if (ptr->m_cTolRef && findex >= ptr->m_cToLBegIndex && findex < ptr->m_cToLEndIndex)
	{
		//解除老的引用
		if (ptr->m_cTolRef[findex] > 0)
			luaL_unref(L, LUA_REGISTRYINDEX, ptr->m_cTolRef[findex]);

		ptr->m_cTolRef[findex] = luaL_ref(L, LUA_REGISTRYINDEX);
	}
	else
	{
		if (!ptr->m_luaBindFunc)
			printLuaFuncStack(L, "not set lua bind func ");
		else
			ptr->m_luaBindFunc(findex, ptr);
	}
	return 0;
}

int LuaState::printFunction(lua_State * L)
{
	int n = lua_gettop(L);  /* number of arguments */
	if (n < 2)
	{
		printLuaFuncStack(L, "print func args num error");
		return 0;
	}

	if (!lua_isinteger(L, 1))
	{
		printLuaFuncStack(L, "print func level type error");
		return 0;
	}


	int32_t level = (int32_t)lua_tointeger(L, 1);
	int i;
	lua_getglobal(L, "tostring");
	std::string log;
	for (i = 2; i <= n; i++) {
		const char *s;
		size_t l;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		s = lua_tolstring(L, -1, &l);  /* get result */
		if (s == NULL)
		{
			printLuaFuncStack(L, "'tostring' must return a string to 'print'");
			return 0;
		}
		log.append(s, l);
		log.append(" ");
		lua_pop(L, 1);  /* pop result */
	}
	log.append("\n");
	/*if (log.size() > 998)
	{
		int writeSize = 0;
		while (writeSize < log.size()) {
			auto subStr = log.substr(writeSize, 512);
			subStr.append("\n");
			Net::Logger::print(Net::LogLevel(level), subStr.c_str());
			writeSize += 512;
		}
	}
	else*/
	{
		Net::Logger::print(Net::LogLevel(level), log.c_str());
	}
	return 0;
}

//int LuaState::open_callFunc(lua_State* L)
//{
//	luaL_Reg lib_s[] = {
//		{ "callFunction",callFunction },
//	{ NULL,NULL }
//	};
//
//	luaL_newlib(L, lib_s);
//	return 1;
//}

char tracebuff[4096] = {0};

static int l_traceback(lua_State *L) {
	size_t msgsz;
	const char *msg = luaL_checklstring(L, 1, &msgsz);
	int level = (int)luaL_optinteger(L, 2, 1);
	int max = (int)luaL_optinteger(L, 3, 20) + level;

	lua_Debug ar;
	int top = lua_gettop(L);
	if (msg)
		lua_pushfstring(L, "%s\n", msg);
	luaL_checkstack(L, 10, NULL);
	lua_pushliteral(L, "STACK TRACEBACK:");
	int n;
	const char *name;

	errparam.clear();

	while (lua_getstack(L, level++, &ar)) {
		lua_getinfo(L, "Slntu", &ar);
		lua_pushfstring(L, "\n=> %s:%d in ", ar.short_src, ar.currentline);
		if (ar.name)
			lua_pushstring(L, ar.name);
		else if (ar.what[0] == 'm')
			lua_pushliteral(L, "mainchunk");
		else
			lua_pushliteral(L, "?");
		if (ar.istailcall)
			lua_pushliteral(L, "\n(...tail calls...)");
		lua_concat(L, lua_gettop(L) - top);     // <str>

		errparam.append("\n--\n");
		// varargs
		n = -1;
		while ((name = lua_getlocal(L, &ar, n--)) != NULL) {    // <str|value>

			sprintf(tracebuff,"\n    %s = ", name);
			errparam.append(tracebuff);
			size_t plen = 0;
			auto pam = luaL_tolstring(L, -1, &plen);
			errparam.append(pam,plen <= 1024 ? plen : 1024);
			
			//lua_pushfstring(L, "\n    %s = ", name);        // <str|value|name>
			//luaL_tolstring(L, -2, NULL);    // <str|value|name|valstr>
			//lua_remove(L, -3);  // <str|name|valstr>
			//lua_concat(L, lua_gettop(L) - top);     // <str>
			lua_pop(L, 2);
		}

		// arg and local
		n = 1;
		while ((name = lua_getlocal(L, &ar, n++)) != NULL) {    // <str|value>
			if (name[0] == '(') {
				lua_pop(L, 1);      // <str>
			}
			else {
				int vt = lua_type(L, -1);
				if (vt == LUA_TTABLE || vt == LUA_TFUNCTION)
				{
					lua_pop(L, 1);
					continue;
				}
				if (n <= ar.nparams + 1)
				{
					//lua_pushfstring(L, "\n    param %s = ", name);      // <str|value|name>
					sprintf(tracebuff, "\n    param %s = ", name);
					errparam.append(tracebuff);
				}
				else
				{
					//lua_pushfstring(L, "\n    local %s = ", name);      // <str|value|name>
					sprintf(tracebuff, "\n    local %s = ", name);
					errparam.append(tracebuff);
				}
				size_t plen = 0;
				auto pam = luaL_tolstring(L, -1, &plen);
				errparam.append(pam, plen <= 1024 ? plen : 1024);
				//luaL_tolstring(L, -2, NULL);    // <str|value|name|valstr>
				//lua_remove(L, -3);  // <str|name|valstr>
				//lua_concat(L, lua_gettop(L) - top);     // <str>
				lua_pop(L, 2);
			}
		}

		if (level > max)
			break;
	}
	lua_concat(L, lua_gettop(L) - top);
	return 1;
}

int LuaState::traceback(lua_State * L)
{
	/*const char *msg = lua_tostring(L, -1);
	if (msg)
		luaL_traceback(L, L, msg, 1);
	else
		lua_pushliteral(L, "no message");*/
	l_traceback(L);
	return 1;
}

int net_readint16(lua_State * L)
{
	if (lua_islightuserdata(L, -1))
	{
		auto msg = (Net::AsioPacket*)lua_touserdata(L, -1);
		lua_pushinteger(L, msg->readInt16());
	}
	else
	{
		LuaState::printLuaFuncStack(L, "readerror not netMsg*");
		lua_pushinteger(L, 0);
	}
	return 1;
}

int net_readint32(lua_State * L)
{
	if (lua_islightuserdata(L, -1))
	{
		auto msg = (Net::AsioPacket*)lua_touserdata(L, -1);
		lua_pushinteger(L, msg->readInt32());
	}
	else
	{
		LuaState::printLuaFuncStack(L, "readerror not netMsg*");
		lua_pushinteger(L, 0);
	}
	return 1;
}

int net_readint64(lua_State * L)
{
	if (lua_islightuserdata(L, -1))
	{
		auto msg = (Net::AsioPacket*)lua_touserdata(L, -1);
		lua_pushinteger(L, msg->readInt64());
	}
	else
	{
		LuaState::printLuaFuncStack(L, "readerror not netMsg*");
		lua_pushinteger(L, 0);
	}
	return 1;
}

int net_readstring(lua_State * L)
{
	if (lua_islightuserdata(L, -1))
	{
		auto msg = (Net::AsioPacket*)lua_touserdata(L, -1);
		auto buf = msg->readUTF8();
		lua_pushlstring(L, buf.c_str(), buf.length());
	}
	else
	{
		LuaState::printLuaFuncStack(L, "readerror not netMsg*");
		lua_pushstring(L, "");
	}
	return 1;
}

int net_readbuff(lua_State * L)
{
	if (lua_islightuserdata(L, -1))
	{
		auto msg = (Net::AsioPacket*)lua_touserdata(L, -1);
		int32_t len = 0;
		auto buf = msg->readBuff(len);
		lua_pushlstring(L, buf, len);
	}
	else
	{
		LuaState::printLuaFuncStack(L, "readerror not netMsg*");
		lua_pushstring(L, "");
	}
	return 1;
}

int net_make_buff(lua_State * L)
{
	if (!lua_islightuserdata(L, -1))
		return 0;

	auto ptr = (LuaState*)lua_touserdata(L, -1);

	auto pack = ptr->popNetPack();
	lua_pushlightuserdata(L, pack);
	return 1;
}

int net_writeint16(lua_State * L)
{
	if (lua_islightuserdata(L, -2))
	{
		auto num = luaL_checkinteger(L, -1);
		auto pack = (Net::AsioPacket*)lua_touserdata(L, -2);
		pack->writeInt16((int16_t)num);
	}
	else
	{
		LuaState::printLuaFuncStack(L, "write not AsioPacket*");
	}
	return 0;
}

int net_writeint32(lua_State * L)
{
	if (lua_islightuserdata(L, -2))
	{
		auto num = luaL_checkinteger(L, -1);
		auto pack = (Net::AsioPacket*)lua_touserdata(L, -2);
		pack->writeInt32((int32_t)num);
	}
	else
	{
		LuaState::printLuaFuncStack(L, "write not AsioPacket*");
	}
	return 0;
}

int net_writeint64(lua_State * L)
{
	if (lua_islightuserdata(L, -2))
	{
		auto num = luaL_checkinteger(L, -1);
		auto pack = (Net::AsioPacket*)lua_touserdata(L, -2);
		pack->writeInt64((int64_t)num);
	}
	else
	{
		LuaState::printLuaFuncStack(L, "write not AsioPacket*");
	}
	return 0;
}

int net_writestring(lua_State * L)
{
	if (lua_islightuserdata(L, -2))
	{
		if (!lua_isstring(L, -1))
		{
			LuaState::printLuaFuncStack(L, "write arg not string");
			return 0;
		}
		size_t len;
		auto buf = lua_tolstring(L, -1, &len);
		auto pack = (Net::AsioPacket*)lua_touserdata(L, -2);
		pack->writeUTF8(std::string(buf, len));
	}
	else
	{
		LuaState::printLuaFuncStack(L, "write not AsioPacket*");
	}
	return 0;
}

int net_writebuff(lua_State * L)
{
	if (lua_islightuserdata(L, -2))
	{
		if (!lua_isstring(L, -1))
		{
			LuaState::printLuaFuncStack(L, "write arg not string");
			return 0;
		}
		size_t len;
		auto buf = lua_tolstring(L, -1, &len);
		auto pack = (Net::AsioPacket*)lua_touserdata(L, -2);
		pack->writeBytes(buf, (int32_t)len);
	}
	else
	{
		LuaState::printLuaFuncStack(L, "write not AsioPacket*");
	}
	return 0;
}

void LuaState::open_libs()
{
	luaL_Reg lib_s[] = {
		{ "readint16",net_readint16 },
		{ "readint32",net_readint32 },
		{ "readint64",net_readint64 },
		{ "readstring",net_readstring },
		{ "readbuff",net_readbuff },
		{ "makepack",net_make_buff},
		{ "writeint16",net_writeint16},
		{ "writeint32",net_writeint32},
		{ "writeint64",net_writeint64},
		{ "writestring",net_writestring},
		{ "writebuff",net_writebuff},
	{ NULL,NULL }
	};

	lua_newtable(m_L);
	lua_setglobal(m_L, "NetMsg");
	lua_getglobal(m_L, "NetMsg");
	luaL_setfuncs(m_L, lib_s, 0);
	lua_settop(m_L, 0);
}

void LuaState::RegistCallFunc()
{
	luaL_Reg lib_s[] = {
		//{ "callFunction", callFunction },
		{ "callPrint", printFunction },
		{ "luaCallC", callFunction2},
		{ "bindLuaFunc", bindLuaFunc},
		{ NULL,NULL }
	};

	luaL_newmetatable(m_L, "Module");
	lua_pushvalue(m_L, -1);
	lua_setfield(m_L, -2, "__index");
	luaL_setfuncs(m_L, lib_s, 0);
}

#define LuaStateName "CLuaState"

void LuaState::PushSelf()
{
	lua_pushlightuserdata(m_L, (void*)this);
	lua_setglobal(m_L, LuaStateName);

	lua_getglobal(m_L, LuaStateName);
	luaL_getmetatable(m_L, "Module");
	lua_setmetatable(m_L, -2);

	// 向注册表中注册lua 出错调试函数
	lua_pushcfunction(m_L, traceback);
	m_errIndex = luaL_ref(m_L, LUA_REGISTRYINDEX);
}

void LuaState::printLuaStack(lua_State *L)
{
	int nIndex;
	int nType;
	fprintf(stderr, "================栈顶================\n");
	fprintf(stderr, "   索引  类型          值\n");
	for (nIndex = lua_gettop(L); nIndex > 0; --nIndex) {
		nType = lua_type(L, nIndex);
		fprintf(stderr, "   (%d)  %s         %s\n", nIndex,
			lua_typename(L, nType), lua_tostring(L, nIndex));
	}
	fprintf(stderr, "================栈底================\n");
}

void LuaState::printLuaFuncStack(lua_State * L,const char* msg)
{
	luaL_traceback(L, L, msg, 1);
	LOG_ERROR("Lua error: %s\n", lua_tostring(L, -1));
	lua_pop(L, 1);
}

int32_t LuaState::PullInt32()
{
	if (lua_isinteger(m_L, m_argIndex+1))
	{
		++m_argIndex;
		return (int32_t)lua_tointeger(m_L, m_argIndex);
	}
	else if (lua_isnumber(m_L, m_argIndex + 1))
	{
		++m_argIndex;
		double tmpV = lua_tonumber(m_L, m_argIndex);
		return (int32_t)std::lround(tmpV);
	}
	else
	{
		LOG_ERROR("PullInt32 not a number: %d\n", (m_argIndex + 1));
	}
		
	return 0;
}

int64_t LuaState::PullInt64()
{
	if (lua_isinteger(m_L, m_argIndex+1))
	{
		++m_argIndex;
		return lua_tointeger(m_L, m_argIndex);
	}
	else if (lua_isnumber(m_L, m_argIndex + 1))
	{
		++m_argIndex;
		double tmpV = lua_tonumber(m_L, m_argIndex);
		return std::llroundl(tmpV);
	}
	else
	{
		LOG_ERROR("PullInt64 not a number: %d\n", (m_argIndex+1));
	}
	return 0;
}

std::string LuaState::PullString()
{
	if (lua_isstring(m_L, m_argIndex+1))
	{
		++m_argIndex;
		size_t len;
		auto c = lua_tolstring(m_L, m_argIndex, &len);
		return std::string(c,len);
	}
	return "";
}

const char * LuaState::PullCString(int32_t & size)
{
	if (lua_isstring(m_L, m_argIndex + 1))
	{
		++m_argIndex;
		size_t len;
		auto c = lua_tolstring(m_L, m_argIndex, &len);
		size = len;
		return c;
	}
	return NULL;
}

float LuaState::Pullfloat()
{
	if (lua_isnumber(m_L, m_argIndex+1))
	{
		++m_argIndex;
		return (float)lua_tonumber(m_L, m_argIndex);
	}
	return 0.0f;
}

void * LuaState::pullUserData()
{
	if (lua_islightuserdata(m_L, m_argIndex + 1))
	{
		++m_argIndex;
		return lua_touserdata(m_L, m_argIndex);
	}
	return NULL;
}

bool LuaState::IsTable(int32_t argIndex)
{
	return lua_istable(m_L, argIndex);
}

bool LuaState::PullTableBegin()
{
	if (!lua_istable(m_L, m_argIndex+1))
		return false;
	++m_argIndex;
	lua_pushvalue(m_L, m_argIndex);
	return true;
}

int32_t LuaState::PullTableLength()
{
	lua_len(m_L, -1);
	auto val = (int32_t)lua_tointeger(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

int32_t LuaState::PullTableInt32(int32_t index)
{
	lua_rawgeti(m_L, -1, index);
	auto val = (int32_t)luaL_checkinteger(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

int64_t LuaState::PullTableInt64(int32_t index)
{
	lua_rawgeti(m_L, -1, index);
	auto val = (int64_t)luaL_checkinteger(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

std::string LuaState::PullTableString(int32_t index)
{
	lua_rawgeti(m_L, -1, index);
	size_t len;
	auto buff = lua_tolstring(m_L, -1, &len);
	lua_pop(m_L, 1);
	return std::string(buff,len);
}

float LuaState::PullTableFloat(int32_t index)
{
	lua_rawgeti(m_L, -1, index);
	auto val = (float)luaL_checknumber(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

bool LuaState::PullTableTable(int32_t index)
{
	lua_rawgeti(m_L, -1, index);
	if (lua_istable(m_L, -1))
		return true;
	lua_pop(m_L, 1);
	return false;
}

int32_t LuaState::PullTableInt32(const std::string & key)
{
	lua_getfield(m_L, -1, key.data());
	auto val = (int32_t)luaL_checkinteger(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

int64_t LuaState::PullTableInt64(const std::string & key)
{
	lua_getfield(m_L, -1, key.data());
	auto val = (int64_t)luaL_checkinteger(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

std::string LuaState::PullTableString(const std::string & key)
{
	lua_getfield(m_L, -1, key.data());
	size_t len;
	auto buff = lua_tolstring(m_L, -1, &len);
	lua_pop(m_L, 1);
	return std::string(buff,len);
}

float LuaState::PullTableFloat(const std::string & key)
{
	lua_getfield(m_L, -1, key.data());
	auto val = (float)luaL_checknumber(m_L, -1);
	lua_pop(m_L, 1);
	return val;
}

bool LuaState::PullTableTable(const std::string & key)
{
	lua_getfield(m_L, -1, key.data());
	if (lua_istable(m_L, -1))
		return true;
	lua_pop(m_L, 1);
	return false;
}

void LuaState::PullTableEnd()
{
	lua_pop(m_L, 1);
}

bool LuaState::callLuaCommonFunc(LuaArgs & arg)
{
	return callLuaFunc(m_common_ref, arg);
}

bool LuaState::callLuaFunc(int32_t findex, LuaArgs & arg)
{
	if (m_cTolRef == NULL)
	{
		LOG_ERROR("need init initCToLIndex or callRegistFunc\n");
		return false;
	}

	if (findex < m_cToLBegIndex || findex >= m_cToLEndIndex)
	{
		LOG_ERROR("findex out of range %d\n",findex);
		return false;
	}

	return callRegistFunc(m_cTolRef[findex - m_cToLBegIndex],arg);
}

bool LuaState::callRegistFunc(int32_t ref, LuaArgs & arg)
{
	ExitLuaClearStack _call(m_L);

	if (!getRefFunc(ref))
		return false;

	int32_t rnum = arg.m_res.size();
	int32_t anum = arg.m_arg.size();

	int es = -2 - anum;

	for(auto& v:arg.m_arg)
	{
		v->pushValue(m_L);
	}

	m_call_state = 1;
	m_call_tick = Net::DayTime::tick() + 5000;

	if (lua_pcall(m_L, anum, rnum, es) != LUA_OK)
	{
		PrintError();
		m_call_state = 0;
		return false;
	}
	for (int32_t i = 0; i < rnum; i++)
	{
		arg.m_res[i]->pullValue(m_L, -rnum + i);
	}

	m_call_state = 0;
	return true;
}

void timeout_break(lua_State* l, lua_Debug* ar)
{
	lua_sethook(l, NULL, 0, 0);
	luaL_error(l, "deadloop time out");
}

void LuaState::checkDeadLoop()
{
	if (m_call_state == 1 && Net::DayTime::tick() > m_call_tick)
	{
		int mask = LUA_MASKCALL | LUA_MASKLINE | LUA_MASKRET | LUA_MASKCOUNT;
		lua_sethook(m_L, timeout_break, mask, 1);
	}
}

void LuaState::PushInt32(int32_t val)
{
	lua_pushinteger(m_L, val);
}

void LuaState::PushInt64(int64_t val)
{
	lua_pushinteger(m_L, val);
}

void LuaState::PushString(const std::string & val)
{
	lua_pushlstring(m_L, val.data(), val.size());
}

void LuaState::PushFloat(float val)
{
	lua_pushnumber(m_L, val);
}

void LuaState::PushTableBegin()
{
	lua_newtable(m_L);
}

void LuaState::PushTableBegin(int32_t tabkey)
{
	PushInt32(tabkey);
	lua_newtable(m_L);
}

void LuaState::PushTableBegin(const std::string & tabkey)
{
	PushString(tabkey);
	lua_newtable(m_L);
}

void LuaState::PushTableInt32(int32_t idx, int32_t val)
{
	lua_pushinteger(m_L, val);
	lua_rawseti(m_L, -2, idx);
}

void LuaState::PushTableInt64(int32_t idx, int64_t val)
{
	lua_pushinteger(m_L, val);
	lua_rawseti(m_L, -2, idx);
}

void LuaState::PushTableString(int32_t idx, const std::string & val)
{
	lua_pushlstring(m_L,val.data(),val.size());
	lua_rawseti(m_L, -2, idx);
}

void LuaState::PushTableFloat(int32_t idx, float val)
{
	lua_pushnumber(m_L, val);
	lua_rawseti(m_L, -2, idx);
}

void LuaState::PushTableEnd()
{
	lua_settable(m_L, -3);
}

void LuaState::PushTableSetValue()
{
	lua_settable(m_L, -3);
}

void LuaState::PushTableInt32(const std::string & key, int32_t val)
{
	lua_pushlstring(m_L, key.data(), key.size());
	lua_pushinteger(m_L, val);
	lua_settable(m_L, -3);
}

void LuaState::PushTableInt64(const std::string & key, int64_t val)
{
	lua_pushlstring(m_L, key.data(), key.size());
	lua_pushinteger(m_L, val);
	lua_settable(m_L, -3);
}

void LuaState::PushTableString(const std::string & key, const std::string & val)
{
	lua_pushlstring(m_L, key.data(), key.size());
	lua_pushlstring(m_L, val.data(), val.size());
	lua_settable(m_L, -3);
}

void LuaState::PushTableFloat(const std::string & key, float val)
{
	lua_pushlstring(m_L, key.data(), key.size());
	lua_pushnumber(m_L,val);
	lua_settable(m_L, -3);
}
