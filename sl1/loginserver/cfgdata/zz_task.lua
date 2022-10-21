local data = {
	[10001] = {id=10001,round=1,job=1,type=1,param=0,progress=2,reward={{13,1,10},{6001,1,20}}},
	[10002] = {id=10002,round=1,job=1,type=2,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[10003] = {id=10003,round=1,job=1,type=3,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[10004] = {id=10004,round=1,job=1,type=4,param=0,progress=10,reward={{13,1,10},{1,1,2000}}},
	[10005] = {id=10005,round=1,job=1,type=5,param=0,progress=1,reward={{13,1,10},{2501,1,10}}},
	[10006] = {id=10006,round=1,job=1,type=6,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[10007] = {id=10007,round=1,job=1,type=7,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[10008] = {id=10008,round=1,job=1,type=8,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[10009] = {id=10009,round=1,job=1,type=9,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[10010] = {id=10010,round=1,job=1,type=10,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[10011] = {id=10011,round=2,job=1,type=1,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[10012] = {id=10012,round=2,job=1,type=11,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10013] = {id=10013,round=2,job=1,type=12,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10014] = {id=10014,round=2,job=1,type=13,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[10015] = {id=10015,round=2,job=1,type=14,param=0,progress=2,reward={{13,1,10},{2501,1,10}}},
	[10016] = {id=10016,round=2,job=1,type=15,param=1,progress=1,reward={{13,1,10},{5501,1,20}}},
	[10017] = {id=10017,round=2,job=1,type=16,param=0,progress=3,reward={{13,1,10},{1701,1,10}}},
	[10018] = {id=10018,round=2,job=1,type=17,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[10019] = {id=10019,round=2,job=1,type=18,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[10020] = {id=10020,round=2,job=1,type=19,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[10021] = {id=10021,round=3,job=1,type=20,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[10022] = {id=10022,round=3,job=1,type=21,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10023] = {id=10023,round=3,job=1,type=22,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[10024] = {id=10024,round=3,job=1,type=23,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[10025] = {id=10025,round=3,job=1,type=15,param=20,progress=1,reward={{13,1,10},{2501,1,10}}},
	[10026] = {id=10026,round=3,job=1,type=24,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[10027] = {id=10027,round=3,job=1,type=25,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[10028] = {id=10028,round=3,job=1,type=26,param=0,progress=2,reward={{13,1,10},{6511,1,20}}},
	[10029] = {id=10029,round=3,job=1,type=27,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[10030] = {id=10030,round=3,job=1,type=1,param=0,progress=4,reward={{13,1,10},{1,1,20000}}},
	[10031] = {id=10031,round=4,job=1,type=28,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[10032] = {id=10032,round=4,job=1,type=29,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10033] = {id=10033,round=4,job=1,type=30,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10034] = {id=10034,round=4,job=1,type=31,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10035] = {id=10035,round=4,job=1,type=15,param=30,progress=1,reward={{13,1,10},{2501,1,10}}},
	[10036] = {id=10036,round=4,job=1,type=32,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[10037] = {id=10037,round=4,job=1,type=33,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[10038] = {id=10038,round=4,job=1,type=34,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[10039] = {id=10039,round=4,job=1,type=35,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[10040] = {id=10040,round=4,job=1,type=1,param=0,progress=5,reward={{13,1,10},{1,1,20000}}},
	[10041] = {id=10041,round=5,job=1,type=36,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[10042] = {id=10042,round=5,job=1,type=37,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[10043] = {id=10043,round=5,job=1,type=38,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10044] = {id=10044,round=5,job=1,type=23,param=0,progress=8,reward={{13,1,10},{1,1,2000}}},
	[10045] = {id=10045,round=5,job=1,type=15,param=40,progress=3,reward={{13,1,10},{2501,1,10}}},
	[10046] = {id=10046,round=5,job=1,type=44,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[10047] = {id=10047,round=5,job=1,type=42,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[10048] = {id=10048,round=5,job=1,type=25,param=3,progress=1,reward={{13,1,10},{6511,1,20}}},
	[10049] = {id=10049,round=5,job=1,type=43,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[10050] = {id=10050,round=5,job=1,type=1,param=0,progress=6,reward={{13,1,10},{1,1,20000}}},
	[10051] = {id=10051,round=6,job=1,type=36,param=0,progress=5,reward={{13,1,10},{6001,1,20}}},
	[10052] = {id=10052,round=6,job=1,type=45,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[10053] = {id=10053,round=6,job=1,type=14,param=0,progress=5,reward={{13,1,10},{1,1,2000}}},
	[10054] = {id=10054,round=6,job=1,type=46,param=2,progress=5,reward={{13,1,10},{1,1,2000}}},
	[10055] = {id=10055,round=6,job=1,type=15,param=50,progress=3,reward={{13,1,10},{2501,1,10}}},
	[10056] = {id=10056,round=6,job=1,type=47,param=0,progress=20,reward={{13,1,10},{5501,1,20}}},
	[10057] = {id=10057,round=6,job=1,type=39,param=0,progress=5,reward={{13,1,10},{1701,1,10}}},
	[10058] = {id=10058,round=6,job=1,type=40,param=0,progress=5,reward={{13,1,10},{6511,1,20}}},
	[10059] = {id=10059,round=6,job=1,type=41,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[10060] = {id=10060,round=6,job=1,type=1,param=0,progress=7,reward={{13,1,10},{1,1,20000}}},
	[20001] = {id=20001,round=1,job=2,type=1,param=0,progress=2,reward={{13,1,10},{6001,1,20}}},
	[20002] = {id=20002,round=1,job=2,type=2,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[20003] = {id=20003,round=1,job=2,type=3,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[20004] = {id=20004,round=1,job=2,type=4,param=0,progress=10,reward={{13,1,10},{1,1,2000}}},
	[20005] = {id=20005,round=1,job=2,type=5,param=0,progress=1,reward={{13,1,10},{2501,1,10}}},
	[20006] = {id=20006,round=1,job=2,type=6,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[20007] = {id=20007,round=1,job=2,type=7,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[20008] = {id=20008,round=1,job=2,type=8,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[20009] = {id=20009,round=1,job=2,type=9,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[20010] = {id=20010,round=1,job=2,type=10,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[20011] = {id=20011,round=2,job=2,type=1,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[20012] = {id=20012,round=2,job=2,type=11,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20013] = {id=20013,round=2,job=2,type=12,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20014] = {id=20014,round=2,job=2,type=13,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[20015] = {id=20015,round=2,job=2,type=14,param=0,progress=2,reward={{13,1,10},{2501,1,10}}},
	[20016] = {id=20016,round=2,job=2,type=15,param=1,progress=1,reward={{13,1,10},{5501,1,20}}},
	[20017] = {id=20017,round=2,job=2,type=16,param=0,progress=3,reward={{13,1,10},{1701,1,10}}},
	[20018] = {id=20018,round=2,job=2,type=17,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[20019] = {id=20019,round=2,job=2,type=18,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[20020] = {id=20020,round=2,job=2,type=19,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[20021] = {id=20021,round=3,job=2,type=20,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[20022] = {id=20022,round=3,job=2,type=21,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20023] = {id=20023,round=3,job=2,type=22,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[20024] = {id=20024,round=3,job=2,type=23,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[20025] = {id=20025,round=3,job=2,type=15,param=20,progress=1,reward={{13,1,10},{2501,1,10}}},
	[20026] = {id=20026,round=3,job=2,type=24,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[20027] = {id=20027,round=3,job=2,type=25,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[20028] = {id=20028,round=3,job=2,type=26,param=0,progress=2,reward={{13,1,10},{6511,1,20}}},
	[20029] = {id=20029,round=3,job=2,type=27,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[20030] = {id=20030,round=3,job=2,type=1,param=0,progress=4,reward={{13,1,10},{1,1,20000}}},
	[20031] = {id=20031,round=4,job=2,type=28,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[20032] = {id=20032,round=4,job=2,type=29,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20033] = {id=20033,round=4,job=2,type=30,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20034] = {id=20034,round=4,job=2,type=31,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20035] = {id=20035,round=4,job=2,type=15,param=30,progress=1,reward={{13,1,10},{2501,1,10}}},
	[20036] = {id=20036,round=4,job=2,type=32,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[20037] = {id=20037,round=4,job=2,type=33,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[20038] = {id=20038,round=4,job=2,type=34,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[20039] = {id=20039,round=4,job=2,type=35,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[20040] = {id=20040,round=4,job=2,type=1,param=0,progress=5,reward={{13,1,10},{1,1,20000}}},
	[20041] = {id=20041,round=5,job=2,type=36,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[20042] = {id=20042,round=5,job=2,type=37,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[20043] = {id=20043,round=5,job=2,type=38,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20044] = {id=20044,round=5,job=2,type=23,param=0,progress=8,reward={{13,1,10},{1,1,2000}}},
	[20045] = {id=20045,round=5,job=2,type=15,param=40,progress=3,reward={{13,1,10},{2501,1,10}}},
	[20046] = {id=20046,round=5,job=2,type=44,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[20047] = {id=20047,round=5,job=2,type=42,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[20048] = {id=20048,round=5,job=2,type=25,param=3,progress=1,reward={{13,1,10},{6511,1,20}}},
	[20049] = {id=20049,round=5,job=2,type=43,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[20050] = {id=20050,round=5,job=2,type=1,param=0,progress=6,reward={{13,1,10},{1,1,20000}}},
	[20051] = {id=20051,round=6,job=2,type=36,param=0,progress=5,reward={{13,1,10},{6001,1,20}}},
	[20052] = {id=20052,round=6,job=2,type=45,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[20053] = {id=20053,round=6,job=2,type=14,param=0,progress=5,reward={{13,1,10},{1,1,2000}}},
	[20054] = {id=20054,round=6,job=2,type=46,param=2,progress=5,reward={{13,1,10},{1,1,2000}}},
	[20055] = {id=20055,round=6,job=2,type=15,param=50,progress=3,reward={{13,1,10},{2501,1,10}}},
	[20056] = {id=20056,round=6,job=2,type=47,param=0,progress=20,reward={{13,1,10},{5501,1,20}}},
	[20057] = {id=20057,round=6,job=2,type=39,param=0,progress=5,reward={{13,1,10},{1701,1,10}}},
	[20058] = {id=20058,round=6,job=2,type=40,param=0,progress=5,reward={{13,1,10},{6511,1,20}}},
	[20059] = {id=20059,round=6,job=2,type=41,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[20060] = {id=20060,round=6,job=2,type=1,param=0,progress=7,reward={{13,1,10},{1,1,20000}}},
	[30001] = {id=30001,round=1,job=3,type=1,param=0,progress=2,reward={{13,1,10},{6001,1,20}}},
	[30002] = {id=30002,round=1,job=3,type=2,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[30003] = {id=30003,round=1,job=3,type=3,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[30004] = {id=30004,round=1,job=3,type=4,param=0,progress=10,reward={{13,1,10},{1,1,2000}}},
	[30005] = {id=30005,round=1,job=3,type=5,param=0,progress=1,reward={{13,1,10},{2501,1,10}}},
	[30006] = {id=30006,round=1,job=3,type=6,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[30007] = {id=30007,round=1,job=3,type=7,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[30008] = {id=30008,round=1,job=3,type=8,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[30009] = {id=30009,round=1,job=3,type=9,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[30010] = {id=30010,round=1,job=3,type=10,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[30011] = {id=30011,round=2,job=3,type=1,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[30012] = {id=30012,round=2,job=3,type=11,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30013] = {id=30013,round=2,job=3,type=12,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30014] = {id=30014,round=2,job=3,type=13,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[30015] = {id=30015,round=2,job=3,type=14,param=0,progress=2,reward={{13,1,10},{2501,1,10}}},
	[30016] = {id=30016,round=2,job=3,type=15,param=1,progress=1,reward={{13,1,10},{5501,1,20}}},
	[30017] = {id=30017,round=2,job=3,type=16,param=0,progress=3,reward={{13,1,10},{1701,1,10}}},
	[30018] = {id=30018,round=2,job=3,type=17,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[30019] = {id=30019,round=2,job=3,type=18,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[30020] = {id=30020,round=2,job=3,type=19,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[30021] = {id=30021,round=3,job=3,type=20,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[30022] = {id=30022,round=3,job=3,type=21,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30023] = {id=30023,round=3,job=3,type=22,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[30024] = {id=30024,round=3,job=3,type=23,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[30025] = {id=30025,round=3,job=3,type=15,param=20,progress=1,reward={{13,1,10},{2501,1,10}}},
	[30026] = {id=30026,round=3,job=3,type=24,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[30027] = {id=30027,round=3,job=3,type=25,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[30028] = {id=30028,round=3,job=3,type=26,param=0,progress=2,reward={{13,1,10},{6511,1,20}}},
	[30029] = {id=30029,round=3,job=3,type=27,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[30030] = {id=30030,round=3,job=3,type=1,param=0,progress=4,reward={{13,1,10},{1,1,20000}}},
	[30031] = {id=30031,round=4,job=3,type=28,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[30032] = {id=30032,round=4,job=3,type=29,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30033] = {id=30033,round=4,job=3,type=30,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30034] = {id=30034,round=4,job=3,type=31,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30035] = {id=30035,round=4,job=3,type=15,param=30,progress=1,reward={{13,1,10},{2501,1,10}}},
	[30036] = {id=30036,round=4,job=3,type=32,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[30037] = {id=30037,round=4,job=3,type=33,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[30038] = {id=30038,round=4,job=3,type=34,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[30039] = {id=30039,round=4,job=3,type=35,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[30040] = {id=30040,round=4,job=3,type=1,param=0,progress=5,reward={{13,1,10},{1,1,20000}}},
	[30041] = {id=30041,round=5,job=3,type=36,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[30042] = {id=30042,round=5,job=3,type=37,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[30043] = {id=30043,round=5,job=3,type=38,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30044] = {id=30044,round=5,job=3,type=23,param=0,progress=8,reward={{13,1,10},{1,1,2000}}},
	[30045] = {id=30045,round=5,job=3,type=15,param=40,progress=3,reward={{13,1,10},{2501,1,10}}},
	[30046] = {id=30046,round=5,job=3,type=44,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[30047] = {id=30047,round=5,job=3,type=42,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[30048] = {id=30048,round=5,job=3,type=25,param=3,progress=1,reward={{13,1,10},{6511,1,20}}},
	[30049] = {id=30049,round=5,job=3,type=43,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[30050] = {id=30050,round=5,job=3,type=1,param=0,progress=6,reward={{13,1,10},{1,1,20000}}},
	[30051] = {id=30051,round=6,job=3,type=36,param=0,progress=5,reward={{13,1,10},{6001,1,20}}},
	[30052] = {id=30052,round=6,job=3,type=45,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[30053] = {id=30053,round=6,job=3,type=14,param=0,progress=5,reward={{13,1,10},{1,1,2000}}},
	[30054] = {id=30054,round=6,job=3,type=46,param=2,progress=5,reward={{13,1,10},{1,1,2000}}},
	[30055] = {id=30055,round=6,job=3,type=15,param=50,progress=3,reward={{13,1,10},{2501,1,10}}},
	[30056] = {id=30056,round=6,job=3,type=47,param=0,progress=20,reward={{13,1,10},{5501,1,20}}},
	[30057] = {id=30057,round=6,job=3,type=39,param=0,progress=5,reward={{13,1,10},{1701,1,10}}},
	[30058] = {id=30058,round=6,job=3,type=40,param=0,progress=5,reward={{13,1,10},{6511,1,20}}},
	[30059] = {id=30059,round=6,job=3,type=41,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[30060] = {id=30060,round=6,job=3,type=1,param=0,progress=7,reward={{13,1,10},{1,1,20000}}},
	[40001] = {id=40001,round=1,job=4,type=1,param=0,progress=2,reward={{13,1,10},{6001,1,20}}},
	[40002] = {id=40002,round=1,job=4,type=2,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[40003] = {id=40003,round=1,job=4,type=3,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[40004] = {id=40004,round=1,job=4,type=4,param=0,progress=10,reward={{13,1,10},{1,1,2000}}},
	[40005] = {id=40005,round=1,job=4,type=5,param=0,progress=1,reward={{13,1,10},{2501,1,10}}},
	[40006] = {id=40006,round=1,job=4,type=6,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[40007] = {id=40007,round=1,job=4,type=7,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[40008] = {id=40008,round=1,job=4,type=8,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[40009] = {id=40009,round=1,job=4,type=9,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[40010] = {id=40010,round=1,job=4,type=10,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[40011] = {id=40011,round=2,job=4,type=1,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[40012] = {id=40012,round=2,job=4,type=11,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40013] = {id=40013,round=2,job=4,type=12,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40014] = {id=40014,round=2,job=4,type=13,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[40015] = {id=40015,round=2,job=4,type=14,param=0,progress=2,reward={{13,1,10},{2501,1,10}}},
	[40016] = {id=40016,round=2,job=4,type=15,param=1,progress=1,reward={{13,1,10},{5501,1,20}}},
	[40017] = {id=40017,round=2,job=4,type=16,param=0,progress=3,reward={{13,1,10},{1701,1,10}}},
	[40018] = {id=40018,round=2,job=4,type=17,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[40019] = {id=40019,round=2,job=4,type=18,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[40020] = {id=40020,round=2,job=4,type=19,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[40021] = {id=40021,round=3,job=4,type=20,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[40022] = {id=40022,round=3,job=4,type=21,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40023] = {id=40023,round=3,job=4,type=22,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[40024] = {id=40024,round=3,job=4,type=23,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[40025] = {id=40025,round=3,job=4,type=15,param=20,progress=1,reward={{13,1,10},{2501,1,10}}},
	[40026] = {id=40026,round=3,job=4,type=24,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[40027] = {id=40027,round=3,job=4,type=25,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[40028] = {id=40028,round=3,job=4,type=26,param=0,progress=2,reward={{13,1,10},{6511,1,20}}},
	[40029] = {id=40029,round=3,job=4,type=27,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[40030] = {id=40030,round=3,job=4,type=1,param=0,progress=4,reward={{13,1,10},{1,1,20000}}},
	[40031] = {id=40031,round=4,job=4,type=28,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[40032] = {id=40032,round=4,job=4,type=29,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40033] = {id=40033,round=4,job=4,type=30,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40034] = {id=40034,round=4,job=4,type=31,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40035] = {id=40035,round=4,job=4,type=15,param=30,progress=1,reward={{13,1,10},{2501,1,10}}},
	[40036] = {id=40036,round=4,job=4,type=32,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[40037] = {id=40037,round=4,job=4,type=33,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[40038] = {id=40038,round=4,job=4,type=34,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[40039] = {id=40039,round=4,job=4,type=35,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[40040] = {id=40040,round=4,job=4,type=1,param=0,progress=5,reward={{13,1,10},{1,1,20000}}},
	[40041] = {id=40041,round=5,job=4,type=36,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[40042] = {id=40042,round=5,job=4,type=37,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[40043] = {id=40043,round=5,job=4,type=38,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40044] = {id=40044,round=5,job=4,type=23,param=0,progress=8,reward={{13,1,10},{1,1,2000}}},
	[40045] = {id=40045,round=5,job=4,type=15,param=40,progress=3,reward={{13,1,10},{2501,1,10}}},
	[40046] = {id=40046,round=5,job=4,type=44,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[40047] = {id=40047,round=5,job=4,type=42,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[40048] = {id=40048,round=5,job=4,type=25,param=3,progress=1,reward={{13,1,10},{6511,1,20}}},
	[40049] = {id=40049,round=5,job=4,type=43,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[40050] = {id=40050,round=5,job=4,type=1,param=0,progress=6,reward={{13,1,10},{1,1,20000}}},
	[40051] = {id=40051,round=6,job=4,type=36,param=0,progress=5,reward={{13,1,10},{6001,1,20}}},
	[40052] = {id=40052,round=6,job=4,type=45,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[40053] = {id=40053,round=6,job=4,type=14,param=0,progress=5,reward={{13,1,10},{1,1,2000}}},
	[40054] = {id=40054,round=6,job=4,type=46,param=2,progress=5,reward={{13,1,10},{1,1,2000}}},
	[40055] = {id=40055,round=6,job=4,type=15,param=50,progress=3,reward={{13,1,10},{2501,1,10}}},
	[40056] = {id=40056,round=6,job=4,type=47,param=0,progress=20,reward={{13,1,10},{5501,1,20}}},
	[40057] = {id=40057,round=6,job=4,type=39,param=0,progress=5,reward={{13,1,10},{1701,1,10}}},
	[40058] = {id=40058,round=6,job=4,type=40,param=0,progress=5,reward={{13,1,10},{6511,1,20}}},
	[40059] = {id=40059,round=6,job=4,type=41,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[40060] = {id=40060,round=6,job=4,type=1,param=0,progress=7,reward={{13,1,10},{1,1,20000}}},
	[50001] = {id=50001,round=1,job=5,type=1,param=0,progress=2,reward={{13,1,10},{6001,1,20}}},
	[50002] = {id=50002,round=1,job=5,type=2,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[50003] = {id=50003,round=1,job=5,type=3,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[50004] = {id=50004,round=1,job=5,type=4,param=0,progress=10,reward={{13,1,10},{1,1,2000}}},
	[50005] = {id=50005,round=1,job=5,type=5,param=0,progress=1,reward={{13,1,10},{2501,1,10}}},
	[50006] = {id=50006,round=1,job=5,type=6,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[50007] = {id=50007,round=1,job=5,type=7,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[50008] = {id=50008,round=1,job=5,type=8,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[50009] = {id=50009,round=1,job=5,type=9,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[50010] = {id=50010,round=1,job=5,type=10,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[50011] = {id=50011,round=2,job=5,type=1,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[50012] = {id=50012,round=2,job=5,type=11,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50013] = {id=50013,round=2,job=5,type=12,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50014] = {id=50014,round=2,job=5,type=13,param=0,progress=2,reward={{13,1,10},{1,1,2000}}},
	[50015] = {id=50015,round=2,job=5,type=14,param=0,progress=2,reward={{13,1,10},{2501,1,10}}},
	[50016] = {id=50016,round=2,job=5,type=15,param=1,progress=1,reward={{13,1,10},{5501,1,20}}},
	[50017] = {id=50017,round=2,job=5,type=16,param=0,progress=3,reward={{13,1,10},{1701,1,10}}},
	[50018] = {id=50018,round=2,job=5,type=17,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[50019] = {id=50019,round=2,job=5,type=18,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[50020] = {id=50020,round=2,job=5,type=19,param=0,progress=1,reward={{13,1,10},{1,1,20000}}},
	[50021] = {id=50021,round=3,job=5,type=20,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[50022] = {id=50022,round=3,job=5,type=21,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50023] = {id=50023,round=3,job=5,type=22,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[50024] = {id=50024,round=3,job=5,type=23,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[50025] = {id=50025,round=3,job=5,type=15,param=20,progress=1,reward={{13,1,10},{2501,1,10}}},
	[50026] = {id=50026,round=3,job=5,type=24,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[50027] = {id=50027,round=3,job=5,type=25,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[50028] = {id=50028,round=3,job=5,type=26,param=0,progress=2,reward={{13,1,10},{6511,1,20}}},
	[50029] = {id=50029,round=3,job=5,type=27,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[50030] = {id=50030,round=3,job=5,type=1,param=0,progress=4,reward={{13,1,10},{1,1,20000}}},
	[50031] = {id=50031,round=4,job=5,type=28,param=0,progress=1,reward={{13,1,10},{6001,1,20}}},
	[50032] = {id=50032,round=4,job=5,type=29,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50033] = {id=50033,round=4,job=5,type=30,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50034] = {id=50034,round=4,job=5,type=31,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50035] = {id=50035,round=4,job=5,type=15,param=30,progress=1,reward={{13,1,10},{2501,1,10}}},
	[50036] = {id=50036,round=4,job=5,type=32,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[50037] = {id=50037,round=4,job=5,type=33,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[50038] = {id=50038,round=4,job=5,type=34,param=0,progress=1,reward={{13,1,10},{6511,1,20}}},
	[50039] = {id=50039,round=4,job=5,type=35,param=0,progress=1,reward={{13,1,10},{1605,1,20}}},
	[50040] = {id=50040,round=4,job=5,type=1,param=0,progress=5,reward={{13,1,10},{1,1,20000}}},
	[50041] = {id=50041,round=5,job=5,type=36,param=0,progress=3,reward={{13,1,10},{6001,1,20}}},
	[50042] = {id=50042,round=5,job=5,type=37,param=0,progress=3,reward={{13,1,10},{1,1,2000}}},
	[50043] = {id=50043,round=5,job=5,type=38,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50044] = {id=50044,round=5,job=5,type=23,param=0,progress=8,reward={{13,1,10},{1,1,2000}}},
	[50045] = {id=50045,round=5,job=5,type=15,param=40,progress=3,reward={{13,1,10},{2501,1,10}}},
	[50046] = {id=50046,round=5,job=5,type=44,param=0,progress=1,reward={{13,1,10},{5501,1,20}}},
	[50047] = {id=50047,round=5,job=5,type=42,param=0,progress=1,reward={{13,1,10},{1701,1,10}}},
	[50048] = {id=50048,round=5,job=5,type=25,param=3,progress=1,reward={{13,1,10},{6511,1,20}}},
	[50049] = {id=50049,round=5,job=5,type=43,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[50050] = {id=50050,round=5,job=5,type=1,param=0,progress=6,reward={{13,1,10},{1,1,20000}}},
	[50051] = {id=50051,round=6,job=5,type=36,param=0,progress=5,reward={{13,1,10},{6001,1,20}}},
	[50052] = {id=50052,round=6,job=5,type=45,param=0,progress=1,reward={{13,1,10},{1,1,2000}}},
	[50053] = {id=50053,round=6,job=5,type=14,param=0,progress=5,reward={{13,1,10},{1,1,2000}}},
	[50054] = {id=50054,round=6,job=5,type=46,param=2,progress=5,reward={{13,1,10},{1,1,2000}}},
	[50055] = {id=50055,round=6,job=5,type=15,param=50,progress=3,reward={{13,1,10},{2501,1,10}}},
	[50056] = {id=50056,round=6,job=5,type=47,param=0,progress=20,reward={{13,1,10},{5501,1,20}}},
	[50057] = {id=50057,round=6,job=5,type=39,param=0,progress=5,reward={{13,1,10},{1701,1,10}}},
	[50058] = {id=50058,round=6,job=5,type=40,param=0,progress=5,reward={{13,1,10},{6511,1,20}}},
	[50059] = {id=50059,round=6,job=5,type=41,param=0,progress=5,reward={{13,1,10},{1605,1,20}}},
	[50060] = {id=50060,round=6,job=5,type=1,param=0,progress=7,reward={{13,1,10},{1,1,20000}}},
}

return data