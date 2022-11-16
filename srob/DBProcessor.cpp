#include "DBProcessor.h"
#include "MemDataStructs.h"
#include "DBPool.h"
#include "GameClientManager.h"
#include "RedisModule.h"
#include "StorageConst.h"
#include "StringUtility.h"
#include "ProxyClientManager.h"
#include "LoginClientManager.h"
#include "DayTime.h"

//#ifdef max
//#undef max
//#endif
//
//#ifdef min
//#undef min
//#endif

#include "Server.pb.h"

#include "proto_sql.h"
#include "proto_table.h"

#define SQL_BUFF m_mysql_statement,(size_t)(sizeof(m_mysql_statement)-1)

#define PLAYER_CHANGE "player_change"

#define PLAYER_FRIEND_LIKE "player_friend_like"

#define MAIL_SAVE_TIME 86400*30

#define PB_FROM_STR(t,s) t pb; \
if (!pb.ParseFromString(s)) \
{ \
	LOG_ERROR("save data parse error %s\n",#t); \
	return; \
}

std::string getPlayerChangeKey(int64_t cid)
{
	//Int64Struct i64(sid, cid);
	return std::to_string(cid);
}

#define PRINTF_REDIS_TABLE_KEY(key,cid,sid) snprintf(m_redis_table_key, sizeof(m_redis_table_key) - 1, key, m_pid, sid, cid)

DBProcessor::DBProcessor():m_pid(0)
{
}

void DBProcessor::beforStart()
{
	saveAllPlayerChange();
	clearMailEndTime();
}

void DBProcessor::onFrame()
{}

void DBProcessor::onPacket(AsioPacketPtr packet)
{
//	auto dbServerId = 0;//packet->readInt32(true);
//	auto gameServerId = 0;// packet->readInt32(true);
	auto loginServerId = packet->popInt32();

	int32_t proc = packet->getProc();
	switch (proc)
	{
	case Proto::IM_DB_LOAD_PLAYER: onLoadPlayer(packet, loginServerId); break;
	case Proto::IM_DB_UPDATE_PLAYER:onUpdatePlayerData(packet); break;
	case Proto::IM_DB_DELETE_PLAYER:onDeletePlayerData(packet); break;
	case Proto::IM_DB_SAVE_PLAYER: onSavePlayerToDB(packet); break;
	case Proto::IM_DB_SAVE_GAME_PLAYER: onSaveGamePlayer(packet); break;
	case Proto::IM_DB_INSERT_EQUIP: onInsertEquip(packet); break;
	case Proto::IM_DB_UPDATE_EQUIP: onUpdateEquip(packet); break;
	case Proto::IM_DB_DELETE_EQUIP: onDeleteEquip(packet); break;
	case Proto::IM_DB_INSERT_BONE: onInsertBone(packet); break;
	case Proto::IM_DB_UPDATE_BONE: onUpdateBone(packet); break;
	case Proto::IM_DB_DELETE_BONE: onDeleteBone(packet); break;
	case Proto::IM_DB_INSERT_PET: onInsertPet(packet); break;
	case Proto::IM_DB_UPDATE_PET: onUpdatePet(packet); break;
	case Proto::IM_DB_DELETE_PET: onDeletePet(packet); break;
	case Proto::IM_DB_INSERT_CORE: onInsertCore(packet); break;
	case Proto::IM_DB_UPDATE_CORE: onUpdateCore(packet); break;
	case Proto::IM_DB_DELETE_CORE: onDeleteCore(packet); break;
	case Proto::IM_DB_INSERT_MEM_COMMON: onInsertMemCommon(packet); break;
	case Proto::IM_DB_UPDATE_MEM_COMMON: onUpdateMemCommon(packet); break;
	case Proto::IM_DB_DELETE_MEM_COMMON: onDeleteMemCommon(packet); break;
	case Proto::IM_DB_INSERT_MAIL: onInsertMail(packet); break;
	case Proto::IM_DB_UPDATE_MAIL: onUpdateMail(packet); break;
	case Proto::IM_DB_DELETE_MAIL: onDeleteMail(packet); break;
	case Proto::IM_DB_LOGIN_SERVER_CONNECTED: onLoginServerConnected(packet, loginServerId); break;
	case Proto::IM_DB_GET_RELATION: onGetRelation(packet, loginServerId); break;
	case Proto::IM_DB_LOAD_SIMPLE_INFO: onLoadSimpleInfo(packet, loginServerId); break;
	case Proto::IM_DB_FRIEND_SEARCH: onSearchSimpleInfo(packet, loginServerId); break;
	case Proto::IM_DB_UPDATE_PLAYER_NAME: onUpdatePlayerName(packet, loginServerId); break;
	case Proto::IM_DB_INSERT_DATA: onInsertData(packet); break;
	case Proto::IM_DB_UPDATE_DATA: onUpdateData(packet); break;
	case Proto::IM_DB_DELETE_DATA: onDeleteData(packet); break;
	case Proto::IM_DB_UPDATE_PAY_LOG: onUpdatePayLog(packet); break;

	case Proto::IM_PHP_DB_USER_PAY: onPhpDBUserPay(packet); break;
	default: break;
	}
}

void DBProcessor::onLoadPlayer(AsioPacketPtr packet, int32_t loginServerId)
{
	auto gateServerId = packet->popInt32();

	auto gateIndex = packet->readInt32();
	auto uid = packet->readUTF8();
	auto sid = packet->readInt32();
	auto cid = packet->readInt64();


	Proto::DBPlayerData outMsg;
	outMsg.set_gate_index(gateIndex);
	outMsg.set_gate_server_id(gateServerId);


	auto key = getRedisPlayerKey(cid);

	if (REDIS.haveKey("opt:" + key))
	{
		savePlayerDataToDb(cid);
	}

	MySqlDBGuard db(DBPOOL);

	std::map<std::string, std::string> hval;
	REDIS.HGetAll(key, hval);

	if (hval.empty())
	{
		//全加载
		loadPlayerDataFromDb(outMsg, hval, cid, db);
		REDIS.HMSet(key, hval);
		
		//清除no redis
		Proto::DB_chr_no_redis exclude;
		exclude.set_cid(cid);
		delete_mem_chr_no_redis(exclude, db, SQL_BUFF);
	}
	else
	{
		//读取no redis
		Proto::DB_chr_no_redis noRedis;
		select_mem_chr_no_redis(noRedis, db, SQL_BUFF, cid);
		vec_str del_fields;
		loadPlayerDataFromRedis(outMsg, hval,cid, noRedis, del_fields);

		//清除redis脏数据
		if (!del_fields.empty()) {
			REDIS.HMDel(key, del_fields);
		}

		//重新加载no redis
		if (noRedis.cid() > 0) {
			delete_mem_chr_no_redis(noRedis, db, SQL_BUFF);
			hval.clear();
			loadPlayerDataFromDb(outMsg, hval, cid, db, noRedis.mod1(), noRedis.mod2());
			REDIS.HMSet(key, hval);
		}

		//加载装备
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_unique_equip);

		//魂骨
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_unique_bone);

		//灵宠
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_unique_pet);

		//魔核
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_unique_core);

		//通用实例
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_unique_common);

		//邮件
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_chr_mail);

		//抽奖
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_chr_drow_item);

		//离线事件
		loadModuleDataFromDb(outMsg, hval, cid, db, TAB_mem_chr_offline_event);
	}

	//每日掉落数据
	key = getRedisDropKey(cid);
	hval.clear();
	REDIS.HGetAll(key, hval);
	for (auto &it : hval) {
		outMsg.add_monster_drop()->ParseFromString(it.second);
	}
	
	//好友点赞
	std::string flike;
	REDIS.HGet(PLAYER_FRIEND_LIKE, std::to_string(cid), flike);
	if(!flike.empty())
		outMsg.mutable_friend_like()->ParseFromString(flike);

	LOGIN_CLIENT_MANAGER.sendLoadMessage(loginServerId, Proto::IM_LOGIN_PLAYER_LOADED, outMsg, gateServerId, gateIndex, uid, sid);
}

