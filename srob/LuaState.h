#ifndef LUA_STATE_H
#define LUA_STATE_H
#include "funcutil.h"
#include "LuaUtil.h"
#include <unordered_map>
#include <iostream>
#include <memory>

#include "LuaValue.h"

class LuaState;

typedef std::function<int(LuaState*)> LuaCallHandle;

namespace Net {
	class AsioPacket;
}

struct ExitLuaClearStack
{
	lua_State* m_l;
	ExitLuaClearStack(lua_State* L) :m_l(L)
	{}

	~ExitLuaClearStack()
	{
		lua_settop(m_l, 0);
	}
};

class LuaState
{
public:
	LuaState(int32_t id);
	virtual ~LuaState();

	lua_State* GetL() { return m_L; }
	int32_t GetId() { return m_id; }
	void RunUpdateFunc(const int64_t& dt);
	void RunScript(const std::string& file);
	void RunString(const std::string& trunk);

	void initLuaCommonFunc(const std::string& name);
	void initLToCIndex(uint32_t _began, uint32_t _end);
	void initCToLIndex(uint32_t _began, uint32_t _end);
	void bindLToCFunc(int32_t findex,const LuaCallHandle& func);

	void setLuaCallFunc(const std::function<int(int32_t, LuaState*)>& func)
	{
		m_luaCallFunc = func;
	}
	void setLuaBindFunc(const std::function<int(int32_t, LuaState*)>& func)
	{
		m_luaBindFunc = func;
	}

	void setPopNetPacktFunc(const std::function<Net::AsioPacket*()>& func)
	{
		m_popPack = func;
	}

	void setErrorLogFunc(const std::function<void(const std::string&, const std::string&)>& func)
	{
		m_error_log_func = func;
	}

	int32_t RegistGlobalFunc(const std::string& fname,bool loop = false)
	{
		ExitLuaClearStack _call(m_L);
		lua_getglobal(m_L, fname.c_str());
		if (!lua_isfunction(m_L, -1))
		{
			return -1;
		}
		int32_t ref = luaL_ref(m_L, LUA_REGISTRYINDEX);
		if (loop)
			m_loopRef.push_back(ref);
		return ref;
	}

