
�'
Common.protoProto"
null"4
Vector3D
x (Rx
y (Ry
z (Rz"&
Vector2D
x (Rx
y (Ry"�
CharacterList_Chrs
cid (Rcid
name (	Rname
delete_time (R
deleteTime
sex (Rsex#
guide_process (RguideProcess
job (Rjob
level (Rlevel
hunshi (Rhunshi
face	 (	Rface
model
 (Rmodel
logout_time (R
logoutTime"7
StorageInfo(
slots (2.Proto.StorageSlotRslots"�
StorageSlot
storage (Rstorage
slot (Rslot
type (Rtype
id (Rid
bind (Rbind
count (Rcount"X
SlotData
id (Rid
type (Rtype
count (Rcount
bind (Rbind"F
Attr
type (Rtype
addon (Raddon
field (Rfield"t
Effect
effectid (Reffectid
pam1 (Rpam1
pam2 (Rpam2
pam3 (Rpam3
pam4 (Rpam4"h

EquipAffix
id (Rid!
attrs (2.Proto.AttrRattrs'
effects (2.Proto.EffectReffects"�
PmEquipInfo
id (Rid
owner_id (RownerId
	owner_sid (RownerSid
base (Rbase
create_time (R
createTime
	strong_lv (RstrongLv
jinglian_lv (R
jinglianLv
star (Rstar
fuling_1	 (Rfuling1
fuling_2
 (Rfuling2
fuling_3 (Rfuling3
attr_lv (RattrLv
lock (Rlock
bind (Rbind"�

PmBoneInfo
id (Rid
owner_id (RownerId
base (Rbase
create_time (R
createTime
	strong_lv (RstrongLv

strong_exp (R	strongExp
jinglian_lv (R
jinglianLv
star_lv (RstarLv
star_exp	 (RstarExp

hunsui1_lv
 (R	hunsui1Lv

hunsui2_lv (R	hunsui2Lv

hunsui3_lv (R	hunsui3Lv

hunsui4_lv (R	hunsui4Lv

hunsui5_lv (R	hunsui5Lv
hunsui1_exp (R
hunsui1Exp
hunsui2_exp (R
hunsui2Exp
hunsui3_exp (R
hunsui3Exp
hunsui4_exp (R
hunsui4Exp
hunsui5_exp (R
hunsui5Exp
lock (Rlock
bind (Rbind"�
PmMonsterCoreInfo
id (Rid
owner_id (RownerId
base (Rbase
create_time (R
createTime
exp (Rexp
level (Rlevel
bind (Rbind
lock (Rlock
equip_id	 (RequipId"�
MemUniqueCommon
id (Rid
owner_id (RownerId
type (Rtype
base (Rbase
create_time (R
createTime
bind (Rbind
int1 (Rint1
int2 (Rint2
int3	 (Rint3
string1
 (	Rstring1
int4 (Rint4
lock (Rlock"�

MemChrMail
id (Rid
cid (Rcid
sender (Rsender
title (	Rtitle
content (	Rcontent
reward (	Rreward
state (Rstate
reason (Rreason
time	 (Rtime"P
MemSkillData
group (Rgroup
level (Rlevel
state (Rstate"3
MemSkill'
list (2.Proto.MemSkillDataRlist"

ProtoInt32
i32 (Ri32"
PInt64
data (Rdata"!
PInt64Array
data (Rdata"<
ProtoPairInt32
data1 (Rdata1
data2 (Rdata2"@
ProtoPairInt32Array)
list (2.Proto.ProtoPairInt32Rlist"#
ProtoInt32Array
i32 (Ri32"R
PInt64Pair32Array
i64 (Ri64+
array (2.Proto.ProtoPairInt32Rarray"
PString
data (	Rdata"R

TalentInfo
list (Rlist0
list_sub (2.Proto.ProtoPairInt32RlistSub"B
SoulCard
id (Rid
level (Rlevel
exp (Rexp"�
SoulInfo
yj_id (RyjId
use_soul (RuseSoul
soul1 (Rsoul1
soul2 (Rsoul2
soul3 (Rsoul3
soul4 (Rsoul4"Q
ShopBuyRecord
buyid (Rbuyid
buynum (Rbuynum
time (Rtime"q
NpcShopInfo
id (Rid*
last_refresh_time (RlastRefreshTime&
rcd (2.Proto.ShopBuyRecordRrcd"M
GameModuleAttr
module (Rmodule#
attr (2.Proto.GameAttrRattr"e
GameAttr
	attr_type (RattrType

value_type (R	valueType

attr_value (R	attrValue"n
PlayerModuleAttr
uid (	Ruid
sid (Rsid6
game_module (2.Proto.GameModuleAttrR
gameModule"0

UnitHandle
type (Rtype
id (Rid"�
PlayerSimpleInfo
cid (Rcid
level (Rlevel
name (	Rname
online (Ronline
logout_time (R
logoutTime
job (Rjob#
family_active (RfamilyActive!
hunshi_level (RhunshiLevel"�
DB_mem_family_event
	family_id (RfamilyId
id (Rid
type (Rtype
time (Rtime
string1 (	Rstring1
string2 (	Rstring2
int1 (Rint1
int2 (Rint2"�
DB_mem_chr_family_send
cid (Rcid
type (Rtype
id (Rid
friend1 (Rfriend1
friend2 (Rfriend2
friend3 (Rfriend3
time (Rtime"�
DB_mem_family_red_packet
	family_id (RfamilyId
id (Rid
cid (Rcid
type (Rtype
num (Rnum
value (Rvalue
job (Rjob
name (	Rname
time	 (Rtime"�
DB_mem_family_red_packet_record
	family_id (RfamilyId
id (Rid
cid (Rcid
value (Rvalue
job (Rjob
name (	Rnamebproto3
��
Client.protoProtoCommon.proto"8
ClientMsgGuide
cid (Rcid
guide (Rguide"J
ClientMsgLogin
uid (	Ruid
sid (Rsid
token (	Rtoken"H
CmNewCharacter
face (	Rface
sex (Rsex
job (Rjob",
ClientMsgDeleteCharacter
cid (Rcid"-
ClientMsgRecoverCharacter
cid (Rcid"J
ClientMsgEnterGame
uid (	Ruid
sid (Rsid
cid (Rcid"3
HunhuanCost
slot (Rslot
num (Rnum"^
UpgradeHunhuanStrength
id (Rid4
hunhuancost (2.Proto.HunhuanCostRhunhuancost"�

CmMoveFrom,
	start_pos (2.Proto.Vector3DRstartPos%
speed (2.Proto.Vector3DRspeed
rotation (Rrotation

start_time (R	startTime
action (Raction"�

SmMoveFrom
entity_type (R
entityType
	entity_id (RentityId,
	start_pos (2.Proto.Vector3DRstartPos%
speed (2.Proto.Vector3DRspeed
rotation (Rrotation

start_time (R	startTime
end_time (RendTime
action (Raction"/

CmMoveStop!
pos (2.Proto.Vector3DRpos"m

SmMoveStop
entity_type (R
entityType
	entity_id (RentityId!
pos (2.Proto.Vector3DRpos"�
SmMoveTo
entity_type (R
entityType
	entity_id (RentityId,
	start_pos (2.Proto.Vector3DRstartPos(
end_pos (2.Proto.Vector3DRendPos
speed (Rspeed

start_time (R	startTime
rotation (Rrotation
action (Raction
force	 (Rforce"�
SmMoveInstant
entity_type (R
entityType
	entity_id (RentityId!
pos (2.Proto.Vector3DRpos
action (Raction
dir (Rdir"�
CmJumpStart,
	start_pos (2.Proto.Vector3DRstartPos%
speed (2.Proto.Vector3DRspeed

start_time (R	startTime"�
SmJumpStart
entity_type (R
entityType
	entity_id (RentityId,
	start_pos (2.Proto.Vector3DRstartPos%
speed (2.Proto.Vector3DRspeed

start_time (R	startTime"5
	CmJumpEnd(
end_pos (2.Proto.Vector3DRendPos"s
	SmJumpEnd
entity_type (R
entityType
	entity_id (RentityId(
end_pos (2.Proto.Vector3DRendPos"D
CmOpenWings
open (Ropen!
pos (2.Proto.Vector3DRpos"�
SmOpenWings
entity_type (R
entityType
	entity_id (RentityId
open (Ropen!
pos (2.Proto.Vector3DRpos"/
CmServerTime
client_time (R
clientTime"o
	CmDoSkill
group (Rgroup)
target (2.Proto.UnitHandleRtarget!
pos (2.Proto.Vector3DRpos"4
SmStopSkill%
unit (2.Proto.UnitHandleRunit"�
SmPlayerInfo
cid (Rcid
sid (Rsid
uid (	Ruid
name (	Rname
job (Rjob
sex (Rsex
level (Rlevel
coin (Rcoin
exp	 (Rexp
map
 (Rmap
x (Rx
y (Ry
z (Rz
create_time (R
createTime
gold_unbind (R
goldUnbind
	gold_bind (RgoldBind
model (Rmodel">
MultiPlayerInfo+
player (2.Proto.SmPlayerInfoRplayer"�
SmCharacterList
uid (	Ruid
sid (Rsid

serverTime (R
serverTime-
chrs (2.Proto.CharacterList_ChrsRchrs"�
ServerMsgClientReply!
message_code (RmessageCode
result (Rresult
param1 (Rparam1
param2 (Rparam2"�

SmEnterMap
	entity_id (RentityId
map (Rmap!
pos (2.Proto.Vector3DRpos
	move_mode (RmoveMode
dir (Rdir"�
SmLevelInfo
level (Rlevel
hunshi (Rhunshi
	xuantian1 (R	xuantian1
	xuantian2 (R	xuantian2
	xuantian3 (R	xuantian3

attr_level (R	attrLevel 
attr_point_1 (R
attrPoint1 
attr_point_2 (R
attrPoint2 
attr_point_3	 (R
attrPoint3 
attr_point_4
 (R
attrPoint4 
attr_point_5 (R
attrPoint5"�
BaoxiangInfo
bid (Rbid
type (Rtype
map (Rmap
x (Rx
y (Ry
z (Rz
state (Rstate
time (Rtime"U
SmBaoxiangInfo/
baoxiang (2.Proto.BaoxiangInfoRbaoxiang
type (Rtype"
	SmExpInfo
exp (Rexp"9
SmDanyaoInfo)
danyao (2.Proto.DanyaoInfoRdanyao"0

DanyaoInfo
did (Rdid
num (Rnum"I
SmMoveSpeed
	entity_id (RentityId

move_speed (R	moveSpeed"Y
	SkillInfo
id (Rid
level (Rlevel
hunyin (Rhunyin
cd (Rcd"l
MapEntityInfo
	entity_id (RentityId
	move_wing (RmoveWing!
pos (2.Proto.Vector3DRpos"�
MapUnitInfo5
entity_info (2.Proto.MapEntityInfoR
entityInfo
max_hp (RmaxHp
hp (Rhp!
attack_speed (RattackSpeed&
buff_show_state (RbuffShowState

move_speed (R	moveSpeed
force (Rforce&
mark (2.Proto.ElementMarkRmark"�
MapPlayerInfo/
	unit_info (2.Proto.MapUnitInfoRunitInfo
name (	Rname
sex (Rsex
job (Rjob(
skills (2.Proto.SkillInfoRskills
whzs (Rwhzs
	face_time (RfaceTime
cid (Rcid
model	 (Rmodel"�
MapMonsterInfo/
	unit_info (2.Proto.MapUnitInfoRunitInfo

monster_id (R	monsterId
first_enter (R
firstEnter

owner_type (R	ownerType
owner_id (RownerId$
map_monster_id (RmapMonsterId"~
MapDropItemInfo5
entity_info (2.Proto.MapEntityInfoR
entityInfo
	item_type (RitemType
item_id (RitemId"p
MapCollectionInfo5
entity_info (2.Proto.MapEntityInfoR
entityInfo
id (Rid
state (Rstate"o
MapTrap5
entity_info (2.Proto.MapEntityInfoR
entityInfo
id (Rid

start_time (R	startTime"�
SmEnterView.
players (2.Proto.MapPlayerInfoRplayers1
monsters (2.Proto.MapMonsterInfoRmonsters4
	dropitems (2.Proto.MapDropItemInfoR	dropitems:
collections (2.Proto.MapCollectionInfoRcollections$
traps (2.Proto.MapTrapRtraps"1
ServerMsgLeaveView
	entity_id (RentityId"P
SmServerTime
client_time (R
clientTime
server_time (R
serverTime"7
SmEquipInfo(
equip (2.Proto.PmEquipInfoRequip"3

SmBoneInfo%
bone (2.Proto.PmBoneInfoRbone":

SmCoreInfo,
data (2.Proto.PmMonsterCoreInfoRdata"�
MemHunQi
id (Rid
owner_id (RownerId
base (Rbase
create_time (R
createTime
bind (Rbind
exp (Rexp
level (Rlevel
attr (Rattr
god_attr	 (RgodAttr&
base_attr_index
 (RbaseAttrIndex
lock (Rlock"1

SmMemHunQi#
data (2.Proto.MemHunQiRdata"r
MemItem
id (Rid
owner_id (RownerId
base (Rbase
bind (Rbind
extra (Rextra"/
	SmMemItem"
data (2.Proto.MemItemRdata"f
ItemBag
item (Ritem
count (Rcount

bind_count (R	bindCount
type (Rtype"/
	SmItemBag"
data (2.Proto.ItemBagRdata"
	SmKickOut
code (Rcode"7
SmSkillList(
skills (2.Proto.SkillInfoRskills"+
	SmSkillCD
id (Rid
cd (Rcd"�
SmSkillStart
id (Rid-
launcher (2.Proto.UnitHandleRlauncher)
target (2.Proto.UnitHandleRtarget!
pos (2.Proto.Vector3DRpos"�
SmSkillChain
id (Rid-
launcher (2.Proto.UnitHandleRlauncher.
	from_unit (2.Proto.UnitHandleRfromUnit*
to_unit (2.Proto.UnitHandleRtoUnit
multiple (Rmultiple"6
HpChangeInfo
val (Rval
state (Rstate"E

SkillChain%
unit (2.Proto.UnitHandleRunit
val (Rval"\
SkillResult%
unit (2.Proto.UnitHandleRunit
val (Rval
state (Rstate"�
SmSkillResult
id (Rid-
launcher (2.Proto.UnitHandleRlauncher,
results (2.Proto.SkillResultRresults7
multi_results (2.Proto.SkillResultRmultiResults

missile_id (R	missileId"�
SkillMissile
inst_id (RinstId
tid (Rtid2
target_unit (2.Proto.UnitHandleR
targetUnit.

target_pos (2.Proto.Vector3DR	targetPos"�
SmSkillMissile-
launcher (2.Proto.UnitHandleRlauncher

beneficial (R
beneficial-
missile (2.Proto.SkillMissileRmissile/
multiple (2.Proto.SkillMissileRmultiple
skill_id (RskillId
effct_index (R
effctIndex"�
SmChainMissile-
launcher (2.Proto.UnitHandleRlauncher.
	from_unit (2.Proto.UnitHandleRfromUnit-
missile (2.Proto.SkillMissileRmissile"k
CmSkillEffect
skill_id (RskillId
index (Rindex)
target (2.Proto.UnitHandleRtarget"y
CmMissileHitUnit

missile_id (R	missileId)
target (2.Proto.UnitHandleRtarget
	hit_index (RhitIndex"p
CmMissileHitPos

missile_id (R	missileId!
pos (2.Proto.Vector3DRpos
	hit_index (RhitIndex"k
CmCheckTask
groupid (Rgroupid
type (Rtype
param1 (Rparam1
param2 (Rparam2"&

CmTaskDone
groupid (Rgroupid"?
TaskProcess
finish (Rfinish
process (Rprocess"f
TaskInfo
taskid (Rtaskid
state (Rstate
process (Rprocess
time (Rtime"�
SingleTaskInfo
ttype (Rttype
taskid (Rtaskid
state (Rstate
process (Rprocess
time (Rtime"K
SmTypeTaskInfo
ttype (Rttype#
task (2.Proto.TaskInfoRtask" 

SmTaskData
data (Rdata"e
	taskRound
round (Rround
tid (Rtid
state (Rstate
progress (Rprogress"3
SmTaskRound$
task (2.Proto.taskRoundRtask"R
taskProgress
tid (Rtid
state (Rstate
progress (Rprogress"9
SmTaskWarToken'
task (2.Proto.taskProgressRtask"�
HunhuanInfo

hunhuan_id (R	hunhuanId
hunshi (Rhunshi
attr1 (Rattr1
attr2 (Rattr2
attr3 (Rattr3
attr4 (Rattr4
attr5 (Rattr5
level (Rlevel
exp	 (Rexp
hunyin1
 (Rhunyin1
hunyin2 (Rhunyin2
hunyin3 (Rhunyin3
break_level (R
breakLevel"Y
HunhuanInfoList
num (Rnum4
hunhuaninfo (2.Proto.HunhuanInfoRhunhuaninfo"B
AccceptTask
taskid (Rtaskid
	entity_id (RentityId"X

SmBuffShow
	unit_type (RunitType
unit_id (RunitId
shows (Rshows"�

BuffChange
group (Rgroup
unit_id (RunitId
is_del (RisDel
end_time (RendTime
layer (Rlayer"m

SmBuffList
	unit_type (RunitType
unit_id (RunitId)
change (2.Proto.BuffChangeRchange"E
CmAddListener
	unit_type (RunitType
unit_id (RunitId"�
SmNeigongInfo
grade (Rgrade
level (Rlevel
ratio (Rratio
neili (Rneili
time (Rtime
	buy_count (RbuyCount"s
	grassInfo
type (Rtype
years (Ryears
level (Rlevel
star (Rstar
attr (Rattr"<
grassGroupInfo
group (Rgroup
level (Rlevel"`
SmGrassInfo&
grass (2.Proto.grassInfoRgrass)
suit (2.Proto.grassGroupInfoRsuit"6
AttrInfo
index (Rindex
value (Rvalue"d
SmAttrs
	unit_type (RunitType
unit_id (RunitId#
attr (2.Proto.AttrInfoRattr"f

tianfuInfo
branch (Rbranch
page (Rpage
point (Rpoint
active (	Ractive"9
SmTianfuInfo)
tianfu (2.Proto.tianfuInfoRtianfu"?
SmSpiritInfo/

chr_spirit (2.Proto.ChrSpiritR	chrSpirit"�
	ChrSpirit
id (Rid
level (Rlevel
attr_1 (Rattr1
attr_2 (Rattr2
attr_3 (Rattr3
attr_4 (Rattr4
attr_5 (Rattr5"[
SmShenQiDataInfo
type (Rtype3

chr_shenqi (2.Proto.ChrShenQiDataR	chrShenqi"5
ChrShenQiData
id (Rid
level (Rlevel"�
SmWuhunInfo
	strong_lv (RstrongLv

strong_exp (R	strongExp

jinghua_lv (R	jinghuaLv

juexing_lv (R	juexingLv"9

ChrPayInfo
id (Rid
	buy_count (RbuyCount"5
SmChrPayInfo%
data (2.Proto.ChrPayInfoRdata">

SmEbowInfo
ebow_lv (RebowLv
suit_lv (RsuitLv"�
SmPositionInfo
pt_level (RptLevel
pt_star (RptStar
med_lv (RmedLv
pt_exp (RptExp

pt_exp_cur (RptExpCur"3
SmPositionRewardInfo
	get_state (RgetState"P
	DressInfo
type (Rtype
id (Rid
expire_time (R
expireTime"3
SmDressInfo$
data (2.Proto.DressInfoRdata"�

TujianInfo
group (Rgroup
id (Rid
affinity (Raffinity
affi_lv (RaffiLv
affi_unlock (R
affiUnlock
jb_lv (RjbLv
jb_activate (R
jbActivate
	cognition (R	cognition
cogni_lv	 (RcogniLv
unlock
 (Runlock"5
SmTujianInfo%
data (2.Proto.TujianInfoRdata"�
SmTujianTotalInfo
	score_npc (RscoreNpc#
score_monster (RscoreMonster!
score_baibao (RscoreBaibao
	score_map (RscoreMap
score_story (R
scoreStory"H

SmReplyRes
proc (Rproc
res (Rres
param (Rparam"[
ItemInfo
	item_type (RitemType
item_id (RitemId
item_num (RitemNum"6
SmMonsterDrop%
items (2.Proto.ItemInfoRitems"Z
SmWhzs
entity_type (R
entityType
	entity_id (RentityId
open (Ropen"^

CmMoveItem
id (Rid
type (Rtype
storage (Rstorage
slot (Rslot"Y
CmEquipFuling
equip_id (RequipId
index (Rindex
core_id (RcoreId"#
CmRevive
on_spot (RonSpot"G
CmCollectionUnlock
	entity_id (RentityId
param (Rparam"0
CmCollectionTouch
	entity_id (RentityId"F
SmCollectionState
	entity_id (RentityId
state (Rstate"m
DropItem
time (Rtime
x (Rx
y (Ry
z (Rz#
item (2.Proto.ItemInfoRitem"3
DropItemList#
data (2.Proto.DropItemRdata"�
AnqiInfo
id (Rid
	strong_lv (RstrongLv

strong_exp (R	strongExp
order_lv (RorderLv
	order_exp (RorderExp
skill_lv (RskillLv
jinglian_lv (R
jinglianLv
star_lv (RstarLv
star_exp	 (RstarExp"1

SmAnqiInfo#
data (2.Proto.AnqiInfoRdata"9
SmStopAction)
player (2.Proto.UnitHandleRplayer"5
Delete_instance
type (Rtype
id (Rid"?
SmDelete_instance*
list (2.Proto.Delete_instanceRlist"I
SmMonsterControl
	entity_id (RentityId
control (Rcontrol"�
SmLifeSkill
equip_lv (RequipLv
	equip_exp (RequipExp

lianzhi_lv (R	lianzhiLv
lianzhi_exp (R
lianzhiExp

lianjin_lv (R	lianjinLv
lianjin_exp (R
lianjinExp
cook_lv (RcookLv
cook_exp (RcookExp 
item_make_lv	 (R
itemMakeLv"
item_make_exp
 (RitemMakeExp"A
	EquipMake
id (Rid
num (Rnum
type (Rtype"3
SmEquipMake$
data (2.Proto.EquipMakeRdata"�
SmWing
	strong_lv (RstrongLv

strong_exp (R	strongExp
order_lv (RorderLv
star_lv (RstarLv
fuling (Rfuling"6

RecordInfo
type (Rtype
value (	Rvalue"5
SmRecordInfo%
info (2.Proto.RecordInfoRinfo"J
ElementMark
id (Rid
num (Rnum
end_time (RendTime"7
SmElementMark&
mark (2.Proto.ElementMarkRmark"�

BuffShield
type (Rtype
element (Relement
cur_life (RcurLife
max_life (RmaxLife
cur_ele (RcurEle
max_ele (RmaxEle"`
SmBuffShield%
unit (2.Proto.UnitHandleRunit)
shield (2.Proto.BuffShieldRshield"D

CmItemLock
type (Rtype
id (Rid
lock (Rlock"c
	TaskState
tid (Rtid
state (Rstate
progress (Rprogress
time (Rtime"�
SmVitalityInfo
vit (Rvit
state (Rstate
total (Rtotal
count (Rcount$
task (2.Proto.TaskStateRtask"c
ShopLimitInfo
shop_id (RshopId
count (Rcount#
discount_time (RdiscountTime";
SmShopLimitInfo(
data (2.Proto.ShopLimitInfoRdata"e
SmAchievementInfo
level (Rlevel
point (Rpoint$
task (2.Proto.TaskStateRtask"F
SelfCollection
id (Rid
num (Rnum
time (Rtime"=
SmSelfCollection)
data (2.Proto.SelfCollectionRdata"=
SelfCollectionForever
id (Rid
value (Rvalue"K
SmSelfCollectionForever0
data (2.Proto.SelfCollectionForeverRdata"3

SmMailInfo%
data (2.Proto.MemChrMailRdata"`
RelationInfo
rcid (Rrcid
type (Rtype
value (Rvalue
time (Rtime"~
SmRelationInfo'
data (2.Proto.RelationInfoRdata+
info (2.Proto.PlayerSimpleInfoRinfo
update (Rupdate"6
SmFriendLike
time (Rtime
data (Rdata"A
SmPlayerSimpleInfo+
data (2.Proto.PlayerSimpleInfoRdata"9
LevelGiftInfo
level (Rlevel
done (Rdone";
SmLevelGiftInfo(
list (2.Proto.LevelGiftInfoRlist"�
ChatMsg
type (Rtype
cid (Rcid
level (Rlevel
name (	Rname
tocid (Rtocid
roomid (Rroomid
msg (	Rmsg
data (Rdata"�
ClientChatMsg(
equip (2.Proto.PmEquipInfoRequip%
bone (2.Proto.PmBoneInfoRbone#
anQi (2.Proto.AnqiInfoRanQi"&
ArenaDailyInfo
score (Rscore"�
ArenaTeamMemberInfo
cid (Rcid
name (	Rname
job (Rjob
level (Rlevel
score (Rscore 
scorechange (Rscorechange
sid (Rsid
ready (Rready"Y
	ArenaTeam
teamid (Rteamid4
members (2.Proto.ArenaTeamMemberInfoRmembers"y
AreanTeamResult&
team1 (2.Proto.ArenaTeamRteam1&
team2 (2.Proto.ArenaTeamRteam2
result (Rresult"u
ArenaSignUpInfo
cid (Rcid
name (	Rname
job (Rjob
level (Rlevel
score (Rscore"{
ArenaCenterSignUp
serverid (Rserverid
teamid (Rteamid2
signinfo (2.Proto.ArenaSignUpInfoRsigninfo"v
ArenaSignRequest
cid (Rcid
name (	Rname
job (Rjob
level (Rlevel
score (Rscore"�
DungeonCenterSignUp
serverid (Rserverid
teamid (Rteamid
	dungeonid (R	dungeonid4
signinfo (2.Proto.DungeonSignUpInfoRsigninfo"�
DungeonSignUpInfo
cid (Rcid
name (	Rname
job (Rjob
level (Rlevel
score (Rscore

fight_type (R	fightType
sid (Rsid
teamid (Rteamid
	confirmed	 (R	confirmed"�
DungeonCenterWaitConfirm
	unique_id (RuniqueId
	dungeonid (R	dungeonid2
signup (2.Proto.DungeonCenterSignUpRsignup"�
DungeonSignInfo
teamid (Rteamid
uniqueid (Runiqueid
	dungeonid (R	dungeonid
infotype (Rinfotype
cids (Rcids"�
DungeonCenterEnter"
gameserverid (Rgameserverid
	dungeonid (R	dungeonid
uniqueid (Runiqueid4
signinfo (2.Proto.DungeonSignUpInfoRsigninfo"{
ArenaSignUpResult
result (Rresult&
team1 (2.Proto.ArenaTeamRteam1&
team2 (2.Proto.ArenaTeamRteam2"�
ArenaSignUpResultWithDgn2
aresult (2.Proto.ArenaSignUpResultRaresult
	dungeonid (R	dungeonid"
gameserverid (Rgameserverid"�

TeamMember
cid (Rcid
sex (Rsex
job (Rjob
level (Rlevel
name (	Rname
ready (Rready"�
TeamInfo
id (Rid
module (Rmodule
target (Rtarget
private (Rprivate
minlv (Rminlv
maxlv (Rmaxlv
time (Rtime
	dungeonid (R	dungeonid
state	 (Rstate
uniqueid
 (Runiqueid)
leader (2.Proto.TeamMemberRleader)
member (2.Proto.TeamMemberRmember"E

SmTeamInfo
type (Rtype#
team (2.Proto.TeamInfoRteam"�
	TeamApply
target (Rtarget
teamId (RteamId
cid (Rcid
sex (Rsex
job (Rjob
level (Rlevel
name (	Rname
time (Rtime"4
SmTeamApplyLog"
log (2.Proto.TeamApplyRlog"�
TeamApplyRec
cid (Rcid
sex (Rsex
job (Rjob
level (Rlevel
name (	Rname
time (Rtime
agree (Ragree";
SmTeamApplyRec)
apply (2.Proto.TeamApplyRecRapply"�
SmTeamInvit
target (Rtarget
teamId (RteamId
cid (Rcid
sex (Rsex
job (Rjob
level (Rlevel
name (	Rname
time (Rtime"H
SmTeamAction
cid (Rcid
name (	Rname
type (Rtype"O
SmCardMonthInfo
	get_state (RgetState
expire_time (R
expireTime"�
FamilySimpleInfo
id (Rid
level (Rlevel
name (	Rname
flag (Rflag
type (Rtype
count (Rcount
limit (Rlimit
leader_name (	R
leaderName
desc	 (	Rdesc

auto_agree
 (R	autoAgree
li_lv (RliLv
wu_lv (RwuLv
yu_lv (RyuLv
min_lv (RminLv
yao_lv (RyaoLv

build_time (R	buildTime"�

FamilyInfo
id (Rid
level (Rlevel
name (	Rname
flag (Rflag
type (Rtype
count (Rcount
limit (Rlimit
leader_name (	R
leaderName
desc	 (	Rdesc
power
 (Rpower
li_lv (RliLv
wu_lv (RwuLv
yu_lv (RyuLv
min_lv (RminLv
yao_lv (RyaoLv
gold (Rgold
mine (Rmine
stone (Rstone
wood (Rwood
notice (	Rnotice!
active_value (RactiveValue

auto_agree (R	autoAgree"L
FamilyOtherInfo#
leader_online (RleaderOnline
apply (Rapply"g
SmFamilyList+
data (2.Proto.FamilySimpleInfoRdata*
info (2.Proto.FamilyOtherInfoRinfo"�
CmCreateFamily
name (	Rname
flag (Rflag
type (Rtype
desc (	Rdesc

auto_agree (R	autoAgree
limit (Rlimit"9
SmFamilyInfo)
family (2.Proto.FamilyInfoRfamily"T
FamilyMember
cid (Rcid
position (Rposition
nochat (Rnochat"f
SmFamilyMember'
data (2.Proto.FamilyMemberRdata+
info (2.Proto.PlayerSimpleInfoRinfo"R
SmFamilyInvite
invite_name (	R
inviteName
family_name (	R
familyName"@
FamilyEventVec.
data (2.Proto.DB_mem_family_eventRdata">
SmFamilyEventVec2)
data (2.Proto.FamilyEventVecRdata"|
SmEntityOtherInfo
entity_type (R
entityType
	entity_id (RentityId)
list (2.Proto.ProtoPairInt32Rlist"�
DrawInfo#
item (2.Proto.ItemInfoRitem
extid (Rextid
extnum (Rextnum
group (Rgroup
first (Rfirst"1

SmDrawInfo#
data (2.Proto.DrawInfoRdata"�

SmHpChange
entity_type (R
entityType
	entity_id (RentityId
change (Rchange
reason (Rreason
param (Rparam
launcher_id (R
launcherId"�

SmWarToken
season (Rseason
time (Rtime
buy (Rbuy
level (Rlevel
exp (Rexp
	round_exp (RroundExp
free (Rfree
lock (Rlock"`
SmFamilySendInfo
ref_time (RrefTime1
data (2.Proto.DB_mem_chr_family_sendRdata"\
RedPackeRecord
id (Rid:
data (2&.Proto.DB_mem_family_red_packet_recordRdata"y
SmRedPacketInfo7
packet (2.Proto.DB_mem_family_red_packetRpacket-
record (2.Proto.RedPackeRecordRrecord"0
CmMapTeleport
teleport_id (R
teleportId"=

SmFastMove
	entity_id (RentityId
open (Ropen"�
SmWatchPlayerInfo+
info (2.Proto.PlayerSimpleInfoRinfo
family_flag (R
familyFlag'
family_position (RfamilyPosition
family_name (	R
familyName
	family_id (RfamilyId
nochat (Rnochat"j
CmChangeBaoxiangState
baoxiang_id (R
baoxiangId
password (	Rpassword
state (Rstate"F

SmFaceData
cid (Rcid
face (	Rface
time (Rtime"4
SmRequestSignDungeon
	dungeonid (R	dungeonid"?
MonsterDropInfo
monster (Rmonster
drop (Rdrop"?
SmMonsterDropInfo*
list (2.Proto.MonsterDropInfoRlist"!
SmModelChange
cid (Rcid"M
BaoxiangGroupInfo
group_id (RgroupId

opened_num (R	openedNum"C
SmBaoxiangGroupInfo,
list (2.Proto.BaoxiangGroupInfoRlist*�%
ClientMsgCodes

CM_MIN 
CM_LOGIN_MIN
CM_USER_LOGIN
CM_NEW_CHARACTER
CM_DELETE_CHARACTER
CM_RECOVER_CHARACTER
CM_SET_GUIDE_PROCESS
CM_LOGIN_MAX�
CM_PLAYER_MIN�
CM_ENTER_GAME�
CM_EXIT_GAME�
CM_MOVE�
CM_DO_SKILL�
CM_OPEN_WINGS�
CM_ADD_LISTENER�
CM_GAME_REQUEST_TEST�
	CM_REVIVE�
CM_COLLECTION_UNLOCK�
CM_COLLECTION_TOUCH�
CM_SKILL_EFFECT�
CM_MISSILE_HIT_UNIT�
CM_MISSILE_HIT_POS�
CM_STOP_SKILL�
CM_BROAD_ANIMATION�
CM_JUMP_START�
CM_JUMP_END�
CM_MOVE_FROM�
CM_MOVE_STOP�
CM_TRAP_TOUCH�
CM_FAST_MOVE�
CM_MAP_TELEPORT�
CM_MAP_EVENT_TRIGGER�
CM_MAP_SELF_TRANSFER�
CM_LEFT_DUNGEON�
CM_PLATER_LUA_BEGIN�
CM_TEST_HOT_LOAD�
CM_DEBUG�
CM_SERVER_TIME�
CM_MAKE_EQUIP�
CM_NEAR_PLAYER�
CM_EQUIP_STRONG�
CM_NEIGONG_UPGRADE�
CM_NEIGONG_NEILI�
CM_EQUIP_STRONG_RECYCLE�
CM_EQUIP_JINGLIAN�
CM_EQUIP_STAR�
CM_EQUIP_STAR_RECYCLE�
CM_REQUEST_TEST�
CM_TASK_INFO�
CM_RECEIVE_TASK�
CM_SUBMIT_TASK�
CM_HUNHUAN_INFO�
CM_GET_NEW_HUNHUAN�
CM_UPGRADE_HUNHUAN� 
CM_UPGRADE_HUNHUAN_STRENGTH�
CM_TIANFU_ACTIVE�
CM_TIANFU_RESET�
CM_CHECK_TASK_PROGRESS�
CM_GRASS_UPGRADE�
CM_CHECK_TASK_PROGRESS_N�
CM_OPEN_BAOXIANG�
CM_BAOXIANG_INFO�
CM_SET_BAOXIANG_OPEN�
CM_CHANGE_BAOXIANG_STATE�
CM_SPIRIT_INHERIT�
CM_SHENQI_QIHE�
CM_SHENQI_STRENGTHEN�
CM_SHENQI_STAR�
CM_NEW_NAME�
CM_FACE_DATA�
CM_WUHUN_STRONG�
CM_WUHUN_JINGHUA�
CM_WUHUN_JUEXING�
CM_HUNQI_STRONG�
CM_EQUIP_FULING_ON�
CM_EQUIP_FULING_OFF�
CM_BONE_STRONG�
CM_BONE_JINGLIAN�
CM_BONE_STAR�
CM_BONE_HUNSUI�
CM_USE_ITEM�
CM_PICK_ITEM�
CM_ITEM_COMPOSE�
CM_CLIENT_RECORD_UPDATE�
CM_SET_ITEM_LOCK�
CM_COOK�
CM_SELF_COLLECTION�
CM_FISH�
CM_INSTANCE_RECYCLE�
CM_ITEM_DELETE�
CM_ITEM_PUT_ON�
CM_ITEM_PUT_DOWN�
CM_BONE_ORDER_UPGRADE�
CM_CORE_LEVEL_UP�
CM_HUNYIN_COMPOSE�
CM_ITEM_COMPOSE_UNLOCK�
CM_ANQI_STRONG�
CM_ANQI_ORDER_UP�
CM_ANQI_SKILL_UP�
CM_ANQI_JINGLIAN�
CM_ANQI_STAR_UP�
CM_SET_LAVEL_ATTR�
CM_EAT_DANYAO�
CM_UNLOCK_HUNYIN�
CM_BREAK_HUANHUAN_STRENGTH�
CM_WING_STRONG�
CM_WING_ORDER�
CM_WING_STAR�
CM_WING_FULING�
CM_VITALITY_ACT�
CM_ACHIEVEMENT_ACT�
CM_TEAM_ACT�
CM_TEAM_CONFIRM_DUNGEON�
CM_EBOW_LEVEL_UP�
CM_EBOW_SUIT_LV_UP�
CM_POSITION_LV_UP�
CM_MEDAL_LV_UP�
CM_GET_POSITION_REWARD�
CM_AFFINITY_UP�
CM_UNLOCK_AFFI_MENU�
CM_ACTIVATE_JIBAN�
CM_GIVE_GIFT�
CM_COGNI_UP�
CM_UNLOCK_TUJIAN�
CM_GET_LEVEL_GIFT�
CM_LEVEL_GIFT_INFO�
CM_ARENA_DAILY_SIGN_UP�
CM_ARENA_DAILY_INFO�!
CM_REPLY_ARENA_DAILY_SIGN_UP�
CM_SWITCH_GAME�
CM_GET_SCORE_REWARD�
CM_SHOP_MALL_BUY�
CM_GET_TASK_GIFT�
CM_MAIL_READ�
CM_MAIL_GET�
CM_MAIL_DELETE�
CM_FRIEND_APPLY�
CM_FRIEND_RESP_APPLY�
CM_ADD_BLACK_LIST�
CM_GET_RELATION_INFO�
CM_FRIEND_DELETE�
CM_FRIEND_RECOMMEND�
CM_FRIEND_SEARCH�
CM_WATCH_PLAYER_INFO�
CM_FRIEND_LIKE�
CM_FRIEND_SEND_FLOWER�
CM_CHAT_CHECK_ENTER�
CM_CHAT�
CM_CHAT_UPDATE_POS�

CM_CHR_PAY�
CM_GET_CARD_MONTH_REWARD�
	CM_ZANZHU�
CM_GET_SIGN_UP_REWARD�
CM_GET_FIRST_PAY_REWARD�

CM_PAY_END�
CM_DRAW_CARD�
CM_UNLOCK_DRESS�
CM_WEAR_DRESS�
CM_WAR_TOKEN_ACT�
CM_BUY_NHHY�
CM_DIG_MONSTER�
CM_FAMILY_CREATE�
CM_FAMILY_GET_LIST�
CM_FAMILY_GET_MEMBER�
CM_FAMILY_GET_APPLY�
CM_FAMILY_APPLY�
CM_FAMILY_DEAL_APPLY�
CM_FAMILY_INVITE�
CM_FAMILY_DEAL_INVITE�
CM_FAMILY_DISBAND�
CM_FAMILY_QUIT�
CM_FAMILY_GET_INFO�
CM_FAMILY_SET_POWER�
CM_FAMILY_KICK�
CM_FAMILY_SET_POSITION�
CM_FAMILY_SET_FLAG�
CM_FAMILY_SET_DESC�
CM_FAMILY_BAN_CHAT�
CM_FAMILY_SET_APPLY�
CM_FAMILY_SELF_RECOMMEND�
CM_FAMILY_GET_EVENT�
CM_FAMILY_BUILD_UP�
CM_FAMILY_SET_NOTICE� 
CM_FAMILY_GET_ACTIVE_REWARD�
CM_FAMILY_DONATE_MONEY�
CM_FAMILY_DONATE_ITEM�
CM_FAMILY_GET_PLAYER_INFO�
CM_FAMILY_GET_SEND_INFO�
CM_FAMILY_FRIEND_SEND�%
 CM_FAMILY_FRIEND_SEND_GET_REWARD�
CM_FAMILY_GET_TASK_REWARD�"
CM_FAMILY_GET_RED_PACKET_INFO�
CM_FAMILY_GET_RED_PACKET�
CM_FAMILY_SEND_RED_PACKET�!
CM_FAMILY_FRIEND_SEND_CANCLE�
CM_FAMILY_END�
CM_VIR_PLAYER_PAY�
CM_PLATER_LUA_END�
CM_PLAYER_MAX�
CM_TEST_MIN�&
CM_BROADCAST_TEST�&
CM_TEST_MAX�'
CM_MAX�'*�
ServerMsgCodes
SM_NONE 
SM_MIN�'
SM_CLIENT_REPLY�'
SM_CHARACTOR_LIST�'
SM_ENTER_MAP�'
SM_ENTER_VIEW�'
SM_LEAVE_VIEW�'
SM_MOVE_FROM�'
SM_PLAYER_INFO�'
SM_SERVER_TIME�'
SM_BUFF_SHOW�'
SM_BUFF_LIST�'

SM_MOVE_TO�'
SM_ATTRS�'
SM_COLLECTION_STATE�'
SM_STOP_ACTION�'
SM_MONSTER_CONTROL�'
SM_SKILL_MISSILE�'
SM_CHAIN_MISSILE�'
SM_STOP_SKILL�'
SM_HP_CHANGE�'
SM_PLAY_ANIMATION�'
SM_PLAYER_ANIMATION�'
SM_MOVE_STOP�'
SM_MOVE_INSTANT�'
SM_STORAGE_INFO�'
SM_EQUIP_INFO�'
SM_CURRENCY_INFO�'
SM_LEVEL_INFO�'
SM_EXP_INFO�'
SM_BONE_INFO�'
SM_ITEM_BAG�'
SM_DELETE_INSTANCE�'
SM_CORE_INFO�'
SM_MOVE_SPEED�'
SM_MEM_ITEM_INFO�'
SM_FACE_DATA�'
SM_MAP_TELEPORT�'
SM_TASK_LIST�'
SM_TASK_PROGRESS�'
SM_TASK_RECEIVED�'
SM_TASK_SUBMITTED�'
SM_TASK_GIVEUPED�'
SM_SKILL_LIST�'
SM_SKILL_START�'
SM_SKILL_RESULT�'
SM_SKILL_CHAIN�'
SM_WHZS�'
SM_BAOXIANG_INFO�'
SM_LEVEL_GIFT_INFO�'
SM_ARENA_DAILY_SIGN_RESULT�'
SM_ARENA_DAILY_INFO�'
SM_ARENA_DAILY_RESULT�'
SM_OPEN_WINGS�'
SM_ARENA_SIGN_REQUEST�'
SM_REQUEST_SIGN_DUNGEON�'
SM_BAOXIANG_GROUP_INFO�'
SM_TASK_WAR_TOKEN_INFO�'
SM_TASK_ROUND_INFO�'
SM_TASK_DATA�'
SM_TYPE_TASK_INFO�'
SM_TASK_INFO�'
SM_HUNHUAN_INFO�'
SM_WUHUN_INFO�'
SM_REPLY_RES�'
SM_HUNQI_INFO�'
SM_LIFESKILL_INFO�'
SM_EQUIP_MAKE�'
SM_DANYAO_INFO�'
SM_WING_INFO�'
SM_CLIENT_RECORD�'
SM_SKILL_CD�'
SM_LAST_NHHY_CHANGE_TIME�'
SM_NHHY_BUY_NUM�'
SM_HUNHUAN_INFO_LIST�'
SM_KICK_OUT�'
SM_NEIGONG_INFO�'
SM_TIANFU_INFO�'
SM_GRASS_INFO�'
SM_SPIRIT_INFO�(
SM_SHENQI_DATA_INFO�(
SM_SHENQI_QIHE_INFO�(
SM_SHENQI_STRENGTHEN_INFO�(
SM_SHENQI_STAR_INFO�(
SM_ELEMENT_MARK�(
SM_BUFF_SHIELD�(
SM_JUMP_START�(
SM_JUMP_END�(
SM_FALL_GROUND�(
SM_DROP_ITEM�(
SM_ANQI_INFO�(
SM_VITALITY_INFO�(
SM_ACHIEVEMENT_INFO�(
SM_TEAM_INFO�(
SM_TEAM_APPLY�(
SM_TEAM_APPLY_REC�(
SM_TEAM_INVIT�(
SM_TEAM_ACTION�(
SM_MONSTER_DROP_INFO�(
SM_EBOW_INFO�(
SM_POSITION_INFO�(
SM_POSITION_REWARD_INFO�(
SM_TUJIAN_INFO�(
SM_TUJIAN_TOTAL_INFO�(
SM_NEAR_PLAYER_INFO�(
SM_SHOW_NPC�(
SM_SHOP_LIMIT_INFO�(
SM_SELF_COLLECTION�(
SM_SELF_COLLECTION_FOREVER�(
SM_MAIL_INFO�(
SM_MAIL_DELETE�(
SM_RELATION_INFO�(
SM_RELATION_DELETE�(
SM_FRIEND_RECOMMEND�(
SM_WATCH_PLAYER_INFO�(
SM_FRIEND_LIKE�(
SM_CHAT_SERVER_INFO�(
SM_CHAT_INFO�(

SM_CHR_PAY�(
SM_CARD_MONTH_INFO�(
SM_ZANZHU_INFO�(
SM_SIGN_UP_INFO�(
SM_FIRST_PAY�(
SM_CHR_PAY_END�(
SM_DUNGEON_WAIT_CONFIRM�(
SM_DRESS_INFO�(
SM_GLAMOUR_INFO�(
SM_WEAR_DRESS�(
SM_DRAW_CARD_REWARD�(
SM_ENTITY_OTHER_INFO�(
SM_DRAW_COUNT�(
SM_FAST_MOVE�(
SM_DUNGEON_CONFIRM_INFO�(
SM_DUNGEON_SIGN_INFO�(
SM_FAMILY_LIST�(
SM_FAMILY_INFO�(
SM_FAMILY_DELETE�(
SM_FAMILY_MEMBER�(
SM_FAMILY_APPLY�(
SM_FAMILY_INVITE�(
SM_FAMILY_EVENT�(
SM_FAMILY_PlAYER_INFO�(
SM_FAMILY_SEND_INFO�(
SM_FAMILY_RED_PACKET_INFO�(
SM_FAMILY_PLAYER_MEMBER�(
SM_WAR_TOKEN_INFO�(
SM_RECORD_VALUE�(
SM_CHR_MODEL_CHANGE�(
SM_EAT_FOOD_INFO�(
SM_MAX�Nbproto3
��
Server.protoProtoCommon.proto"4
GameDBConnected!
server_index (RserverIndex"�	
	DBChrInfo
cid (Rcid
sid (Rsid
uid (	Ruid
name (	Rname
sex (Rsex
level (Rlevel
coin (Rcoin
diamond (Rdiamond
exp	 (Rexp
map
 (Rmap
	map_index (RmapIndex"
unique_map_id (RuniqueMapId#
gameserver_id (RgameserverId
x (Rx
y (Ry
z (Rz
create_time (R
createTime
delete_time (R
deleteTime
back_map (RbackMap$
back_map_index (RbackMapIndex,
back_gameserver_id (RbackGameserverId
back_x (RbackX
back_y (RbackY
back_z (RbackZ+
back_unique_map_id (RbackUniqueMapId#
guide_process (RguideProcess$
back_unique_id (RbackUniqueId
job (Rjob 
attr_point_1 (R
attrPoint1 
attr_point_2 (R
attrPoint2 
attr_point_3 (R
attrPoint3 
attr_point_4  (R
attrPoint4 
attr_point_5! (R
attrPoint5
hunshi" (Rhunshi

attr_level# (R	attrLevel
	xuantian1$ (R	xuantian1
	xuantian2% (R	xuantian2
	xuantian3& (R	xuantian3

login_time' (R	loginTime
logout_time( (R
logoutTime
gold_unbind) (R
goldUnbind
	gold_bind* (RgoldBind
dir+ (Rdir
model, (Rmodel"�
DB_chr_storage
cid (Rcid
sid (Rsid
storage (Rstorage
slot (Rslot
type (Rtype
id (Rid
bind (Rbind
count (Rcount"|
DB_chr_item
cid (Rcid
item (Ritem
count (Rcount

bind_count (R	bindCount
type (Rtype"�
DB_chr_baoxiang_group
cid (Rcid
group (Rgroup
	first_num (RfirstNum
left_num (RleftNum*
next_refresh_time (RnextRefreshTime"�
DB_chr_baoxiang_task
cid (Rcid
tid (Rtid
state (Rstate
progress (	Rprogress
time (Rtime"�
DB_chr_baoxiang
cid (Rcid
bid (Rbid
groupid (Rgroupid
type (Rtype
map (Rmap
x (Rx
y (Ry
z (Rz
state	 (Rstate
opennum
 (Ropennum
time (Rtime"�
DB_chr_anqi
cid (Rcid
id (Rid
	strong_lv (RstrongLv

strong_exp (R	strongExp
order_lv (RorderLv
	order_exp (RorderExp
skill_lv (RskillLv
jinglian_lv (R
jinglianLv
star_lv	 (RstarLv
star_exp
 (RstarExp"�
DB_chr_hunhuan
cid (Rcid
sid (Rsid

hunhuan_id (R	hunhuanId
hunshi (Rhunshi
attr_1 (Rattr1
attr_2 (Rattr2
attr_3 (Rattr3
attr_4 (Rattr4
attr_5	 (Rattr5
level
 (Rlevel
exp (Rexp
hunyin_1 (Rhunyin1
hunyin_2 (Rhunyin2
hunyin_3 (Rhunyin3
break_level (R
breakLevel"�
DB_chr_neigong
cid (Rcid
grade (Rgrade
level (	Rlevel
ratio (	Rratio
neili (Rneili
time (Rtime"�
DBChrSpirit
cid (Rcid
id (Rid
level (Rlevel
attr_1 (Rattr1
attr_2 (Rattr2
attr_3 (Rattr3
attr_4 (Rattr4
attr_5	 (Rattr5"E
DB_chr_danyao
cid (Rcid
did (Rdid
num (Rnum"�
DB_chr_lifeskill
cid (Rcid
equip_lv (RequipLv
	equip_exp (RequipExp

lianzhi_lv (R	lianzhiLv
lianzhi_exp (R
lianzhiExp

lianjin_lv (R	lianjinLv
lianjin_exp (R
lianjinExp
cook_lv (RcookLv
cook_exp	 (RcookExp 
item_make_lv
 (R
itemMakeLv"
item_make_exp (RitemMakeExp
fish_lv (RfishLv
fish_exp (RfishExp"�
DB_chr_wing
cid (Rcid
	strong_lv (RstrongLv

strong_exp (R	strongExp
order_lv (RorderLv
star_lv (RstarLv
	fuling_lv (	RfulingLv"c
DB_chr_elementbow
cid (Rcid#
elementbow_lv (	RelementbowLv
suit_lv (RsuitLv"�
DB_chr_position
cid (Rcid
pt_level (RptLevel
pt_star (RptStar
med_lv (RmedLv
pt_exp (RptExp

pt_exp_cur (RptExpCur"G
DB_chr_position_reward
cid (Rcid
	get_state (RgetState"�
DB_chr_tujian_total
cid (Rcid
	score_npc (RscoreNpc#
score_monster (RscoreMonster!
score_baibao (RscoreBaibao
	score_map (RscoreMap
score_story (R
scoreStory
level (Rlevel"�
DB_chr_tujian
cid (Rcid
group (Rgroup
id (Rid
affinity (Raffinity
affi_lv (RaffiLv
affi_unlock (R
affiUnlock
jb_lv (RjbLv
jb_activate (R
jbActivate
	cognition	 (R	cognition
cogni_lv
 (RcogniLv
unlock (Runlock"e
DB_chr_dress
cid (Rcid
type (Rtype
id (Rid
expire_time (R
expireTime"�
DB_chr_shop_limit
cid (Rcid
shop_id (RshopId
count (Rcount

limit_type (R	limitType#
discount_time (RdiscountTime"[
DB_chr_equip_make
cid (Rcid
id (Rid
num (Rnum
type (Rtype"F
DBShenQiData
cid (Rcid
id (Rid
level (Rlevel"e
DBShenQiPray
cid (Rcid
id (Rid
level (Rlevel

pray_value (R	prayValue"u
DBShenQiQiLing
cid (Rcid
id (Rid
level (Rlevel
value (Rvalue
is_buy (RisBuy"}
DB_chr_task_trunk
cid (Rcid
tid (Rtid
state (Rstate
progress (	Rprogress
time (Rtime"K
DB_chr_record
cid (Rcid
type (Rtype
value (Rvalue"R
DB_chr_client_record
cid (Rcid
type (Rtype
value (	Rvalue"{
DB_chr_tianfu
cid (Rcid
branch (Rbranch
page (Rpage
point (Rpoint
active (	Ractive"�
DB_chr_wuhun
cid (Rcid
	strong_lv (RstrongLv

strong_exp (R	strongExp

jinghua_lv (R	jinghuaLv

juexing_lv (R	juexingLv
	fuling_lv (	RfulingLv"Z

DB_chr_pet
cid (Rcid
pid (Rpid
slot (Rslot
state (Rstate"�
DB_chr_grass
cid (Rcid
type (Rtype
years (Ryears
level (Rlevel
star (Rstar
attr (	Rattr"�
DB_chr_vit_gift
cid (Rcid
vit (Rvit
state (Rstate
total (Rtotal
count (Rcount
time (Rtime"g
DB_chr_vit_task
cid (Rcid
tid (Rtid
state (Rstate
progress (Rprogress"R
DB_chr_achievement
cid (Rcid
level (Rlevel
point (Rpoint"�
DB_chr_achievement_task
cid (Rcid
tid (Rtid
state (Rstate
progress (Rprogress
time (Rtime"[
DB_chr_collection
cid (Rcid
id (Rid
num (Rnum
time (Rtime"S
DB_chr_collection_forever
cid (Rcid
id (Rid
value (Rvalue"�
	PmPetInfo
id (Rid
owner_id (RownerId
base (Rbase
create_time (R
createTime
level (Rlevel
grade (Rgrade
zizhi_1 (Rzizhi1
zizhi_2 (Rzizhi2
zizhi_3	 (Rzizhi3
zizhi_4
 (Rzizhi4
zizhi_5 (Rzizhi5
attr_1 (Rattr1
attr_2 (Rattr2
attr_3 (Rattr3
attr_4 (Rattr4
attr_5 (Rattr5
attr_num (RattrNum
juexing (Rjuexing
neidan_1 (Rneidan1
neidan_2 (Rneidan2
neidan_3 (Rneidan3
neidan_4 (Rneidan4
neidan_5 (Rneidan5
skill_1 (Rskill1
skill_2 (Rskill2
skill_3 (Rskill3
skill_4 (Rskill4
skill_5 (Rskill5
skill_6 (Rskill6
skill_7 (Rskill7
skill_8 (Rskill8
skill_9  (Rskill9
skill_10! (Rskill10
skill_11" (Rskill11
skill_12# (Rskill12
skill_13$ (Rskill13
skill_14% (Rskill14
skill_15& (Rskill15
skill_16' (Rskill16"J
DB_chr_server_mail
cid (Rcid
id (Rid
time (Rtime"u
DB_chr_relation
cid (Rcid
rcid (Rrcid
type (Rtype
value (Rvalue
time (Rtime"O
DB_chr_level_gift
cid (Rcid
level (Rlevel
done (Rdone"K

DB_chr_pay
cid (Rcid
id (Rid
	buy_count (RbuyCount"L
DB_chr_sign_up
cid (Rcid
days (Rdays
state (Rstate"9
DB_chr_dress_wear
cid (Rcid
wear (	Rwear"�
DB_chr_task_random
cid (Rcid
ttype (Rttype
tid (Rtid
state (Rstate
progress (	Rprogress
time (Rtime"~
DB_chr_task_branch
cid (Rcid
tid (Rtid
state (Rstate
progress (	Rprogress
time (Rtime"
DB_chr_task_zhuanji
cid (Rcid
tid (Rtid
state (Rstate
progress (	Rprogress
time (Rtime"
DB_chr_task_round
cid (Rcid
round (Rround
tid (Rtid
state (Rstate
progress (Rprogress"�
DB_chr_arena
cid (Rcid
score (Rscore
win (Rwin
lose (Rlose
draw (Rdraw
time (Rtime"�
DB_chr_war_token
cid (Rcid
season (Rseason
time (Rtime
buy (Rbuy
level (Rlevel
exp (Rexp
round (Rround
	round_exp (RroundExp
free	 (	Rfree
lock
 (	Rlock"m
DB_chr_task_war_token
cid (Rcid
tid (Rtid
state (Rstate
progress (Rprogress"P
DB_chr_drow_item
cid (Rcid
itemid (Ritemid
type (Rtype"�
DB_chr_offline_event
cid (Rcid
type (Rtype
param1 (Rparam1
pi64 (Rpi64
param2 (Rparam2"<
DB_chr_friend_like
time (Rtime
data (Rdata"G
DB_chr_face
cid (Rcid
face (	Rface
time (Rtime"U
DB_chr_monster_drop
cid (Rcid
monster (Rmonster
drop (Rdrop"�
DBPlayerData

gate_index (R	gateIndex$
gate_server_id (RgateServerId+
chr_info (2.Proto.DBChrInfoRchrInfo/
storage (2.Proto.DB_chr_storageRstorage*
equips (2.Proto.PmEquipInfoRequips/
hunhuan (2.Proto.DB_chr_hunhuanRhunhuan,
record (2.Proto.DB_chr_recordRrecord/
neigong (2.Proto.DB_chr_neigongRneigong7

task_trunk	 (2.Proto.DB_chr_task_trunkR	taskTrunk,
tianfu
 (2.Proto.DB_chr_tianfuRtianfu*
spirit (2.Proto.DBChrSpiritRspirit4
shenqi_qihe (2.Proto.DBShenQiDataR
shenqiQihe@
shenqi_strengthen (2.Proto.DBShenQiDataRshenqiStrengthen4
shenqi_pray (2.Proto.DBShenQiPrayR
shenqiPray:
shenqi_qiling (2.Proto.DBShenQiQiLingRshenqiQiling4
shenqi_star (2.Proto.DBShenQiDataR
shenqiStar)
wuhun (2.Proto.DB_chr_wuhunRwuhun*
chr_pet (2.Proto.DB_chr_petRchrPet"
pet (2.Proto.PmPetInfoRpet)
grass (2.Proto.DB_chr_grassRgrass%
bone (2.Proto.PmBoneInfoRbone,
core (2.Proto.PmMonsterCoreInfoRcore&
item (2.Proto.DB_chr_itemRitemC
baoxiang_group (2.Proto.DB_chr_baoxiang_groupRbaoxiangGroup@
baoxiang_task (2.Proto.DB_chr_baoxiang_taskRbaoxiangTask2
baoxiang (2.Proto.DB_chr_baoxiangRbaoxiang&
anqi (2.Proto.DB_chr_anqiRanqi4
	memCommon (2.Proto.MemUniqueCommonR	memCommon,
danyao (2.Proto.DB_chr_danyaoRdanyao5
	lifeskill (2.Proto.DB_chr_lifeskillR	lifeskill7

equip_make (2.Proto.DB_chr_equip_makeR	equipMake-
chr_wing  (2.Proto.DB_chr_wingRchrWing@
client_record! (2.Proto.DB_chr_client_recordRclientRecord8

elementbow" (2.Proto.DB_chr_elementbowR
elementbow2
position# (2.Proto.DB_chr_positionRposition1
vit_gift$ (2.Proto.DB_chr_vit_giftRvitGift1
vit_task% (2.Proto.DB_chr_vit_taskRvitTask7

shop_limit& (2.Proto.DB_chr_shop_limitR	shopLimitF
position_reward' (2.Proto.DB_chr_position_rewardRpositionReward;
achievement( (2.Proto.DB_chr_achievementRachievementI
achievement_task) (2.Proto.DB_chr_achievement_taskRachievementTask8

collection* (2.Proto.DB_chr_collectionR
collection,
tujian+ (2.Proto.DB_chr_tujianRtujian=
tujian_total, (2.Proto.DB_chr_tujian_totalRtujianTotal%
mail- (2.Proto.MemChrMailRmail:
server_mail. (2.Proto.DB_chr_server_mailR
serverMail2
relation/ (2.Proto.DB_chr_relationRrelation7

level_gift0 (2.Proto.DB_chr_level_giftR	levelGift*
chr_pay1 (2.Proto.DB_chr_payRchrPay:
task_random2 (2.Proto.DB_chr_task_randomR
taskRandom5
chr_sign_up3 (2.Proto.DB_chr_sign_upR	chrSignUp:
task_branch4 (2.Proto.DB_chr_task_branchR
taskBranch=
task_zhuanji5 (2.Proto.DB_chr_task_zhuanjiRtaskZhuanji7

task_round6 (2.Proto.DB_chr_task_roundR	taskRound)
arena7 (2.Proto.DB_chr_arenaRarena)
dress8 (2.Proto.DB_chr_dressRdress4
	war_token9 (2.Proto.DB_chr_war_tokenRwarTokenB
task_war_token: (2.Proto.DB_chr_task_war_tokenRtaskWarToken>
family_send; (2.Proto.DB_mem_chr_family_sendR
familySend7

dress_wear< (2.Proto.DB_chr_dress_wearR	dressWear4
	drow_item= (2.Proto.DB_chr_drow_itemRdrowItem@
offline_event> (2.Proto.DB_chr_offline_eventRofflineEvent:
friend_like? (2.Proto.DB_chr_friend_likeR
friendLike&
face@ (2.Proto.DB_chr_faceRfaceO
collection_foreverA (2 .Proto.DB_chr_collection_foreverRcollectionForever=
monster_dropB (2.Proto.DB_chr_monster_dropRmonsterDrop"5
DB_sql_data
keys (	Rkeys
data (Rdata"v
DB_sql_data_list
cid (Rcid
sid (Rsid
table (Rtable(
datas (2.Proto.DB_sql_dataRdatas"�
DB_mem_family
id (Rid
level (Rlevel
name (	Rname
flag (Rflag
type (Rtype
limit (Rlimit

auto_agree (R	autoAgree
desc (	Rdesc
time	 (Rtime
power
 (Rpower
li_lv (RliLv
wu_lv (RwuLv
yu_lv (RyuLv
min_lv (RminLv
yao_lv (RyaoLv
gold (Rgold
mine (Rmine
stone (Rstone
wood (Rwood
notice (	Rnotice!
active_value (RactiveValue

build_time (R	buildTime"y
DB_mem_family_member
cid (Rcid
	family_id (RfamilyId
position (Rposition
nochat (Rnochat"X
DB_mem_family_apply
	family_id (RfamilyId
cid (Rcid
time (Rtime"�
DB_family_data,
family (2.Proto.DB_mem_familyRfamily3
member (2.Proto.DB_mem_family_memberRmember0
apply (2.Proto.DB_mem_family_applyRapply0
event (2.Proto.DB_mem_family_eventRevent>

red_packet (2.Proto.DB_mem_family_red_packetR	redPacketR
red_packet_record (2&.Proto.DB_mem_family_red_packet_recordRredPacketRecord"f
DBDungeonData
	unique_id (RuniqueId
map_id (RmapId!
pos (2.Proto.Vector3DRpos"M
DBEquipChange
type (Rtype(
equip (2.Proto.PmEquipInfoRequip"I
DBBoneChange
type (Rtype%
bone (2.Proto.PmBoneInfoRbone"E
DBPetChange
type (Rtype"
pet (2.Proto.PmPetInfoRpet"P
DBCoreChange
type (Rtype,
core (2.Proto.PmMonsterCoreInfoRcore"]
DBMemUniqueCommonChange
reason (Rreason*
data (2.Proto.MemUniqueCommonRdata"L
DBPlayerGameInfo
uid (	Ruid
sid (Rsid
state (Rstate"6
DBPlayerGameExit
uid (	Ruid
sid (Rsid"�
GameLoginKickUser
uid (	Ruid
sid (Rsid
gate_server (R
gateServer

gate_index (R	gateIndex

game_index (R	gameIndex"O
GateGameConnected!
server_index (RserverIndex
db_port (RdbPort"h
GateGameEnterGame

gate_index (R	gateIndex
uid (	Ruid
sid (Rsid
cid (Rcid"U
GateGameExitGame

gate_index (R	gateIndex
uid (	Ruid
sid (Rsid"�
GameGateExitGameReply
	wait_time (RwaitTime

gate_index (R	gateIndex!
player_index (RplayerIndex!
server_index (RserverIndex
uid (	Ruid"�
ImGameGateSetGameIndex

gate_index (R	gateIndex

game_index (R	gameIndex
uid (	Ruid
sid (Rsid#
switch_server (RswitchServer"
GateLoginConnected"�
LoginGateLoginResult
result (Rresult
index (Rindex
uid (	Ruid
sid (Rsid&
login_server_id (RloginServerId"i
LoginGateEnterGame
uid (	Ruid
sid (Rsid
cid (Rcid

gate_index (R	gateIndex"V
LoginGateKickUser
uid (	Ruid
sid (Rsid

gate_index (R	gateIndex"�
GameKickPlayer
uid (	Ruid
sid (Rsid

game_index (R	gameIndex$
gate_server_id (RgateServerId

gate_index (R	gateIndex$
game_server_id (RgameServerId"�

SwitchGame$
game_server_id (RgameServerId
map_id (RmapId
	map_index (RmapIndex
x (Rx
y (Ry
z (Rz"�
ImSwitchGame$
game_server_id (RgameServerId
map_id (RmapId
	map_index (RmapIndex
x (Rx
y (Ry
z (Rz
cid (Rcid
sid (Rsid
uid	 (	Ruid&
login_server_id
 (RloginServerId
	unique_id (RuniqueId"�
ImGamePlayerLoaded

gate_index (R	gateIndex
gate_id (RgateId
db_id (RdbId+
chr_info (2.Proto.DBChrInfoRchrInfo6
module_attr (2.Proto.GameModuleAttrR
moduleAttr?
skill_level_info (2.Proto.SkillLevelInfoRskillLevelInfo#
switch_server (RswitchServer
	face_time (RfaceTime"m
ImDbSaveGamePlayer
cid (Rcid
sid (Rsid!
pos (2.Proto.Vector3DRpos
dir (Rdir"M
ImCheckTaskProgress
	condition (R	condition
placeid (Rplaceid"|
ImUpdateTaskProgress
	condition (R	condition
param1 (Rparam1
param2 (Rparam2
param3 (Rparam3"}
ImMonsterDie$
map_monster_id (RmapMonsterId

monster_id (R	monsterId
x (Rx
y (Ry
z (Rz"�

ImEnterMap
map_id (RmapId
x (Rx
y (Ry
z (Rz
	map_index (RmapIndex
back_map (RbackMap,
back_gameserver_id (RbackGameserverId$
back_map_index (RbackMapIndex
back_x	 (RbackX
back_y
 (RbackY
back_z (RbackZ"Y
SkillLevelInfo
skill_id (RskillId
level (Rlevel
hunyin (Rhunyin"S
ImSkillLevelInfo?
skill_level_info (2.Proto.SkillLevelInfoRskillLevelInfo"M
	ImMapDrop!
pos (2.Proto.Vector3DRpos

drop_group (R	dropGroup"I
ImAddBag%
slots (2.Proto.SlotDataRslots
reason (Rreason"1
MailList%
data (2.Proto.MemChrMailRdata"C
PlayerSimpleInfoList+
data (2.Proto.PlayerSimpleInfoRdata"<
ImDbUpdatePlayerName
cid (Rcid
name (	Rname"�
PayLog
id (Rid
oid (	Roid
rmb (Rrmb
gold (Rgold
product (Rproduct
log (Rlog
time (Rtime"1
PayLogVector!
data (2.Proto.PayLogRdata"K
DB_chr_no_redis
cid (Rcid
mod1 (Rmod1
mod2 (Rmod2"�
log_draw_card
cid (Rcid
item_id (RitemId
	item_type (RitemType
num (Rnum
active (Ractive
time (Rtime"�
log_useitem
cid (Rcid
itemid (Ritemid
type (Rtype
num (Rnum
reason (Rreason
realid (Rrealid
time (Rtime*�
InternalMsg

IM_MIN 
	IM_DB_MIN�N
IM_DB_LOAD_PLAYER�N!
IM_DB_LOGIN_SERVER_CONNECTED�N
IM_DB_SAVE_PLAYER�N
IM_DB_UPDATE_PLAYER�N
IM_DB_DELETE_PLAYER�N
IM_DB_INSERT_EQUIP�N
IM_DB_UPDATE_EQUIP�N
IM_DB_DELETE_EQUIP�N
IM_DB_SAVE_GAME_PLAYER�N
IM_DB_INSERT_BONE�N
IM_DB_UPDATE_BONE�N
IM_DB_DELETE_BONE�N
IM_DB_INSERT_PET�N
IM_DB_UPDATE_PET�N
IM_DB_DELETE_PET�N
IM_DB_INSERT_CORE�N
IM_DB_UPDATE_CORE�N
IM_DB_DELETE_CORE�N
IM_DB_INSERT_MEM_COMMON�N
IM_DB_UPDATE_MEM_COMMON�N
IM_DB_DELETE_MEM_COMMON�N
IM_DB_INSERT_MAIL�N
IM_DB_UPDATE_MAIL�N
IM_DB_DELETE_MAIL�N
IM_DB_GET_RELATION�N
IM_DB_LOAD_SIMPLE_INFO�N
IM_DB_FRIEND_SEARCH�N
IM_DB_INSERT_DATA�N
IM_DB_UPDATE_DATA�N
IM_DB_DELETE_DATA�N
IM_DB_UPDATE_PLAYER_NAME�N
IM_DB_UPDATE_PAY_LOG�N
	IM_DB_MAX�U
IM_GAME_MIN�U
IM_GAME_KICK_PLAYER�U
IM_GAME_MODULE_ATTR�U
IM_GAME_PLAYER_LOADED�U
IM_GAME_TO_PLAYER_MSG�U
IM_GAME_REQUEST_TEST�U 
IM_GAME_PLAYER_REQUEST_TEST�U 
IM_GAME_PLAYER_RESPONSE_MSG�V/
*IM_GAME_PLAYER_REQUEST_CHECK_TASK_PROGRESS�V$
IM_GAME_PLAYER_SKILL_LEVEL_INFO�V
IM_GAME_INIT_SCENE�V&
!IM_GAME_PLAYER_SKILL_LEVEL_UPDATE�V
IM_GAME_LEAVE_MAP�V%
 IM_GAME_PLAYER_REQUEST_CHECK_POS�V
IM_GAME_PLAYER_ADD_BUFF�V
IM_GAME_PLAYER_ADD_ATTR�V
IM_GAME_SWITCH_GAME�V!
IM_GAME_LEAVE_MAP_FOR_SWITCH�V
IM_GAME_OPEN_WING�V
IM_GAME_PLAYER_REMOVE_BUFF�V
IM_GAME_UPDATE_AI�V!
IM_GAME_PLAYER_TASK_RECEIVED�V"
IM_GAME_PLAYER_TASK_COMPLETED�V%
 IM_GAME_PLAYER_CHECK_MONSTER_DIG�V 
IM_GAME_PLAYER_CHANGE_MODEL�V
IM_GAME_MAX�]
IM_LOGIN_MIN�]
IM_LOGIN_SERVER_DISCONNECT�]
IM_LOGIN_CONNECTED�]
IM_LOGIN_PLAYER_LOADED�]
IM_LOGIN_EXIT_GAME�]
IM_LOGIN_GATE_KICK_USER�]
IM_LOGIN_SAVE_USER�]
IM_LOGIN_ENTER_GAME�]
IM_LOGIN_GAME_KICK_USER�]
IM_LOGIN_RESPONSE_MSG�]!
IM_LOGIN_PLAYER_REQUEST_TEST�])
$IM_LOGIN_PLAYER_UPDATE_TASK_PROGRESS�]
IM_LOGIN_MONSTER_DIE�]
IM_LOGIN_PLAYER_REVIVE�]
IM_LOGIN_MAP_DROP�]
IM_LOGIN_ADD_BAG�]
IM_LOGIN_LOAD_SERVER_MAIL�]
IM_LOGIN_LOAD_FAMILY_DATA�]
IM_LOGIN_SWITCH_GAME�]
IM_LOGIN_CHECK_TELEPORT�]!
IM_LOGIN_PLAYER_RECEIVE_TASK�]
IM_LOGIN_ENTER_MAP�]
IM_LOGIN_MONSTER_MIN_HP�]$
IM_LOGIN_PLAYER_ADD_NEW_HUNHUAN�]
IM_LOGIN_ADD_BUFF�]
IM_LOGIN_PLAYER_ATK�]"
IM_LOGIN_ARENA_SIGN_UP_RESULT�_"
IM_LOGIN_DUNGEON_WAIT_CONFIRM�_"
IM_LOGIN_DUNGEON_CONFIRM_INFO�_#
IM_LOGIN_DUNGEON_ENTER_DUNGEON�_
IM_LOGIN_DUNGEON_SIGN_INFO�_
IM_LOGIN_ARENA_SIGN_INFO�_
IM_LOGIN_CENTER_END�`
IM_LOGIN_HOT_LOAD�a
IM_LOGIN_AI_UPDATE�a
IM_LOGIN_PHP_PAY�b
IM_LOGIN_USER_PAY�b
IM_LOGIN_INTERNAL_GAME�e"
IM_LOGIN_INTERNAL_REMOVE_USER�e
IM_LOGIN_INTERNAL_DB�e
IM_LOGIN_INTERNAL_CLIENT�e
IM_LOGIN_MAX�e
IM_GATE_MIN�e
IM_GATE_SET_GAME_INDEX�e
IM_GATE_LOGIN_RESULT�e
IM_GATE_KICK_USER�e
IM_GATE_MAX�m
IM_CENTER_MIN�m
IM_CENTER_CONNECTED�m
IM_CENTER_ARENA_SIGN_UP�m
IM_CENTER_ADD_GAMESERVER�m 
IM_CENTER_REMOVE_GAMESERVER�m
IM_CENTER_DUNGEON_SIGN_UP�m
IM_CENTER_DUNGEON_CONFIRM�m"
IM_CENTER_CANCEL_SIGN_DUNGEON�m 
IM_CENTER_CANCEL_SIGN_ARENA�m
IM_CENTER_MAX�u
IM_PROXY_DB_MIN�u
IM_PR0XY_DB_CONNECTED��
IM_PR0XY_GAME_CONNECTED��
IM_PR0XY_PROXY_CONNECTED��
IM_PROXY_DB_MAX�|
IM_CHAT_MIN�}
IM_CHAT_PLAYER_LOGIN�}
IM_CHAT_PLAYER_LOGOUT�}
IM_CHAT_ENTER_TEAM�}
IM_CHAT_QUIT_TEAM�}
IM_CHAT_MAX�~

IM_PHP_MIN�
IM_PHP_DB_USER_PAY�

IM_PHP_MAXό

IM_LOG_MINЌ

IM_LOG_LOGь

IM_LOG_MAX��
IM_MAX��*L
DBEquipChangeType
DB_ECT_INSERT 
DB_ECT_DELETE
DB_ECT_UPDATEbproto3