void DBProcessor::updatePlayerData(Proto::DB_sql_data_list &pbmsg) {
	auto table = pbmsg.table();
	auto key = getRedisPlayerKey(pbmsg.cid());

	std::vector<std::string> field;
	std::vector<std::string> vals;
	std::vector<std::string> opts;

	for (auto& it : pbmsg.datas())
	{
		std::string fk;
		if (it.keys().empty())
		{
			fk = getRedisFieldKey(table);
		}
		else
		{
			fk.append(std::to_string(table)).append("_");
			for (auto &k : it.keys())
			{
				if (k.empty())
					fk.append("0_");
				else
					fk.append(k).append("_");
			}
			fk.pop_back();
		}

		field.push_back(fk);
		vals.push_back(it.data());
		opts.push_back("u");
	}

	if (REDIS.haveKey(key))
	{
		REDIS.HMSet(key, field, vals);
		REDIS.HMSet("opt:" + key, field, opts);
		REDIS.SAdd(PLAYER_CHANGE, getPlayerChangeKey(pbmsg.cid()));
	}
	else
	{
		MySqlDBGuard db(DBPOOL);
		for (size_t i = 0; i < field.size(); i++)
		{
			auto table = getTableIndexFromKey(field[i]);
			updatePlayerData(table, vals[i], db);
		}
	}
}
void DBProcessor::updatePlayerMonsterDrop(Proto::DB_sql_data_list &pbmsg) {
	auto cid = pbmsg.cid();
	std::string key(getRedisDropKey(pbmsg.cid()));
	std::vector<std::string> field;
	std::vector<std::string> vals;

	for (auto& it : pbmsg.datas()) {
		auto &keys = it.keys();
		if (keys.empty()) { continue; }
		field.push_back(keys[0]);
		vals.push_back(it.data());
	}
	REDIS.HMSet(key, field, vals);
}

void DBProcessor::onUpdatePlayerData(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);
	updatePlayerData(pbmsg);
}

void DBProcessor::onDeletePlayerData(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);

	auto table = pbmsg.table();
	auto key = getRedisPlayerKey(pbmsg.cid());

	std::vector<std::string> field;
	std::vector<std::string> vals;
	std::vector<std::string> opts;

	for (auto& it : pbmsg.datas())
	{
		std::string fk = getRedisFieldKey(table);
		if (!it.keys().empty())
		{
			for (auto &k : it.keys())
			{
				if (k.empty())
					fk.append("_0");
				else
					fk.append("_").append(k);
			}
		}

		field.push_back(fk);
		vals.push_back(it.data());
		opts.push_back("d");
	}

	if (REDIS.haveKey(key))
	{
		REDIS.HMSet("opt:" + key, field, opts);
		REDIS.SAdd(PLAYER_CHANGE, getPlayerChangeKey(pbmsg.cid()));
	}
	else
	{
		MySqlDBGuard db(DBPOOL);
		for (size_t i = 0; i < field.size(); i++)
		{
			auto table = getTableIndexFromKey(field[i]);
			deletePlayerData(table, vals[i],db);
		}
	}
}

void DBProcessor::onSavePlayerToDB(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);
	savePlayerDataToDb(pbmsg.cid());

}

void DBProcessor::onSaveGamePlayer(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::ImDbSaveGamePlayer, pb);
	Proto::DBChrInfo chrInfo;
	auto key = getRedisPlayerKey(pb.cid());
	if (REDIS.haveKey(key)) {
		auto fk = getRedisFieldKey(TAB_mem_chr);
		std::string val;
		REDIS.HGet(key, fk, val);
		chrInfo.ParseFromArray(val.c_str(), val.length());
		chrInfo.set_x(pb.pos().x());
		chrInfo.set_y(pb.pos().y());
		chrInfo.set_z(pb.pos().z());
		chrInfo.set_dir(pb.dir());
		REDIS.HSet(key, fk, chrInfo.SerializeAsString());
	}
	else {
		chrInfo.set_x(pb.pos().x());
		chrInfo.set_y(pb.pos().y());
		chrInfo.set_z(pb.pos().z());
		chrInfo.set_dir(pb.dir());
	}
	MySqlDBGuard db(DBPOOL);
	update_mem_chr_pos(chrInfo, db, SQL_BUFF);
}

void DBProcessor::onInsertEquip(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBEquipChange, pbmsg);

	MySqlDBGuard db(DBPOOL);
	auto equip = pbmsg.equip();
	insert_mem_unique_equip(equip, db, SQL_BUFF);
}

void DBProcessor::onUpdateEquip(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBEquipChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto equip = pbmsg.equip();
	update_mem_unique_equip(equip, db, SQL_BUFF);
}

void DBProcessor::onDeleteEquip(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBEquipChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto equip = pbmsg.equip();
	delete_mem_unique_equip(equip, db, SQL_BUFF);
}

void DBProcessor::onInsertBone(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBBoneChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto bone = pbmsg.bone();
	insert_mem_unique_bone(bone, db, SQL_BUFF);
}

void DBProcessor::onUpdateBone(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBBoneChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto bone = pbmsg.bone();
	update_mem_unique_bone(bone, db, SQL_BUFF);
}

void DBProcessor::onDeleteBone(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBBoneChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto bone = pbmsg.bone();
	delete_mem_unique_bone(bone, db, SQL_BUFF);
}

void DBProcessor::onInsertPet(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBPetChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pet = pbmsg.pet();
	insert_mem_unique_pet(pet, db, SQL_BUFF);
}

void DBProcessor::onUpdatePet(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBPetChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pet = pbmsg.pet();
	update_mem_unique_pet(pet, db, SQL_BUFF);
}

void DBProcessor::onDeletePet(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBPetChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pet = pbmsg.pet();
	delete_mem_unique_pet(pet, db, SQL_BUFF);
}

void DBProcessor::onInsertCore(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBCoreChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.core();
	insert_mem_unique_core(pb, db, SQL_BUFF);
}

void DBProcessor::onUpdateCore(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBCoreChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.core();
	update_mem_unique_core(pb, db, SQL_BUFF);
}

void DBProcessor::onDeleteCore(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBCoreChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.core();
	delete_mem_unique_core(pb, db, SQL_BUFF);
}

void DBProcessor::onInsertMemCommon(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBMemUniqueCommonChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.data();
	insert_mem_unique_common(pb, db, SQL_BUFF);
}

void DBProcessor::onUpdateMemCommon(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBMemUniqueCommonChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.data();
	update_mem_unique_common(pb, db, SQL_BUFF);
}

void DBProcessor::onDeleteMemCommon(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DBMemUniqueCommonChange, pbmsg);
	MySqlDBGuard db(DBPOOL);
	auto pb = pbmsg.data();
	delete_mem_unique_common(pb, db, SQL_BUFF);
}

void DBProcessor::onInsertMail(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::MemChrMail, pbmsg);
	MySqlDBGuard db(DBPOOL);
	insert_mem_chr_mail(pbmsg, db, SQL_BUFF);
}

void DBProcessor::onUpdateMail(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::MemChrMail, pbmsg);
	MySqlDBGuard db(DBPOOL);
	update_mem_chr_mail(pbmsg, db, SQL_BUFF);
}

