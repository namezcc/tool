#pragma once
#include "Thread.h"
#include "boost/serialization/singleton.hpp"
#include "CfgDataStructs.h"

namespace google {
	namespace protobuf {
		class Message;
	}
}


using namespace Net;

#define REDIS_KEY_SIZE 32
#define MAX_SQL_LENGTH 1024

//redis对应的玩家的key值
#define REDIS_PLAYER_KEY "Player:%d_%lld"		//Player_platid_cid
#define REDIS_DROP_KEY "Drop:%lld"			//Drop:cid

namespace Proto
{
	class DBChrInfo;
	class DBPlayerData;
	class DB_sql_data_list;
	class DB_chr_no_redis;
}

namespace Net
{
	class MySqlDBGuard;
}

class DBProcessor
	: public Thread
{
public:
	DBProcessor();
	void setDBServerId(int32_t dbserverId) { m_dbserverId = dbserverId;}
protected:
	virtual void beforStart();
	virtual void onFrame();
	virtual void onPacket(AsioPacketPtr packet);

private:
	void onLoadPlayer(AsioPacketPtr packet, int32_t loginServerId);
	void onUpdatePlayerData(AsioPacketPtr packet);
	void onDeletePlayerData(AsioPacketPtr packet);
	void onSavePlayerToDB(AsioPacketPtr packet);
	void onSaveGamePlayer(AsioPacketPtr packet);
	void onInsertEquip(AsioPacketPtr packet);
	void onUpdateEquip(AsioPacketPtr packet);
	void onDeleteEquip(AsioPacketPtr packet);
	void onInsertBone(AsioPacketPtr packet);
	void onUpdateBone(AsioPacketPtr packet);
	void onDeleteBone(AsioPacketPtr packet);
	void onInsertPet(AsioPacketPtr packet);
	void onUpdatePet(AsioPacketPtr packet);
	void onDeletePet(AsioPacketPtr packet);
	void onInsertCore(AsioPacketPtr packet);
	void onUpdateCore(AsioPacketPtr packet);
	void onDeleteCore(AsioPacketPtr packet);
	void onInsertMemCommon(AsioPacketPtr packet);
	void onUpdateMemCommon(AsioPacketPtr packet);
	void onDeleteMemCommon(AsioPacketPtr packet);
	void onInsertMail(AsioPacketPtr packet);
	void onUpdateMail(AsioPacketPtr packet);
	void onDeleteMail(AsioPacketPtr packet);
	void onLoginServerConnected(AsioPacketPtr packet, int32_t loginServerId);
	void onGetRelation(AsioPacketPtr packet, int32_t loginServerId);
	void onLoadSimpleInfo(AsioPacketPtr packet, int32_t loginServerId);
	void onSearchSimpleInfo(AsioPacketPtr packet, int32_t loginServerId);
	void onUpdatePlayerName(AsioPacketPtr packet, int32_t loginServerId);

	void onInsertData(AsioPacketPtr packet);
	void onUpdateData(AsioPacketPtr packet);
	void onDeleteData(AsioPacketPtr packet);

	void onUpdatePayLog(AsioPacketPtr packet);
	void onPhpDBUserPay(AsioPacketPtr packet);

	std::string getRedisPlayerKey(int64_t cid);
	const char *getRedisDropKey(int64_t cid);
	std::string getRedisFieldKey(int32_t table);
	std::string getRedisFieldKey(int32_t table, std::string key1);
	std::string getRedisFieldKey(int32_t table, std::string key1, std::string key2);
	int32_t getTableIndexFromKey(const std::string& key);

	void loadPlayerChrInfo(Proto::DBChrInfo& pdata,const int64_t& cid, MySqlDBGuard& db,std::string& fchr);
	bool loadModuleDataFromDb(Proto::DBPlayerData& pdata, std::map<std::string, std::string>& hval, int64_t cid, Net::MySqlDBGuard& db, int32_t mod);
	void loadPlayerDataFromDb(Proto::DBPlayerData& pdata, std::map<std::string, std::string>& hval, int64_t cid, Net::MySqlDBGuard& db, int64_t set1 = -1, int64_t set2 = -1);	//新加表需要处理
	void loadPlayerDataFromRedis(Proto::DBPlayerData& pdata, std::map<std::string, std::string>& hval, int64_t cid, const Proto::DB_chr_no_redis &noRedis, std::vector<std::string> &del_fields);				//新加表需要处理
	void savePlayerDataToDb(int64_t cid);
	void updatePlayerData(int32_t table, const std::string& str, MySqlDBGuard& db);									//新加表需要处理
	void deletePlayerData(int32_t table, const std::string& str, MySqlDBGuard& db);		//会删数据的表需要处理
	void saveAllPlayerChange();
	void clearMailEndTime();
	void updatePlayerData(Proto::DB_sql_data_list &pbmsg);
	void updatePlayerMonsterDrop(Proto::DB_sql_data_list &pbmsg);

	int32_t getPlayerGameserver(const std::string& uid, int32_t sid);
	void updatePlayerGameserver(const std::string& uid, int32_t sid, int32_t gameserver, int32_t state);
	void kickPlayerGameserver(const std::string& uid, int32_t sid, int32_t gameserver);

	void responseLoginLuaMsg(int32_t loginid, int32_t coidx, google::protobuf::Message& msg);



	int32_t m_dbserverId;
	int32_t m_pid;	//平台id
	char m_redis_table_key[REDIS_KEY_SIZE];
	char m_mysql_statement[4096];

	std::map<int32_t, std::map<std::string, int32_t> > m_uidGameServer; //sid uid gameserverid*10+state --角色加载,下线或者切换时需要判断gameserverid是否一致，发给proxyserver时随便取一个发
};
#define DB_PROCESSOR boost::serialization::singleton<DBProcessor>::get_mutable_instance()