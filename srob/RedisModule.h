#ifndef REDIS_MODULE_H
#define REDIS_MODULE_H

#include <boost/serialization/singleton.hpp>
#include <memory>
#include <map>
#include <vector>

using namespace std;

#define SHARE std::shared_ptr
typedef std::vector<std::string> vec_str;
typedef std::pair<std::string, std::string> pair_str;
typedef std::map<std::string, std::string> string_map;

namespace redis {
	struct default_hasher;
	
	template<typename HS>
	class base_client;

	typedef base_client<default_hasher> client;
}

class RedisModule
{
public:
	RedisModule();
	~RedisModule();

	void Init();

	inline bool IsConnect() { return m_enable; };
	void SetConnect(const string& host, const string& pass, const int& port = 6379);
	bool Connect(const string& host, const string& pass, const int& port=6379);

	bool Del(const string& key);

	bool Set(const string& key, const string& val);
	bool Get(const string& key, string& val);
	bool Exists(const string& key);

	bool HSet(const string& key, const string& f, const string& v);
	bool HGet(const string& key,const string& f, string& v);
	bool HMSet(const string& key, const vec_str& f, const vec_str& v);
	bool HMSet(const string& key, const std::map<std::string, std::string>& vals);
	bool HMGet(const string& key, const vec_str& f,vec_str& v);

	bool HDel(const string& key, const string& f);
	bool HMDel(const string& key, const vec_str& f);
	bool HLength(const string& key, int& nLen);

	bool Keys(const string& patten, vec_str& key);
	bool HKeys(const string& key, vec_str& f);
	bool HVals(const string& key, vec_str& v);

	bool HGetAll(const string& key, string_map& res);

	bool ZAdd(const string& key, const string& m, const double& s);

	bool SAdd(const string& key, const string& val);
	bool SMembers(const string& key, vec_str& r);
	bool SRem(const string& key, const string& val);

	bool haveKey(const string& key);
private:
	// 通过 BaseModule 继承
	
	void AfterInit();
	void Execute();

	bool Reconnect();

protected:

	string m_host;
	int m_port;
	string m_pass;

	bool m_enable;
	SHARE<redis::client> m_redis;
};
#define REDIS boost::serialization::singleton<RedisModule>::get_mutable_instance()
#endif