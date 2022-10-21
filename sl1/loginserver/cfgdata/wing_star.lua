local data = {
	{job=1,level=1,item={{7080,1,20},{7010,1,1},{7001,1,2}},attr={{31,1,30},{50,1,60},{51,1,30},{53,1,24},{54,1,24}}},
	{job=1,level=2,item={{7080,1,25},{7010,1,1},{7001,1,2}},attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	{job=1,level=3,item={{7080,1,30},{7010,1,1},{7001,1,2}},attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	{job=1,level=4,item={{7080,1,35},{7010,1,1},{7001,1,2}},attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	{job=1,level=5,item={{7080,1,40},{7010,1,1},{7001,1,2}},attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	{job=1,level=6,item={{7081,1,50},{7011,1,2},{7002,1,3}},attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	{job=1,level=7,item={{7081,1,60},{7011,1,2},{7002,1,3}},attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	{job=1,level=8,item={{7081,1,70},{7011,1,2},{7002,1,3}},attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	{job=1,level=9,item={{7081,1,80},{7011,1,2},{7002,1,3}},attr={{31,1,975},{50,1,1950},{51,1,975},{53,1,780},{54,1,780}}},
	{job=1,level=10,item={{7081,1,90},{7011,1,2},{7002,1,3}},attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	{job=1,level=11,item={{7082,1,100},{7012,1,3},{7003,1,4}},attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	{job=1,level=12,item={{7082,1,110},{7012,1,3},{7003,1,4}},attr={{31,1,1425},{50,1,2850},{51,1,1425},{53,1,1140},{54,1,1140}}},
	{job=1,level=13,item={{7082,1,120},{7012,1,3},{7003,1,4}},attr={{31,1,1575},{50,1,3150},{51,1,1575},{53,1,1260},{54,1,1260}}},
	{job=1,level=14,item={{7082,1,130},{7012,1,3},{7003,1,4}},attr={{31,1,1725},{50,1,3450},{51,1,1725},{53,1,1380},{54,1,1380}}},
	{job=1,level=15,item={{7082,1,140},{7012,1,3},{7003,1,4}},attr={{31,1,1875},{50,1,3750},{51,1,1875},{53,1,1500},{54,1,1500}}},
	{job=1,level=16,item={{7083,1,150},{7013,1,4},{7004,1,4}},attr={{31,1,2025},{50,1,4050},{51,1,2025},{53,1,1620},{54,1,1620}}},
	{job=1,level=17,item={{7083,1,160},{7013,1,4},{7004,1,4}},attr={{31,1,2205},{50,1,4410},{51,1,2205},{53,1,1764},{54,1,1764}}},
	{job=1,level=18,item={{7083,1,175},{7013,1,4},{7004,1,4}},attr={{31,1,2385},{50,1,4770},{51,1,2385},{53,1,1908},{54,1,1908}}},
	{job=1,level=19,item={{7083,1,200},{7013,1,4},{7004,1,4}},attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	{job=1,level=20,item={{7083,1,225},{7013,1,4},{7004,1,4}},attr={{31,1,2790},{50,1,5580},{51,1,2790},{53,1,2232},{54,1,2232}}},
	{job=1,level=21,item={{7084,1,300},{7014,1,5},{7005,1,5}},attr={{31,1,3000},{50,1,6000},{51,1,3000},{53,1,2400},{54,1,2400}}},
	{job=1,level=22,item={{7084,1,400},{7014,1,6},{7005,1,6}},attr={{31,1,3240},{50,1,6480},{51,1,3240},{53,1,2592},{54,1,2592}}},
	{job=1,level=23,item={{7084,1,500},{7014,1,7},{7005,1,7}},attr={{31,1,3480},{50,1,6960},{51,1,3480},{53,1,2784},{54,1,2784}}},
	{job=1,level=24,item={{7084,1,750},{7014,1,12},{7005,1,12}},attr={{31,1,3870},{50,1,7740},{51,1,3870},{53,1,3096},{54,1,3096}}},
	{job=1,level=25,item={{7084,1,1000},{7014,1,20},{7005,1,20}},attr={{31,1,4275},{50,1,8550},{51,1,4275},{53,1,3420},{54,1,3420}}},
	{job=1,level=26,item={{7085,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,5137},{50,1,10275},{51,1,5137},{53,1,4110},{54,1,4110}}},
	{job=1,level=27,item={{7085,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,6180},{50,1,12360},{51,1,6180},{53,1,4944},{54,1,4944}}},
	{job=1,level=28,item={{7085,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,8040},{50,1,16080},{51,1,8040},{53,1,6432},{54,1,6432}}},
	{job=1,level=29,item={{7085,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	{job=1,level=30,item={{7085,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,22500},{50,1,45000},{51,1,22500},{53,1,18000},{54,1,18000}}},
	{job=2,level=1,item={{7030,1,20},{7010,1,1},{7001,1,2}},attr={{31,1,30},{50,1,60},{51,1,30},{53,1,24},{54,1,24}}},
	{job=2,level=2,item={{7030,1,25},{7010,1,1},{7001,1,2}},attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	{job=2,level=3,item={{7030,1,30},{7010,1,1},{7001,1,2}},attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	{job=2,level=4,item={{7030,1,35},{7010,1,1},{7001,1,2}},attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	{job=2,level=5,item={{7030,1,40},{7010,1,1},{7001,1,2}},attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	{job=2,level=6,item={{7031,1,50},{7011,1,2},{7002,1,3}},attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	{job=2,level=7,item={{7031,1,60},{7011,1,2},{7002,1,3}},attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	{job=2,level=8,item={{7031,1,70},{7011,1,2},{7002,1,3}},attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	{job=2,level=9,item={{7031,1,80},{7011,1,2},{7002,1,3}},attr={{31,1,975},{50,1,1950},{51,1,975},{53,1,780},{54,1,780}}},
	{job=2,level=10,item={{7031,1,90},{7011,1,2},{7002,1,3}},attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	{job=2,level=11,item={{7032,1,100},{7012,1,3},{7003,1,4}},attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	{job=2,level=12,item={{7032,1,110},{7012,1,3},{7003,1,4}},attr={{31,1,1425},{50,1,2850},{51,1,1425},{53,1,1140},{54,1,1140}}},
	{job=2,level=13,item={{7032,1,120},{7012,1,3},{7003,1,4}},attr={{31,1,1575},{50,1,3150},{51,1,1575},{53,1,1260},{54,1,1260}}},
	{job=2,level=14,item={{7032,1,130},{7012,1,3},{7003,1,4}},attr={{31,1,1725},{50,1,3450},{51,1,1725},{53,1,1380},{54,1,1380}}},
	{job=2,level=15,item={{7032,1,140},{7012,1,3},{7003,1,4}},attr={{31,1,1875},{50,1,3750},{51,1,1875},{53,1,1500},{54,1,1500}}},
	{job=2,level=16,item={{7033,1,150},{7013,1,4},{7004,1,4}},attr={{31,1,2025},{50,1,4050},{51,1,2025},{53,1,1620},{54,1,1620}}},
	{job=2,level=17,item={{7033,1,160},{7013,1,4},{7004,1,4}},attr={{31,1,2205},{50,1,4410},{51,1,2205},{53,1,1764},{54,1,1764}}},
	{job=2,level=18,item={{7033,1,175},{7013,1,4},{7004,1,4}},attr={{31,1,2385},{50,1,4770},{51,1,2385},{53,1,1908},{54,1,1908}}},
	{job=2,level=19,item={{7033,1,200},{7013,1,4},{7004,1,4}},attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	{job=2,level=20,item={{7033,1,225},{7013,1,4},{7004,1,4}},attr={{31,1,2790},{50,1,5580},{51,1,2790},{53,1,2232},{54,1,2232}}},
	{job=2,level=21,item={{7034,1,300},{7014,1,5},{7005,1,5}},attr={{31,1,3000},{50,1,6000},{51,1,3000},{53,1,2400},{54,1,2400}}},
	{job=2,level=22,item={{7034,1,400},{7014,1,6},{7005,1,6}},attr={{31,1,3240},{50,1,6480},{51,1,3240},{53,1,2592},{54,1,2592}}},
	{job=2,level=23,item={{7034,1,500},{7014,1,7},{7005,1,7}},attr={{31,1,3480},{50,1,6960},{51,1,3480},{53,1,2784},{54,1,2784}}},
	{job=2,level=24,item={{7034,1,750},{7014,1,12},{7005,1,12}},attr={{31,1,3870},{50,1,7740},{51,1,3870},{53,1,3096},{54,1,3096}}},
	{job=2,level=25,item={{7034,1,1000},{7014,1,20},{7005,1,20}},attr={{31,1,4275},{50,1,8550},{51,1,4275},{53,1,3420},{54,1,3420}}},
	{job=2,level=26,item={{7035,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,5137},{50,1,10275},{51,1,5137},{53,1,4110},{54,1,4110}}},
	{job=2,level=27,item={{7035,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,6180},{50,1,12360},{51,1,6180},{53,1,4944},{54,1,4944}}},
	{job=2,level=28,item={{7035,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,8040},{50,1,16080},{51,1,8040},{53,1,6432},{54,1,6432}}},
	{job=2,level=29,item={{7035,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	{job=2,level=30,item={{7035,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,22500},{50,1,45000},{51,1,22500},{53,1,18000},{54,1,18000}}},
	{job=3,level=1,item={{7090,1,20},{7010,1,1},{7001,1,2}},attr={{31,1,30},{50,1,60},{51,1,30},{53,1,24},{54,1,24}}},
	{job=3,level=2,item={{7090,1,25},{7010,1,1},{7001,1,2}},attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	{job=3,level=3,item={{7090,1,30},{7010,1,1},{7001,1,2}},attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	{job=3,level=4,item={{7090,1,35},{7010,1,1},{7001,1,2}},attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	{job=3,level=5,item={{7090,1,40},{7010,1,1},{7001,1,2}},attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	{job=3,level=6,item={{7091,1,50},{7011,1,2},{7002,1,3}},attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	{job=3,level=7,item={{7091,1,60},{7011,1,2},{7002,1,3}},attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	{job=3,level=8,item={{7091,1,70},{7011,1,2},{7002,1,3}},attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	{job=3,level=9,item={{7091,1,80},{7011,1,2},{7002,1,3}},attr={{31,1,975},{50,1,1950},{51,1,975},{53,1,780},{54,1,780}}},
	{job=3,level=10,item={{7091,1,90},{7011,1,2},{7002,1,3}},attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	{job=3,level=11,item={{7092,1,100},{7012,1,3},{7003,1,4}},attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	{job=3,level=12,item={{7092,1,110},{7012,1,3},{7003,1,4}},attr={{31,1,1425},{50,1,2850},{51,1,1425},{53,1,1140},{54,1,1140}}},
	{job=3,level=13,item={{7092,1,120},{7012,1,3},{7003,1,4}},attr={{31,1,1575},{50,1,3150},{51,1,1575},{53,1,1260},{54,1,1260}}},
	{job=3,level=14,item={{7092,1,130},{7012,1,3},{7003,1,4}},attr={{31,1,1725},{50,1,3450},{51,1,1725},{53,1,1380},{54,1,1380}}},
	{job=3,level=15,item={{7092,1,140},{7012,1,3},{7003,1,4}},attr={{31,1,1875},{50,1,3750},{51,1,1875},{53,1,1500},{54,1,1500}}},
	{job=3,level=16,item={{7093,1,150},{7013,1,4},{7004,1,4}},attr={{31,1,2025},{50,1,4050},{51,1,2025},{53,1,1620},{54,1,1620}}},
	{job=3,level=17,item={{7093,1,160},{7013,1,4},{7004,1,4}},attr={{31,1,2205},{50,1,4410},{51,1,2205},{53,1,1764},{54,1,1764}}},
	{job=3,level=18,item={{7093,1,175},{7013,1,4},{7004,1,4}},attr={{31,1,2385},{50,1,4770},{51,1,2385},{53,1,1908},{54,1,1908}}},
	{job=3,level=19,item={{7093,1,200},{7013,1,4},{7004,1,4}},attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	{job=3,level=20,item={{7093,1,225},{7013,1,4},{7004,1,4}},attr={{31,1,2790},{50,1,5580},{51,1,2790},{53,1,2232},{54,1,2232}}},
	{job=3,level=21,item={{7094,1,300},{7014,1,5},{7005,1,5}},attr={{31,1,3000},{50,1,6000},{51,1,3000},{53,1,2400},{54,1,2400}}},
	{job=3,level=22,item={{7094,1,400},{7014,1,6},{7005,1,6}},attr={{31,1,3240},{50,1,6480},{51,1,3240},{53,1,2592},{54,1,2592}}},
	{job=3,level=23,item={{7094,1,500},{7014,1,7},{7005,1,7}},attr={{31,1,3480},{50,1,6960},{51,1,3480},{53,1,2784},{54,1,2784}}},
	{job=3,level=24,item={{7094,1,750},{7014,1,12},{7005,1,12}},attr={{31,1,3870},{50,1,7740},{51,1,3870},{53,1,3096},{54,1,3096}}},
	{job=3,level=25,item={{7094,1,1000},{7014,1,20},{7005,1,20}},attr={{31,1,4275},{50,1,8550},{51,1,4275},{53,1,3420},{54,1,3420}}},
	{job=3,level=26,item={{7095,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,5137},{50,1,10275},{51,1,5137},{53,1,4110},{54,1,4110}}},
	{job=3,level=27,item={{7095,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,6180},{50,1,12360},{51,1,6180},{53,1,4944},{54,1,4944}}},
	{job=3,level=28,item={{7095,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,8040},{50,1,16080},{51,1,8040},{53,1,6432},{54,1,6432}}},
	{job=3,level=29,item={{7095,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	{job=3,level=30,item={{7095,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,22500},{50,1,45000},{51,1,22500},{53,1,18000},{54,1,18000}}},
	{job=4,level=1,item={{7020,1,20},{7010,1,1},{7001,1,2}},attr={{31,1,30},{50,1,60},{51,1,30},{53,1,24},{54,1,24}}},
	{job=4,level=2,item={{7020,1,25},{7010,1,1},{7001,1,2}},attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	{job=4,level=3,item={{7020,1,30},{7010,1,1},{7001,1,2}},attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	{job=4,level=4,item={{7020,1,35},{7010,1,1},{7001,1,2}},attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	{job=4,level=5,item={{7020,1,40},{7010,1,1},{7001,1,2}},attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	{job=4,level=6,item={{7021,1,50},{7011,1,2},{7002,1,3}},attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	{job=4,level=7,item={{7021,1,60},{7011,1,2},{7002,1,3}},attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	{job=4,level=8,item={{7021,1,70},{7011,1,2},{7002,1,3}},attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	{job=4,level=9,item={{7021,1,80},{7011,1,2},{7002,1,3}},attr={{31,1,975},{50,1,1950},{51,1,975},{53,1,780},{54,1,780}}},
	{job=4,level=10,item={{7021,1,90},{7011,1,2},{7002,1,3}},attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	{job=4,level=11,item={{7022,1,100},{7012,1,3},{7003,1,4}},attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	{job=4,level=12,item={{7022,1,110},{7012,1,3},{7003,1,4}},attr={{31,1,1425},{50,1,2850},{51,1,1425},{53,1,1140},{54,1,1140}}},
	{job=4,level=13,item={{7022,1,120},{7012,1,3},{7003,1,4}},attr={{31,1,1575},{50,1,3150},{51,1,1575},{53,1,1260},{54,1,1260}}},
	{job=4,level=14,item={{7022,1,130},{7012,1,3},{7003,1,4}},attr={{31,1,1725},{50,1,3450},{51,1,1725},{53,1,1380},{54,1,1380}}},
	{job=4,level=15,item={{7022,1,140},{7012,1,3},{7003,1,4}},attr={{31,1,1875},{50,1,3750},{51,1,1875},{53,1,1500},{54,1,1500}}},
	{job=4,level=16,item={{7023,1,150},{7013,1,4},{7004,1,4}},attr={{31,1,2025},{50,1,4050},{51,1,2025},{53,1,1620},{54,1,1620}}},
	{job=4,level=17,item={{7023,1,160},{7013,1,4},{7004,1,4}},attr={{31,1,2205},{50,1,4410},{51,1,2205},{53,1,1764},{54,1,1764}}},
	{job=4,level=18,item={{7023,1,175},{7013,1,4},{7004,1,4}},attr={{31,1,2385},{50,1,4770},{51,1,2385},{53,1,1908},{54,1,1908}}},
	{job=4,level=19,item={{7023,1,200},{7013,1,4},{7004,1,4}},attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	{job=4,level=20,item={{7023,1,225},{7013,1,4},{7004,1,4}},attr={{31,1,2790},{50,1,5580},{51,1,2790},{53,1,2232},{54,1,2232}}},
	{job=4,level=21,item={{7024,1,300},{7014,1,5},{7005,1,5}},attr={{31,1,3000},{50,1,6000},{51,1,3000},{53,1,2400},{54,1,2400}}},
	{job=4,level=22,item={{7024,1,400},{7014,1,6},{7005,1,6}},attr={{31,1,3240},{50,1,6480},{51,1,3240},{53,1,2592},{54,1,2592}}},
	{job=4,level=23,item={{7024,1,500},{7014,1,7},{7005,1,7}},attr={{31,1,3480},{50,1,6960},{51,1,3480},{53,1,2784},{54,1,2784}}},
	{job=4,level=24,item={{7024,1,750},{7014,1,12},{7005,1,12}},attr={{31,1,3870},{50,1,7740},{51,1,3870},{53,1,3096},{54,1,3096}}},
	{job=4,level=25,item={{7024,1,1000},{7014,1,20},{7005,1,20}},attr={{31,1,4275},{50,1,8550},{51,1,4275},{53,1,3420},{54,1,3420}}},
	{job=4,level=26,item={{7025,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,5137},{50,1,10275},{51,1,5137},{53,1,4110},{54,1,4110}}},
	{job=4,level=27,item={{7025,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,6180},{50,1,12360},{51,1,6180},{53,1,4944},{54,1,4944}}},
	{job=4,level=28,item={{7025,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,8040},{50,1,16080},{51,1,8040},{53,1,6432},{54,1,6432}}},
	{job=4,level=29,item={{7025,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	{job=4,level=30,item={{7025,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,22500},{50,1,45000},{51,1,22500},{53,1,18000},{54,1,18000}}},
	{job=5,level=1,item={{7040,1,20},{7010,1,1},{7001,1,2}},attr={{31,1,30},{50,1,60},{51,1,30},{53,1,24},{54,1,24}}},
	{job=5,level=2,item={{7040,1,25},{7010,1,1},{7001,1,2}},attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	{job=5,level=3,item={{7040,1,30},{7010,1,1},{7001,1,2}},attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	{job=5,level=4,item={{7040,1,35},{7010,1,1},{7001,1,2}},attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	{job=5,level=5,item={{7040,1,40},{7010,1,1},{7001,1,2}},attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	{job=5,level=6,item={{7041,1,50},{7011,1,2},{7002,1,3}},attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	{job=5,level=7,item={{7041,1,60},{7011,1,2},{7002,1,3}},attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	{job=5,level=8,item={{7041,1,70},{7011,1,2},{7002,1,3}},attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	{job=5,level=9,item={{7041,1,80},{7011,1,2},{7002,1,3}},attr={{31,1,975},{50,1,1950},{51,1,975},{53,1,780},{54,1,780}}},
	{job=5,level=10,item={{7041,1,90},{7011,1,2},{7002,1,3}},attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	{job=5,level=11,item={{7042,1,100},{7012,1,3},{7003,1,4}},attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	{job=5,level=12,item={{7042,1,110},{7012,1,3},{7003,1,4}},attr={{31,1,1425},{50,1,2850},{51,1,1425},{53,1,1140},{54,1,1140}}},
	{job=5,level=13,item={{7042,1,120},{7012,1,3},{7003,1,4}},attr={{31,1,1575},{50,1,3150},{51,1,1575},{53,1,1260},{54,1,1260}}},
	{job=5,level=14,item={{7042,1,130},{7012,1,3},{7003,1,4}},attr={{31,1,1725},{50,1,3450},{51,1,1725},{53,1,1380},{54,1,1380}}},
	{job=5,level=15,item={{7042,1,140},{7012,1,3},{7003,1,4}},attr={{31,1,1875},{50,1,3750},{51,1,1875},{53,1,1500},{54,1,1500}}},
	{job=5,level=16,item={{7043,1,150},{7013,1,4},{7004,1,4}},attr={{31,1,2025},{50,1,4050},{51,1,2025},{53,1,1620},{54,1,1620}}},
	{job=5,level=17,item={{7043,1,160},{7013,1,4},{7004,1,4}},attr={{31,1,2205},{50,1,4410},{51,1,2205},{53,1,1764},{54,1,1764}}},
	{job=5,level=18,item={{7043,1,175},{7013,1,4},{7004,1,4}},attr={{31,1,2385},{50,1,4770},{51,1,2385},{53,1,1908},{54,1,1908}}},
	{job=5,level=19,item={{7043,1,200},{7013,1,4},{7004,1,4}},attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	{job=5,level=20,item={{7043,1,225},{7013,1,4},{7004,1,4}},attr={{31,1,2790},{50,1,5580},{51,1,2790},{53,1,2232},{54,1,2232}}},
	{job=5,level=21,item={{7044,1,300},{7014,1,5},{7005,1,5}},attr={{31,1,3000},{50,1,6000},{51,1,3000},{53,1,2400},{54,1,2400}}},
	{job=5,level=22,item={{7044,1,400},{7014,1,6},{7005,1,6}},attr={{31,1,3240},{50,1,6480},{51,1,3240},{53,1,2592},{54,1,2592}}},
	{job=5,level=23,item={{7044,1,500},{7014,1,7},{7005,1,7}},attr={{31,1,3480},{50,1,6960},{51,1,3480},{53,1,2784},{54,1,2784}}},
	{job=5,level=24,item={{7044,1,750},{7014,1,12},{7005,1,12}},attr={{31,1,3870},{50,1,7740},{51,1,3870},{53,1,3096},{54,1,3096}}},
	{job=5,level=25,item={{7044,1,1000},{7014,1,20},{7005,1,20}},attr={{31,1,4275},{50,1,8550},{51,1,4275},{53,1,3420},{54,1,3420}}},
	{job=5,level=26,item={{7045,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,5137},{50,1,10275},{51,1,5137},{53,1,4110},{54,1,4110}}},
	{job=5,level=27,item={{7045,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,6180},{50,1,12360},{51,1,6180},{53,1,4944},{54,1,4944}}},
	{job=5,level=28,item={{7045,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,8040},{50,1,16080},{51,1,8040},{53,1,6432},{54,1,6432}}},
	{job=5,level=29,item={{7045,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	{job=5,level=30,item={{7045,1,1250},{7015,1,10},{7006,1,10}},attr={{31,1,22500},{50,1,45000},{51,1,22500},{53,1,18000},{54,1,18000}}},
}

return data