void DBProcessor::onDeleteMail(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::PInt64Array, pbmsg);
	MySqlDBGuard db(DBPOOL);
	Proto::MemChrMail mail;
	for (auto id:pbmsg.data())
	{
		mail.set_id(id);
		delete_mem_chr_mail(mail, db, SQL_BUFF);
	}
}

void DBProcessor::onLoginServerConnected(AsioPacketPtr packet, int32_t loginServerId)
{
	MySqlDBGuard db(DBPOOL);
	Proto::MailList msg;

	select_server_mail(*msg.mutable_data(), db, SQL_BUFF, DayTime::now() - MAIL_SAVE_TIME);
	LOGIN_CLIENT_MANAGER.sendMessage(loginServerId, Proto::IM_LOGIN_LOAD_SERVER_MAIL, msg);

	Proto::DB_family_data familymsg;
	select_mem_family(*familymsg.mutable_family(), db, SQL_BUFF);
	select_mem_family_member(*familymsg.mutable_member(), db, SQL_BUFF);
	select_mem_family_apply(*familymsg.mutable_apply(), db, SQL_BUFF);
	select_mem_family_event(*familymsg.mutable_event(), db, SQL_BUFF);
	select_mem_family_red_packet(*familymsg.mutable_red_packet(), db, SQL_BUFF);
	select_mem_family_red_packet_record(*familymsg.mutable_red_packet_record(), db, SQL_BUFF);
	LOGIN_CLIENT_MANAGER.sendMessage(loginServerId, Proto::IM_LOGIN_LOAD_FAMILY_DATA, familymsg);
}

void DBProcessor::onGetRelation(AsioPacketPtr packet, int32_t loginServerId)
{
	auto coidx = packet->readInt32();
	Parse2Message(packet, Proto::PInt64Array, pbmsg);
	Proto::DB_chr_relation msg;
	if (pbmsg.data_size() == 2)
	{
		auto key = getRedisPlayerKey(pbmsg.data(0));
		if (REDIS.haveKey(key))
		{
			auto field = getRedisFieldKey(TAB_mem_chr_relation, std::to_string(pbmsg.data(1)));
			std::string optval;
			REDIS.HGet("opt:" + key, field, optval);
			if (optval != "d")
			{
				std::string rval;
				REDIS.HGet(key, field, rval);
				if (!rval.empty())
					msg.ParseFromString(rval);
				
			}
		}
		else
		{
			MySqlDBGuard db(DBPOOL);
			select_mem_chr_relation(msg, db, SQL_BUFF, pbmsg.data(0), pbmsg.data(1));
		}
	}
	responseLoginLuaMsg(loginServerId, coidx, msg);
}

void DBProcessor::onLoadSimpleInfo(AsioPacketPtr packet, int32_t loginServerId)
{
	auto coidx = packet->readInt32();
	Parse2Message(packet, Proto::PInt64Array, pbmsg);
	Proto::PlayerSimpleInfoList msg;
	MySqlDBGuard db(DBPOOL);
	Proto::DBChrInfo chrmsg;
	Proto::DB_chr_record record;
	auto fchr = getRedisFieldKey(TAB_mem_chr);

	for (auto cid:pbmsg.data())
	{
		chrmsg.Clear();
		loadPlayerChrInfo(chrmsg, cid,db ,fchr);
		auto simp = msg.add_data();
		simp->set_cid(cid);
		simp->set_name(chrmsg.name());
		simp->set_level(chrmsg.level());
		simp->set_logout_time(chrmsg.logout_time());
		simp->set_job(chrmsg.job());
		simp->set_hunshi_level(chrmsg.hunshi());
		simp->set_sex(chrmsg.sex());
		//周活跃
		if (select_mem_chr_record(record, db, SQL_BUFF, cid, 1502))
			simp->set_family_active(record.value());
	}
	responseLoginLuaMsg(loginServerId, coidx, msg);
}

void DBProcessor::onSearchSimpleInfo(AsioPacketPtr packet, int32_t loginServerId)
{
	auto coidx = packet->readInt32();
	Parse2Message(packet, Proto::PString, pbmsg);
	Proto::PlayerSimpleInfoList msg;
	MySqlDBGuard db(DBPOOL);
	Proto::DBChrInfo chrmsg;
	auto fchr = getRedisFieldKey(TAB_mem_chr);

	if (select_mem_chr_name(chrmsg, db, SQL_BUFF, pbmsg.data()))
	{
		loadPlayerChrInfo(chrmsg, chrmsg.cid(), db, fchr);
		auto simp = msg.add_data();
		simp->set_cid(chrmsg.cid());
		simp->set_name(chrmsg.name());
		simp->set_level(chrmsg.level());
		simp->set_logout_time(chrmsg.logout_time());
		simp->set_job(chrmsg.job());
		simp->set_hunshi_level(chrmsg.hunshi());
		simp->set_sex(chrmsg.sex());
	}

	responseLoginLuaMsg(loginServerId, coidx, msg);
}

void DBProcessor::onUpdatePlayerName(AsioPacketPtr packet, int32_t loginServerId)
{
	auto coidx = packet->readInt32();
	Parse2Message(packet, Proto::ImDbUpdatePlayerName, pbmsg);
	auto cid = pbmsg.cid();
	auto &name = pbmsg.name();

	auto err = 0;
	MySqlDBGuard db(DBPOOL);
	CHAR_STR(szSQL, MAX_SQL_LENGTH);
	snprintf(szSQL, sizeof(szSQL) - 1, "SELECT * FROM `mem_chr` WHERE `name`='%s'", name.c_str());
	auto& queryResult = db.query(szSQL);
	if (!queryResult.eof()) {
		err = 1;
	}

	if (!err) {
		snprintf(szSQL, sizeof(szSQL) - 1, "UPDATE `mem_chr` SET `name`='%s' WHERE `cid`=%lld", name.c_str(), cid);
		db.excute(szSQL);
	}
	
	Proto::ProtoInt32 msg;
	msg.set_i32(err);
	responseLoginLuaMsg(loginServerId, coidx, msg);
}