	template<typename ...Args>
	void CallGlobalLuaFunc(const std::string& funcstr, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_getglobal(m_L, funcstr.c_str());
		if (!lua_isfunction(m_L, -1))
		{
			return;
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), 0, es) != LUA_OK)
			PrintError();
	}

	template<typename T, typename ...Args>
	typename std::enable_if<!LuaReflect<T>::have_type, T>::type
		CallGlobalLuaFuncRes(const std::string& funcstr, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_getglobal(m_L, funcstr.c_str());
		if (!lua_isfunction(m_L, -1))
		{
			return T();
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), PullLuaArgs<T>::P_SIZE, es) != LUA_OK)
			PrintError();
		return PullLuaArgs<T>::PullVal(m_L);
	}

	template<typename T, typename ...Args>
	typename std::enable_if<LuaReflect<T>::have_type, T>::type
		CallGlobalLuaFuncRes(const std::string& funcstr, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_getglobal(m_L, funcstr.c_str());
		if (!lua_isfunction(m_L, -1))
		{
			return T();
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), PullLuaArgs<LuaReflect<T>>::P_SIZE, es) != LUA_OK)
			PrintError();
		return PullLuaArgs<LuaReflect<T>>::PullVal(m_L);
	}

	template<typename ...Args>
	void CallRegistFuncTpl(const int32_t& ref, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, ref);
		if (!lua_isfunction(m_L, -1))
		{
			return;
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), 0, es) != LUA_OK)
			PrintError();
	}

	template<typename T, typename ...Args>
	typename std::enable_if<!LuaReflect<T>::have_type, T>::type
		CallRegistFuncRes(const int32_t& ref, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, ref);
		if (!lua_isfunction(m_L, -1))
		{
			return T();
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), PullLuaArgs<T>::P_SIZE, es) != LUA_OK)
			PrintError();
		return PullLuaArgs<T>::PullVal(m_L);
	}

	template<typename T, typename ...Args>
	typename std::enable_if<LuaReflect<T>::have_type, T>::type
		CallRegistFuncRes(const int32_t& ref, Args&&... args)
	{
		ExitLuaClearStack _call(m_L);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, m_errIndex);
		lua_rawgeti(m_L, LUA_REGISTRYINDEX, ref);
		if (!lua_isfunction(m_L, -1))
		{
			return T();
		}
		if (sizeof...(Args)>0)
			PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		int es = -2 - static_cast<int>(sizeof...(Args));
		if (lua_pcall(m_L, sizeof...(Args), PullLuaArgs<LuaReflect<T>>::P_SIZE, es) != LUA_OK)
			PrintError();
		return PullLuaArgs<LuaReflect<T>>::PullVal(m_L);
	}

	void report(lua_State *L) {
		const char *msg = lua_tostring(L, -1);
		if (msg == NULL)
			return;
		l_message(msg);
		lua_pop(L, 1);  /* remove message */
	}

	/*template<typename T, typename F>
	void BindLuaCall(const std::string& fname, T&&t, F&&f)
	{
		auto call = ANY_BIND(t, f);
		m_luaCallFunc[fname] = [call](lua_State* L) {
			if (lua_gettop(L) - 2 != FuncArgsType<F>::SIZE)
			{
				l_message("error args num expect:", std::to_string(FuncArgsType<F>::SIZE).data());
				return 0;
			}
			return CallTool<FuncArgsType<F>::SIZE>::Call<typename FuncArgsType<F>::tupleArgs>(L, call);
		};
	}*/

	//template<typename T, typename F>
	//void BindLuaOrgCall(const std::string& fname, T&&t, F&&f)
	//{
	//	/*auto call = ANY_BIND(t, f);
	//	m_luaCallFunc[fname] = [call](lua_State* L){
	//	return call(L);
	//	};*/
	//	m_luaCallFunc[fname] = ANY_BIND(t, f);
	//}

	/*template<typename F>
	void BindLuaOrgCall(const std::string& fname, F&&f)
	{
		m_luaCallFunc[fname] = ANY_BIND_2(f);
	}*/

	
	bool callLuaCommonFunc(LuaArgs& arg);
	bool callLuaFunc(int32_t findex, LuaArgs& arg);
	bool callRegistFunc(int32_t ref, LuaArgs& arg);
	void checkDeadLoop();

	template<typename ...Args>
	int32_t PushArgs(Args&&... args)
	{
		PushLuaArgs::PushVal(m_L, std::forward<Args>(args)...);
		return sizeof...(Args);
	}

	//--------- new -------------------

	void PushInt32(int32_t val);
	void PushInt64(int64_t val);
	void PushString(const std::string& val);
	void PushFloat(float val);
	void PushTableBegin();
	void PushTableBegin(int32_t tabkey);
	void PushTableBegin(const std::string& tabkey);
	void PushTableInt32(int32_t idx, int32_t val);
	void PushTableInt64(int32_t idx, int64_t val);
	void PushTableString(int32_t idx, const std::string& val);
	void PushTableFloat(int32_t idx, float val);
	void PushTableEnd();
	void PushTableSetValue();
	void PushTableInt32(const std::string& key, int32_t val);
	void PushTableInt64(const std::string& key, int64_t val);
	void PushTableString(const std::string& key, const std::string& val);
	void PushTableFloat(const std::string& key, float val);

	int32_t PullInt32();
	int64_t PullInt64();
	std::string PullString();
	const char* PullCString(int32_t& size);
	float Pullfloat();
	void* pullUserData();
	bool IsTable(int32_t argIndex);
	int32_t GetArgIndex() { return m_argIndex; }
	bool PullTableBegin();
	int32_t PullTableLength();
	int32_t PullTableInt32(int32_t index);
	int64_t PullTableInt64(int32_t index);
	std::string PullTableString(int32_t index);
	float PullTableFloat(int32_t index);
	bool PullTableTable(int32_t index);
	int32_t PullTableInt32(const std::string& key);
	int64_t PullTableInt64(const std::string& key);
	std::string PullTableString(const std::string& key);
	float PullTableFloat(const std::string& key);
	bool PullTableTable(const std::string& key);
	void PullTableEnd();

	//--------------------------------

	static void printLuaFuncStack(lua_State *L, const char* msg);
	void PrintError();
	bool getRefFunc(int32_t ref);

	Net::AsioPacket* popNetPack()
	{
		return m_popPack();
	}
protected:

	void l_message(const char *msg);

	//static int callFunction(lua_State* L);
	static int callFunction2(lua_State* L);
	static int bindLuaFunc(lua_State* L);
	static int printFunction(lua_State* L);
	static int traceback(lua_State *L);

	//static int open_callFunc(lua_State* L);
	void open_libs();
	void RegistCallFunc();
	void PushSelf();
	static void printLuaStack(lua_State *L);

protected:
	lua_State * m_L;
	int32_t m_id;
	int32_t m_errIndex;
	std::vector<int32_t> m_loopRef;
	//std::unordered_map<std::string, std::function<int(lua_State*)>> m_luaCallFunc;
	int32_t m_argIndex;
	
	std::function<int(int32_t, LuaState*)> m_luaCallFunc;
	std::function<int(int32_t, LuaState*)> m_luaBindFunc;
	std::function<Net::AsioPacket*()> m_popPack;
	std::function<void(const std::string&, const std::string&)> m_error_log_func;

	int32_t m_beginIndex;
	int32_t m_endIndex;
	LuaCallHandle* m_commonCall;

	int32_t m_cToLBegIndex;
	int32_t m_cToLEndIndex;
	int32_t* m_cTolRef;

	int32_t m_common_ref;

	int64_t m_call_tick;
	int32_t m_call_state;
};

typedef std::shared_ptr<LuaState> LuaStatePtr;

#endif