void DBProcessor::onInsertData(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);
	auto table = pbmsg.table();
	MySqlDBGuard db(DBPOOL);
	for (auto& it : pbmsg.datas())
	{
		switch (table)
		{
		case TAB_mem_family:
		{
			PB_FROM_STR(Proto::DB_mem_family, it.data());
			insert_mem_family(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_member:
		{
			PB_FROM_STR(Proto::DB_mem_family_member, it.data());
			insert_mem_family_member(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_apply:
		{
			PB_FROM_STR(Proto::DB_mem_family_apply, it.data());
			insert_mem_family_apply(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_event:
		{
			PB_FROM_STR(Proto::DB_mem_family_event, it.data());
			insert_mem_family_event(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_red_packet:
		{
			PB_FROM_STR(Proto::DB_mem_family_red_packet, it.data());
			insert_mem_family_red_packet(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_red_packet_record:
		{
			PB_FROM_STR(Proto::DB_mem_family_red_packet_record, it.data());
			insert_mem_family_red_packet_record(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_chr_drow_item:
		{
			PB_FROM_STR(Proto::DB_chr_drow_item, it.data());
			insert_mem_chr_drow_item(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_chr_offline_event:
		{
			PB_FROM_STR(Proto::DB_chr_offline_event, it.data());
			insert_mem_chr_offline_event(pb, db, SQL_BUFF);
			break;
		}
		default:
			break;
		}
	}
}

void DBProcessor::onUpdateData(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);
	auto table = pbmsg.table();
	MySqlDBGuard db(DBPOOL);
	for (auto& it : pbmsg.datas())
	{
		switch (table)
		{
		case TAB_mem_family:
		{
			PB_FROM_STR(Proto::DB_mem_family, it.data());
			update_mem_family(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_member:
		{
			PB_FROM_STR(Proto::DB_mem_family_member, it.data());
			update_mem_family_member(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_chr_friend_like:
		{
			REDIS.HSet(PLAYER_FRIEND_LIKE, std::to_string(pbmsg.cid()), it.data());
			break;
		}
		case TAB_mem_chr_monster_drop:
		{
			updatePlayerMonsterDrop(pbmsg);
			break;
		}
		default:
			break;
		}
	}
}

void DBProcessor::onDeleteData(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::DB_sql_data_list, pbmsg);
	auto table = pbmsg.table();

	MySqlDBGuard db(DBPOOL);
	for (auto& it : pbmsg.datas())
	{
		switch (table)
		{
		case TAB_mem_family:
		{
			PB_FROM_STR(Proto::DB_mem_family, it.data());
			delete_mem_family(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_member:
		{
			PB_FROM_STR(Proto::DB_mem_family_member, it.data());
			if (pb.cid() == 0)
				delete_mem_family_member_family(pb, db, SQL_BUFF);
			else
				delete_mem_family_member(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_apply:
		{
			PB_FROM_STR(Proto::DB_mem_family_apply, it.data());
			if (pb.cid() == 0)
				delete_mem_family_apply_family(pb, db, SQL_BUFF);
			else
				delete_mem_family_apply(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_event:
		{
			PB_FROM_STR(Proto::DB_mem_family_event, it.data());
			if (pb.id() == 0)
				delete_mem_family_event_family(pb, db, SQL_BUFF);
			else
				delete_mem_family_event(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_red_packet:
		{
			PB_FROM_STR(Proto::DB_mem_family_red_packet, it.data());
			if (pb.family_id() == 0)
				delete_mem_family_red_packet_all(pb, db, SQL_BUFF);
			else
				delete_mem_family_red_packet(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_family_red_packet_record:
		{
			PB_FROM_STR(Proto::DB_mem_family_red_packet_record, it.data());
			if (pb.family_id() == 0)
				delete_mem_family_red_packet_record_all(pb, db, SQL_BUFF);
			else
				delete_mem_family_red_packet_record(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_chr_offline_event:
		{
			PB_FROM_STR(Proto::DB_chr_offline_event, it.data());
			delete_mem_chr_offline_event(pb, db, SQL_BUFF);
			break;
		}
		case TAB_mem_chr_monster_drop: {
			PB_FROM_STR(Proto::DB_chr_monster_drop, it.data());
			auto key = getRedisDropKey(pb.cid());
			REDIS.Del(key);
			break;
		}
		default:
			break;
		}
	}
}

void DBProcessor::onUpdatePayLog(AsioPacketPtr packet)
{
	Parse2Message(packet, Proto::PayLogVector, pbmsg);
	MySqlDBGuard db(DBPOOL);
	CHAR_STR(szSQL, MAX_SQL_LENGTH);

	auto payLogs = pbmsg.mutable_data();
	for (auto& v : *payLogs)
	{
		snprintf(szSQL, sizeof(szSQL) - 1, "UPDATE `pay_log` SET `log`= %d WHERE `id` = %d AND `oid`= '%s' ",v.log(), v.id(), v.oid().c_str());
		db.excute(szSQL);
	}
}

void DBProcessor::onPhpDBUserPay(AsioPacketPtr packet)
{
	auto uid = packet->readUTF8();
	auto sid = packet->readInt32();

	MySqlDBGuard db(DBPOOL);
	char szSQL[MAX_SQL_LENGTH] = {};
	//snprintf(szSQL, sizeof(szSQL) - 1, "SELECT gold_pay FROM `sys_user` WHERE `uid`='%s' AND `sid`=%d", uid.c_str(), sid);
	//MySqlQuery result = db.query(szSQL);
	//if (result.getRowCount() != 1)
	//{
	//	LOG_ERROR("DBServer::onPhpDBUserPay sid_uid repeated with sid=%d,uid=%s\n", sid, uid.c_str());
	//	return;
	//}

	//bzero(szSQL, sizeof(szSQL));
	snprintf(szSQL, sizeof(szSQL) - 1, "SELECT * FROM `pay_log` WHERE `uid`='%s' AND `sid`='%d' AND `log`=0", uid.c_str(), sid);
	MySqlQuery result = db.query(szSQL);
	Proto::PayLogVector payLogs;
	while (!result.eof())
	{
		auto payLog = payLogs.add_data();
		payLog->set_id(result.getIntValue("id"));
		payLog->set_oid(result.getStringValue("oid"));
		payLog->set_rmb(result.getIntValue("rmb"));
		payLog->set_gold(result.getIntValue("gold"));
		payLog->set_product(result.getIntValue("product_id"));
		payLog->set_log(result.getIntValue("log"));
		payLog->set_time(result.getIntValue("time"));

		result.nextRow();
	}
	if (payLogs.data_size() <= 0)
		return;

	LOGIN_CLIENT_MANAGER.sendLoadMessage(sid, Proto::IM_LOGIN_USER_PAY, payLogs, 0, 0, uid, sid);
	//LOGIN_CLIENT_MANAGER.sendMessage(sid, Proto::IM_LOGIN_USER_PAY, payLogs);
}

std::string DBProcessor::getRedisPlayerKey(int64_t cid)
{
	snprintf(m_redis_table_key, sizeof(m_redis_table_key) - 1, REDIS_PLAYER_KEY, m_pid, cid);
	return m_redis_table_key;
}

const char * DBProcessor::getRedisDropKey(int64_t cid) {
	snprintf(m_redis_table_key, sizeof(m_redis_table_key) - 1, REDIS_DROP_KEY, cid);
	return m_redis_table_key;
}

std::string DBProcessor::getRedisFieldKey(int32_t table)
{
	return std::to_string(table);
}

std::string DBProcessor::getRedisFieldKey(int32_t table, std::string key1)
{
	if (key1.empty()) key1.append("0");

	std::string res;
	res.append(std::to_string(table));
	res.append("_").append(key1);
	return res;
}

std::string DBProcessor::getRedisFieldKey(int32_t table, std::string key1, std::string key2)
{
	if (key1.size() == 0) key1.append("0");
	if (key2.size() == 0) key2.append("0");
	
	std::string res;
	res.append(std::to_string(table));
	res.append("_").append(key1);
	res.append("_").append(key2);
	return res;
}

int32_t DBProcessor::getTableIndexFromKey(const std::string & key)
{
	return atoi(key.c_str());
}
void DBProcessor::loadPlayerChrInfo(Proto::DBChrInfo & pdata,const  int64_t & cid, MySqlDBGuard& db, std::string& fchr)
{
	auto key = getRedisPlayerKey(cid);
	if (REDIS.haveKey(key))
	{
		std::string val;
		REDIS.HGet(key, fchr, val);
		pdata.ParseFromString(val);
	}
	else
	{
		select_mem_chr(pdata, db, SQL_BUFF, cid);
	}
}

#define load_struct_from_db(pmsg, hval, mod_name) \
	if(select_##mod_name(*pmsg, db, SQL_BUFF, cid)) \
	{hval[getRedisFieldKey(TAB_##mod_name)] = std::move(pmsg->SerializeAsString());}

#define load_vector_from_db_1(pmsg, hval, mod_name, key1) \
	select_##mod_name(*pmsg, db, SQL_BUFF, cid); \
	for (auto &it : *pmsg) { \
		auto k = getRedisFieldKey(TAB_##mod_name, std::to_string(it.key1())); \
		hval[k] = std::move(it.SerializeAsString()); \
	}

#define load_vector_from_db_2(pmsg, hval, mod_name, key1, key2) \
	select_##mod_name(*pmsg, db, SQL_BUFF, cid); \
	for (auto &it : *pmsg) { \
		auto k = getRedisFieldKey(TAB_##mod_name, std::to_string(it.key1()), std::to_string(it.key2())); \
		hval[k] = std::move(it.SerializeAsString()); \
	}


bool DBProcessor::loadModuleDataFromDb(Proto::DBPlayerData& pdata, std::map<std::string, std::string>& hval, int64_t cid, Net::MySqlDBGuard& db, int32_t mod) {
	bool defined = true;
	switch (mod)
	{
	case TAB_mem_chr: {
		auto pmsg = pdata.mutable_chr_info();
		load_struct_from_db(pmsg, hval, mem_chr);
//		select_mem_chr(*pmsg, db, SQL_BUFF, cid);
//		hval[getRedisFieldKey(TAB_mem_chr)] = std::move(pmsg->SerializeAsString());
		break;
	}
	case TAB_mem_chr_storage: {
		auto pmsg = pdata.mutable_storage();
		load_vector_from_db_2(pmsg, hval, mem_chr_storage, storage, slot);
		break;
	}
	case TAB_mem_unique_equip: {
		auto equips = pdata.mutable_equips();
		select_mem_unique_equip(*equips, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_hunhuan: {
		auto pmsg = pdata.mutable_hunhuan();
		load_vector_from_db_1(pmsg, hval, mem_chr_hunhuan, hunhuan_id);
		break;
	}
	case TAB_mem_chr_spirit: {
		auto pmsg = pdata.mutable_spirit();
		load_vector_from_db_1(pmsg, hval, mem_chr_spirit, id);
		break;
	}
	case TAB_mem_chr_shenqi_qihe: {
		auto pmsg = pdata.mutable_shenqi_qihe();
		load_vector_from_db_1(pmsg, hval, mem_chr_shenqi_qihe, id);
		break;
	}
	case TAB_mem_chr_shenqi_strengthen:
		break;
	case TAB_mem_chr_shenqi_star:
		break;
	case TAB_mem_chr_shenqi_pray:
		break;
	case TAB_mem_chr_task_trunk: {
		auto pmsg = pdata.mutable_task_trunk();
		load_vector_from_db_1(pmsg, hval, mem_chr_task_trunk, tid);
		break;
	}
	case TAB_mem_chr_record: {
		auto pmsg = pdata.mutable_record();
		load_vector_from_db_1(pmsg, hval, mem_chr_record, type);
		break;
	}
	case TAB_mem_chr_neigong: {
		auto pmsg = pdata.mutable_neigong();
		load_struct_from_db(pmsg, hval, mem_chr_neigong);
		break;
	}
	case TAB_mem_chr_tianfu: {
		auto pmsg = pdata.mutable_tianfu();
		load_vector_from_db_2(pmsg, hval, mem_chr_tianfu, branch, page);
		break;
	}
	case TAB_mem_chr_wuhun: {
		auto pmsg = pdata.mutable_wuhun();
		load_struct_from_db(pmsg, hval, mem_chr_wuhun);
		break;
	}
	case TAB_mem_unique_pet: {
		auto pet = pdata.mutable_pet();
		select_mem_unique_pet(*pet, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_pet: {
		auto pmsg = pdata.mutable_chr_pet();
		load_vector_from_db_1(pmsg, hval, mem_chr_pet, pid);
		break;
	}
	case TAB_mem_chr_grass: {
		auto pmsg = pdata.mutable_grass();
		load_vector_from_db_1(pmsg, hval, mem_chr_grass, type);
		break;
	}
	case TAB_mem_unique_bone: {
		auto bone = pdata.mutable_bone();
		select_mem_unique_bone(*bone, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_unique_core: {
		auto core = pdata.mutable_core();
		select_mem_unique_core(*core, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_item: {
		auto pmsg = pdata.mutable_item();
		load_vector_from_db_1(pmsg, hval, mem_chr_item, item);
		break;
	}
	case TAB_mem_chr_baoxiang_group: {
		auto pmsg = pdata.mutable_baoxiang_group();
		load_vector_from_db_1(pmsg, hval, mem_chr_baoxiang_group, group);
		break;
	}
	case TAB_mem_chr_baoxiang_task: {
		auto pmsg = pdata.mutable_baoxiang_task();
		load_vector_from_db_1(pmsg, hval, mem_chr_baoxiang_task, tid);
		break;
	}
	case TAB_mem_chr_baoxiang: {
		auto pmsg = pdata.mutable_baoxiang();
		load_vector_from_db_1(pmsg, hval, mem_chr_baoxiang, bid);
		break;
	}
	case TAB_mem_chr_anqi: {
		auto pmsg = pdata.mutable_anqi();
		load_vector_from_db_1(pmsg, hval, mem_chr_anqi, id);
		break;
	}
	case TAB_mem_unique_common: {
		auto memCommon = pdata.mutable_memcommon();
		select_mem_unique_common(*memCommon, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_danyao: {
		auto pmsg = pdata.mutable_danyao();
		load_vector_from_db_1(pmsg, hval, mem_chr_danyao, did);
		break;
	}
	case TAB_mem_chr_lifeskill: {
		auto pmsg = pdata.mutable_lifeskill();
		load_struct_from_db(pmsg, hval, mem_chr_lifeskill);
		break;
	}
	case TAB_mem_chr_equip_make: {
		auto pmsg = pdata.mutable_equip_make();
		load_vector_from_db_1(pmsg, hval, mem_chr_equip_make, id);
		break;
	}
	case TAB_mem_chr_wing: {
		auto pmsg = pdata.mutable_chr_wing();
		load_struct_from_db(pmsg, hval, mem_chr_wing);
		break;
	}
	case TAB_mem_chr_client_record: {
		auto pmsg = pdata.mutable_client_record();
		load_vector_from_db_1(pmsg, hval, mem_chr_client_record, type);
		break;
	}
	case TAB_mem_chr_ebow: {
		auto pmsg = pdata.mutable_elementbow();
		load_struct_from_db(pmsg, hval, mem_chr_ebow);
		break;
	}
	case TAB_mem_chr_position: {
		auto pmsg = pdata.mutable_position();
		load_struct_from_db(pmsg, hval, mem_chr_position);
		break;
	}
	case TAB_mem_chr_vit_task: {
		auto pmsg = pdata.mutable_vit_task();
		load_vector_from_db_1(pmsg, hval, mem_chr_vit_task, tid);
		break;
	}
	case TAB_mem_chr_vit_gift: {
		auto pmsg = pdata.mutable_vit_gift();
		load_struct_from_db(pmsg, hval, mem_chr_vit_gift);
		break;
	}	
	case TAB_mem_chr_shop_limit: {
		auto pmsg = pdata.mutable_shop_limit();
		load_vector_from_db_1(pmsg, hval, mem_chr_shop_limit, shop_id);
		break;
	}
	case TAB_mem_chr_position_reward: {
		auto pmsg = pdata.mutable_position_reward();
		load_struct_from_db(pmsg, hval, mem_chr_position_reward);
		break;
	}
	case TAB_mem_chr_achievement: {
		auto pmsg = pdata.mutable_achievement();
		load_struct_from_db(pmsg, hval, mem_chr_achievement);
		break;
	}
	case TAB_mem_chr_achievement_task: {
		auto pmsg = pdata.mutable_achievement_task();
		load_vector_from_db_1(pmsg, hval, mem_chr_achievement_task, tid);
		break;
	}
	case TAB_mem_chr_collection: {
		auto pmsg = pdata.mutable_collection();
		load_vector_from_db_1(pmsg, hval, mem_chr_collection, id);
		break;
	}
	case TAB_mem_chr_tujian: {
		auto pmsg = pdata.mutable_tujian();
		load_vector_from_db_2(pmsg, hval, mem_chr_tujian, group, id);
		break;
	}
	case TAB_mem_chr_tujian_total: {
		auto pmsg = pdata.mutable_tujian_total();
		load_struct_from_db(pmsg, hval, mem_chr_tujian_total);
		break;
	}
	case TAB_mem_chr_mail: {
		auto msg = pdata.mutable_mail();
		select_mem_chr_mail(*msg, db, SQL_BUFF, cid, DayTime::now() - MAIL_SAVE_TIME);
		break;
	}
	case TAB_server_mail:
		break;
	case TAB_mem_chr_server_mail: {
		auto pmsg = pdata.mutable_server_mail();
		select_mem_chr_server_mail(*pmsg, db, SQL_BUFF, cid, DayTime::now() - MAIL_SAVE_TIME);
		for (auto &it : *pmsg)
		{
			auto k = getRedisFieldKey(TAB_mem_chr_server_mail, std::to_string(it.id()));
			hval[k] = std::move(it.SerializeAsString());
		}
		break;
	}
	case TAB_mem_chr_relation: {
		auto pmsg = pdata.mutable_relation();
		load_vector_from_db_1(pmsg, hval, mem_chr_relation, rcid);
		break;
	}
	case TAB_mem_chr_level_gift:
		break;
	case TAB_mem_chr_pay: {
		auto pmsg = pdata.mutable_chr_pay();
		load_vector_from_db_1(pmsg, hval, mem_chr_pay, id);
		break;
	}
	case TAB_mem_chr_task_random: {
		auto pmsg = pdata.mutable_task_random();
		load_vector_from_db_2(pmsg, hval, mem_chr_task_random, ttype, tid);
		break;
	}
	case TAB_mem_chr_sign_up: {
		auto pmsg = pdata.mutable_chr_sign_up();
		load_struct_from_db(pmsg, hval, mem_chr_sign_up);
		break;
	}
	case TAB_mem_chr_task_branch: {
		auto pmsg = pdata.mutable_task_branch();
		load_vector_from_db_1(pmsg, hval, mem_chr_task_branch, tid);
		break;
	}
	case TAB_mem_chr_task_zhuanji: {
		auto pmsg = pdata.mutable_task_zhuanji();
		load_vector_from_db_1(pmsg, hval, mem_chr_task_zhuanji, tid);
		break;
	}
	case TAB_mem_family:
		break;
	case TAB_mem_family_member:
		break;
	case TAB_mem_family_apply:
		break;
	case TAB_mem_family_event:
		break;
	case TAB_mem_chr_task_round: {
		auto pmsg = pdata.mutable_task_round();
		load_vector_from_db_2(pmsg, hval, mem_chr_task_round, round, tid);
		break;
	}
	case TAB_mem_chr_arena:{
		auto pmsg = pdata.mutable_arena();
		load_struct_from_db(pmsg, hval, mem_chr_arena);
		break;
	}
	case TAB_mem_chr_dress: {
		auto pmsg = pdata.mutable_dress();
		load_vector_from_db_2(pmsg, hval, mem_chr_dress, type, id);
		break;
	}
	case TAB_mem_chr_war_token: {
		// 1659283200: 2022-08-01 00:00:00，应改为开服当日的0点时间戳
		int32_t season = DayTime::daydiff(1659283200) / 40 + 1;
		auto pmsg = pdata.mutable_war_token();
		select_mem_chr_war_token(*pmsg, db, SQL_BUFF, cid, season);
		hval[getRedisFieldKey(TAB_mem_chr_war_token)] = std::move(pmsg->SerializeAsString());
		break;
	}
	case TAB_mem_chr_task_war_token: {
		auto pmsg = pdata.mutable_task_war_token();
		load_vector_from_db_1(pmsg, hval, mem_chr_task_war_token, tid);
		break;
	}
	case TAB_mem_chr_family_send: {
		auto pmsg = pdata.mutable_family_send();
		load_vector_from_db_1(pmsg, hval, mem_chr_family_send, type);
		break;
	}
	case TAB_mem_family_red_packet:
		break;
	case TAB_mem_family_red_packet_record:
		break;
	case TAB_mem_chr_dress_wear: {
		auto pmsg = pdata.mutable_dress_wear();
		load_struct_from_db(pmsg, hval, mem_chr_dress_wear);
		break;
	}
	case TAB_mem_chr_drow_item: {
		auto drow = pdata.mutable_drow_item();
		select_mem_chr_drow_item(*drow, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_offline_event: {
		auto offlineevent = pdata.mutable_offline_event();
		select_mem_chr_offline_event(*offlineevent, db, SQL_BUFF, cid);
		break;
	}
	case TAB_mem_chr_friend_like:
		break;
	case TAB_mem_chr_face: {
		auto pmsg = pdata.mutable_face();
		load_struct_from_db(pmsg, hval, mem_chr_face);
		break;
	}
	case TAB_mem_chr_collection_forever: {
		auto pmsg = pdata.mutable_collection_forever();
		load_vector_from_db_1(pmsg, hval, mem_chr_collection_forever, id);
		break;
	}
	case TAB_mem_chr_monster_drop:
		break;
	case TAB_mem_chr_no_redis:
		break;
	case TAB_mem_chr_map_door: {
		auto pmsg = pdata.mutable_map_door();
		load_vector_from_db_1(pmsg, hval, mem_chr_map_door, door_id);
		break;
	}
	default:
		defined = false;
		break;
	}
	return defined;
}

//每行sql数据作为redis每个hashval
void DBProcessor::loadPlayerDataFromDb(Proto::DBPlayerData & pdata, std::map<std::string, std::string>& hval, int64_t cid, Net::MySqlDBGuard& db, int64_t set1, int64_t set2)
{
	auto mod = 0;
	while (++mod <= 128) {
		if ((set1 & (1LL << (mod - 1))) || (set2 & (1LL << (mod - 65)))) {
			if (!loadModuleDataFromDb(pdata, hval, cid, db, mod)) { break; }
		}
	}
}

void DBProcessor::loadPlayerDataFromRedis(Proto::DBPlayerData & pdata, std::map<std::string, std::string>& hval, int64_t cid, const Proto::DB_chr_no_redis &noRedis, std::vector<std::string> &del_fields)
{
	for (auto& it:hval)
	{
		if (it.second.empty())
			continue;

		auto table = getTableIndexFromKey(it.first);
		if ((table > 0 && table <= 64 && (noRedis.mod1()&(1LL << (table - 1)))) ||
			(table > 64 && table <= 128 && (noRedis.mod2()&(1LL << (table - 65))))) {
			del_fields.push_back(it.first);
			continue;
		}

		switch (table)
		{
		case TAB_mem_chr:
		{
			pdata.mutable_chr_info()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_storage:
		{
			pdata.mutable_storage()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_trunk:
		{
			pdata.mutable_task_trunk()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_hunhuan:
		{
			pdata.mutable_hunhuan()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_spirit:
		{
			pdata.mutable_spirit()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_record:
		{
			pdata.mutable_record()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_neigong:
		{
			pdata.mutable_neigong()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_tianfu:
		{
			pdata.mutable_tianfu()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_wuhun:
		{
			pdata.mutable_wuhun()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_pet:
		{
			pdata.mutable_pet()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_grass:
		{
			pdata.mutable_grass()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_item:
		{
			pdata.mutable_item()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_baoxiang_group :
		{
			pdata.mutable_baoxiang_group()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_baoxiang_task:
		{
			pdata.mutable_baoxiang_task()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_baoxiang:
		{
			pdata.mutable_baoxiang()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_anqi:
		{
			pdata.mutable_anqi()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_lifeskill:
		{
			pdata.mutable_lifeskill()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_equip_make:
		{
			pdata.mutable_equip_make()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_wing:
		{
			pdata.mutable_chr_wing()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_client_record:
		{
			pdata.mutable_client_record()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_ebow:
		{
			pdata.mutable_elementbow()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_position:
		{
			pdata.mutable_position()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_shop_limit:
		{
			pdata.mutable_shop_limit()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_position_reward:
		{
			pdata.mutable_position_reward()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_vit_gift:
		{
			pdata.mutable_vit_gift()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_vit_task:
		{
			pdata.mutable_vit_task()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_achievement:
		{
			pdata.mutable_achievement()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_achievement_task:
		{
			pdata.mutable_achievement_task()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_collection:
		{
			pdata.mutable_collection()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_tujian:
		{
			pdata.mutable_tujian()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_tujian_total:
		{
			pdata.mutable_tujian_total()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_server_mail:
		{
			pdata.mutable_server_mail()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_relation:
		{
			pdata.mutable_relation()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_level_gift:
		{
			pdata.mutable_level_gift()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_pay:
		{
			pdata.mutable_chr_pay()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_sign_up:
		{
			pdata.mutable_chr_sign_up()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_random:
		{
			pdata.mutable_task_random()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_branch:
		{
			pdata.mutable_task_branch()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_zhuanji:
		{
			pdata.mutable_task_zhuanji()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_dress:
		{
			pdata.mutable_dress()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_danyao:
		{
			pdata.mutable_danyao()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_dress_wear:
		{
			pdata.mutable_dress_wear()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_round:
		{
			pdata.mutable_task_round()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_arena:
		{
			pdata.mutable_arena()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_war_token:
		{
			pdata.mutable_war_token()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_task_war_token:
		{
			pdata.mutable_task_war_token()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_family_send:
		{
			pdata.mutable_family_send()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_face:
		{
			pdata.mutable_face()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_collection_forever:
		{
			pdata.mutable_collection_forever()->Add()->ParseFromString(it.second);
			break;
		}
		case TAB_mem_chr_map_door:
		{
			pdata.mutable_map_door()->Add()->ParseFromString(it.second);
			break;
		}
		default:
			break;
		}
	}
//赋默认值
//{示例
//	auto key = getRedisFieldKey(tabindex);
//	if (!hval.find(key))
//		select_mem_chr(*pdata.mutable_chr_info(), db, SQL_BUFF, cid);
//}
}

void DBProcessor::savePlayerDataToDb(int64_t cid)
{
	auto key = getRedisPlayerKey(cid);

	std::map<std::string, std::string> pdata;
	std::map<std::string, std::string> opts;
	vec_str dels;

	REDIS.HGetAll(key, pdata);
	REDIS.HGetAll("opt:"+key, opts);

	MySqlDBGuard db(DBPOOL);

	for (auto& it : opts)
	{
		auto itd = pdata.find(it.first);
		if (itd == pdata.end())
		{
			LOG_ERROR("opt key cid:%lld no data %s opt %s\n", cid,it.first.c_str(),it.second.c_str());
			continue;
		}

		auto table = getTableIndexFromKey(it.first);

		if (it.second == "u")
		{
			updatePlayerData(table, itd->second, db);
		}
		else if (it.second == "d")
		{
			deletePlayerData(table, itd->second, db);
			dels.push_back(itd->first);
		}
		else
		{
			LOG_ERROR("error opt %s key %s\n", it.second.c_str(), it.first.c_str());
		}
	}

	if (!dels.empty())
		REDIS.HMDel(key, dels);

	REDIS.Del("opt:" + key);
	REDIS.SRem(PLAYER_CHANGE, getPlayerChangeKey(cid));
}

void DBProcessor::updatePlayerData(int32_t table, const std::string & str, MySqlDBGuard& db)
{
	switch (table)
	{
	case TAB_mem_chr:
	{
		PB_FROM_STR(Proto::DBChrInfo, str);
		update_mem_chr(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_storage:
	{
		PB_FROM_STR(Proto::DB_chr_storage, str);
		insert_mem_chr_storage(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_trunk:
	{
		PB_FROM_STR(Proto::DB_chr_task_trunk, str);
		insert_mem_chr_task_trunk(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_hunhuan:
	{
		PB_FROM_STR(Proto::DB_chr_hunhuan, str);
		insert_mem_chr_hunhuan(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_record:
	{
		PB_FROM_STR(Proto::DB_chr_record, str);
		insert_mem_chr_record(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_neigong:
	{
		PB_FROM_STR(Proto::DB_chr_neigong, str);
		insert_mem_chr_neigong(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_tianfu:
	{
		PB_FROM_STR(Proto::DB_chr_tianfu, str);
		insert_mem_chr_tianfu(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_wuhun:
	{
		PB_FROM_STR(Proto::DB_chr_wuhun, str);
		insert_mem_chr_wuhun(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_pet:
	{
		PB_FROM_STR(Proto::DB_chr_pet, str);
		insert_mem_chr_pet(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_grass:
	{
		PB_FROM_STR(Proto::DB_chr_grass, str);
		insert_mem_chr_grass(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_item:
	{
		PB_FROM_STR(Proto::DB_chr_item, str);
		insert_mem_chr_item(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_spirit:
	{
		PB_FROM_STR(Proto::DBChrSpirit, str);
		insert_mem_chr_spirit(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_shenqi_qihe:
	{
		PB_FROM_STR(Proto::DBShenQiData, str);
		insert_mem_chr_shenqi_qihe(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_baoxiang_group:
	{
		PB_FROM_STR(Proto::DB_chr_baoxiang_group, str);
		insert_mem_chr_baoxiang_group(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_baoxiang_task:
	{
		PB_FROM_STR(Proto::DB_chr_baoxiang_task, str);
		insert_mem_chr_baoxiang_task(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_baoxiang:
	{
		PB_FROM_STR(Proto::DB_chr_baoxiang, str);
		insert_mem_chr_baoxiang(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_anqi:
	{
		PB_FROM_STR(Proto::DB_chr_anqi, str);
		insert_mem_chr_anqi(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_danyao:
	{
		PB_FROM_STR(Proto::DB_chr_danyao, str);
		insert_mem_chr_danyao(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_lifeskill:
	{
		PB_FROM_STR(Proto::DB_chr_lifeskill, str);
		insert_mem_chr_lifeskill(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_equip_make:
	{
		PB_FROM_STR(Proto::DB_chr_equip_make, str);
		insert_mem_chr_equip_make(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_wing:
	{
		PB_FROM_STR(Proto::DB_chr_wing, str);
		insert_mem_chr_wing(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_client_record:
	{
		PB_FROM_STR(Proto::DB_chr_client_record, str);
		insert_mem_chr_client_record(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_ebow:
	{
		PB_FROM_STR(Proto::DB_chr_elementbow, str);
		insert_mem_chr_ebow(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_position:
	{
		PB_FROM_STR(Proto::DB_chr_position, str);
		insert_mem_chr_position(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_shop_limit:
	{
		PB_FROM_STR(Proto::DB_chr_shop_limit, str);
		insert_mem_chr_shop_limit(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_position_reward:
	{
		PB_FROM_STR(Proto::DB_chr_position_reward, str);
		insert_mem_chr_position_reward(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_vit_gift:
	{
		PB_FROM_STR(Proto::DB_chr_vit_gift, str);
		insert_mem_chr_vit_gift(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_vit_task:
	{
		PB_FROM_STR(Proto::DB_chr_vit_task, str);
		insert_mem_chr_vit_task(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_achievement:
	{
		PB_FROM_STR(Proto::DB_chr_achievement, str);
		insert_mem_chr_achievement(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_achievement_task:
	{
		PB_FROM_STR(Proto::DB_chr_achievement_task, str);
		insert_mem_chr_achievement_task(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_collection:
	{
		PB_FROM_STR(Proto::DB_chr_collection, str);
		insert_mem_chr_collection(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_tujian:
	{
		PB_FROM_STR(Proto::DB_chr_tujian, str);
		insert_mem_chr_tujian(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_tujian_total:
	{
		PB_FROM_STR(Proto::DB_chr_tujian_total, str);
		insert_mem_chr_tujian_total(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_server_mail:
	{
		PB_FROM_STR(Proto::DB_chr_server_mail, str);
		insert_mem_chr_server_mail(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_relation:
	{
		PB_FROM_STR(Proto::DB_chr_relation, str);
		insert_mem_chr_relation(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_pay:
	{
		PB_FROM_STR(Proto::DB_chr_pay, str);
		insert_mem_chr_pay(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_sign_up:
	{
		PB_FROM_STR(Proto::DB_chr_sign_up, str);
		insert_mem_chr_sign_up(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_dress:
	{
		PB_FROM_STR(Proto::DB_chr_dress, str);
		insert_mem_chr_dress(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_dress_wear:
	{
		PB_FROM_STR(Proto::DB_chr_dress_wear, str);
		insert_mem_chr_dress_wear(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_level_gift:
	{
		PB_FROM_STR(Proto::DB_chr_level_gift, str);
		insert_mem_chr_level_gift(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_random:
	{
		PB_FROM_STR(Proto::DB_chr_task_random, str);
		insert_mem_chr_task_random(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_branch:
	{
		PB_FROM_STR(Proto::DB_chr_task_branch, str);
		insert_mem_chr_task_branch(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_zhuanji:
	{
		PB_FROM_STR(Proto::DB_chr_task_zhuanji, str);
		insert_mem_chr_task_zhuanji(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_round:
	{
		PB_FROM_STR(Proto::DB_chr_task_round, str);
		insert_mem_chr_task_round(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_arena:
	{
		PB_FROM_STR(Proto::DB_chr_arena, str);
		insert_mem_chr_arena(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_war_token:
	{
		PB_FROM_STR(Proto::DB_chr_war_token, str);
		insert_mem_chr_war_token(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_war_token:
	{
		PB_FROM_STR(Proto::DB_chr_task_war_token, str);
		insert_mem_chr_task_war_token(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_family_send:
	{
		PB_FROM_STR(Proto::DB_mem_chr_family_send, str);
		insert_mem_chr_family_send(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_face:
	{
		PB_FROM_STR(Proto::DB_chr_face, str);
		update_mem_chr_face(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_collection_forever:
	{
		PB_FROM_STR(Proto::DB_chr_collection_forever, str);
		insert_mem_chr_collection_forever(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_map_door:
	{
		PB_FROM_STR(Proto::DB_chr_map_door, str);
		insert_mem_chr_map_door(pb, db, SQL_BUFF);
		break;
	}
	default:
		break;
	}

}

void DBProcessor::deletePlayerData(int32_t table, const std::string & str, MySqlDBGuard& db)
{
	switch (table)
	{
	case TAB_mem_chr_storage:
	{
		PB_FROM_STR(Proto::DB_chr_storage, str);
		delete_mem_chr_storage(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_record:
	{
		PB_FROM_STR(Proto::DB_chr_record, str);
		delete_mem_chr_record(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_item:
	{
		PB_FROM_STR(Proto::DB_chr_item, str);
		delete_mem_chr_item(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_vit_task:
	{
		PB_FROM_STR(Proto::DB_chr_vit_task, str);
		delete_mem_chr_vit_task(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_relation:
	{
		PB_FROM_STR(Proto::DB_chr_relation, str);
		delete_mem_chr_relation(pb, db, SQL_BUFF);
		break;
	}
	case TAB_mem_chr_task_random:
	{
		PB_FROM_STR(Proto::DB_chr_task_random, str);
		delete_mem_chr_task_random(pb, db, SQL_BUFF);
		break;
	}
	default:
		break;
	}
}

void DBProcessor::saveAllPlayerChange()
{
	vec_str vec;
	REDIS.SMembers(PLAYER_CHANGE, vec);
	if (vec.empty())
	{
		return;
	}

	//Int64Struct i64;
	for (size_t i = 0; i < vec.size(); i++)
	{
		auto cid = atoll(vec[i].c_str());
		savePlayerDataToDb(cid);
	}
}

void DBProcessor::clearMailEndTime()
{
	MySqlDBGuard db(DBPOOL);
	Proto::MemChrMail msg;
	Proto::DB_chr_server_mail msg2;
	msg.set_time(DayTime::now()-MAIL_SAVE_TIME);
	msg2.set_time(DayTime::now() - MAIL_SAVE_TIME);

	delete_mem_chr_mail_outtime(msg, db, SQL_BUFF);
	delete_mem_chr_server_mail_outtime(msg2, db, SQL_BUFF);
}

int32_t DBProcessor::getPlayerGameserver(const std::string& uid, int32_t sid)
{
	auto itTable = m_uidGameServer.find(sid);
	if (itTable != m_uidGameServer.end())
	{
		auto it = itTable->second.find(uid);
		if (it != itTable->second.end())
		{
			return it->second;
		}
	}
	return 0;
}

void DBProcessor::updatePlayerGameserver(const std::string& uid, int32_t sid, int32_t gameserver, int32_t state)
{
	int32_t num = getPlayerGameserver(uid, sid);

	if (state == 0)
	{
		int32_t curGameserver = num / 10;
		int32_t curstate = num % 10;
		if (curstate != 0)
		{
			if (curGameserver == gameserver)
			{
				m_uidGameServer[sid][uid] = 0;
			}
			else
			{
				LOG_ERROR("updatePlayerGameserver state error uid %s sid %d curnum %d gameserver %d, state %d\n", uid.c_str(), sid, num, gameserver, state);
			}
		}
		else
		{
			m_uidGameServer[sid][uid] = 0;
		}	
	}
	else
	{
		int32_t curGameserver = num / 10;
		int32_t curstate = num % 10;
		if (curstate == 0)
		{
			m_uidGameServer[sid][uid] = gameserver * 10 + state;
		}
		else
		{
			if (curGameserver != gameserver)
			{
				LOG_ERROR("updatePlayerGameserver state error uid %s sid %d curnum %d gameserver %d, state %d\n", uid.c_str(), sid, num, gameserver, state);
				m_uidGameServer[sid][uid] = gameserver * 10 + state;
				
				//原有gameserver踢出玩家
				kickPlayerGameserver(uid, sid, curGameserver);
			}
			else
			{
				m_uidGameServer[sid][uid] = gameserver * 10 + state;
			}
		}
	}
}

void DBProcessor::kickPlayerGameserver(const std::string& uid, int32_t sid, int32_t gameserver)
{
	/*Proto::DBPlayerGameExit msg;
	msg.set_uid(uid);
	msg.set_sid(sid);
	PROXY_CLIENT_MANAGER.randSendMessage(m_dbserverId, gameserver, Proto::IM_DB_GAME_PLAYER_EXIT, msg);
	*/
}

void DBProcessor::responseLoginLuaMsg(int32_t loginid, int32_t coidx, google::protobuf::Message & msg)
{
	auto sendpack = popAsioPacket(msg.ByteSize() + 4);

	sendpack->writeInt32(coidx);
	sendpack->writeProto(msg);
	LOGIN_CLIENT_MANAGER.sendMessage(loginid, Proto::IM_LOGIN_RESPONSE_MSG, sendpack);
}
