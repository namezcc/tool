local data = {
	{job=1,level=0,item={},attr={}},
	{job=1,level=1,item={{6201,1,4},{6530,1,1},{6540,1,2}},attr={{50,1,120},{51,1,60},{52,1,60},{53,1,48},{54,1,48}}},
	{job=1,level=2,item={{6201,1,5},{6530,1,1},{6540,1,2}},attr={{50,1,240},{51,1,120},{52,1,120},{53,1,96},{54,1,96}}},
	{job=1,level=3,item={{6201,1,6},{6530,1,1},{6540,1,2}},attr={{50,1,360},{51,1,180},{52,1,180},{53,1,144},{54,1,144}}},
	{job=1,level=4,item={{6201,1,7},{6530,1,1},{6540,1,2}},attr={{50,1,480},{51,1,240},{52,1,240},{53,1,192},{54,1,192}}},
	{job=1,level=5,item={{6201,1,8},{6530,1,1},{6540,1,2}},attr={{50,1,600},{51,1,300},{52,1,300},{53,1,240},{54,1,240}}},
	{job=1,level=6,item={{6201,1,10},{6531,1,2},{6541,1,3}},attr={{50,1,840},{51,1,420},{52,1,420},{53,1,336},{54,1,336}}},
	{job=1,level=7,item={{6201,1,12},{6531,1,2},{6541,1,3}},attr={{50,1,1080},{51,1,540},{52,1,540},{53,1,432},{54,1,432}}},
	{job=1,level=8,item={{6201,1,14},{6531,1,2},{6541,1,3}},attr={{50,1,1320},{51,1,660},{52,1,660},{53,1,528},{54,1,528}}},
	{job=1,level=9,item={{6201,1,16},{6531,1,2},{6541,1,3}},attr={{50,1,1560},{51,1,780},{52,1,780},{53,1,624},{54,1,624}}},
	{job=1,level=10,item={{6201,1,18},{6531,1,2},{6541,1,3}},attr={{50,1,1800},{51,1,900},{52,1,900},{53,1,720},{54,1,720}}},
	{job=1,level=11,item={{6201,1,20},{6532,1,3},{6542,1,4}},attr={{50,1,2250},{51,1,1125},{52,1,1125},{53,1,900},{54,1,900}}},
	{job=1,level=12,item={{6201,1,22},{6532,1,3},{6542,1,4}},attr={{50,1,2700},{51,1,1350},{52,1,1350},{53,1,1080},{54,1,1080}}},
	{job=1,level=13,item={{6201,1,24},{6532,1,3},{6542,1,4}},attr={{50,1,3150},{51,1,1575},{52,1,1575},{53,1,1260},{54,1,1260}}},
	{job=1,level=14,item={{6201,1,26},{6532,1,3},{6542,1,4}},attr={{50,1,3600},{51,1,1800},{52,1,1800},{53,1,1440},{54,1,1440}}},
	{job=1,level=15,item={{6201,1,28},{6532,1,3},{6542,1,4}},attr={{50,1,4050},{51,1,2025},{52,1,2025},{53,1,1620},{54,1,1620}}},
	{job=1,level=16,item={{6201,1,30},{6533,1,4},{6543,1,4}},attr={{50,1,4590},{51,1,2295},{52,1,2295},{53,1,1836},{54,1,1836}}},
	{job=1,level=17,item={{6201,1,32},{6533,1,4},{6543,1,4}},attr={{50,1,5160},{51,1,2580},{52,1,2580},{53,1,2064},{54,1,2064}}},
	{job=1,level=18,item={{6201,1,35},{6533,1,4},{6543,1,4}},attr={{50,1,5790},{51,1,2895},{52,1,2895},{53,1,2316},{54,1,2316}}},
	{job=1,level=19,item={{6201,1,40},{6533,1,4},{6543,1,4}},attr={{50,1,6480},{51,1,3240},{52,1,3240},{53,1,2592},{54,1,2592}}},
	{job=1,level=20,item={{6201,1,50},{6533,1,4},{6543,1,4}},attr={{50,1,7200},{51,1,3600},{52,1,3600},{53,1,2880},{54,1,2880}}},
	{job=1,level=21,item={{6201,1,60},{6534,1,5},{6544,1,5}},attr={{50,1,8550},{51,1,4275},{52,1,4275},{53,1,3420},{54,1,3420}}},
	{job=1,level=22,item={{6201,1,80},{6534,1,6},{6544,1,6}},attr={{50,1,10275},{51,1,5137},{52,1,5137},{53,1,4110},{54,1,4110}}},
	{job=1,level=23,item={{6201,1,100},{6534,1,7},{6544,1,7}},attr={{50,1,12360},{51,1,6180},{52,1,6180},{53,1,4944},{54,1,4944}}},
	{job=1,level=24,item={{6201,1,150},{6534,1,12},{6544,1,12}},attr={{50,1,16080},{51,1,8040},{52,1,8040},{53,1,6432},{54,1,6432}}},
	{job=1,level=25,item={{6201,1,200},{6534,1,20},{6544,1,20}},attr={{50,1,22500},{51,1,11250},{52,1,11250},{53,1,9000},{54,1,9000}}},
	{job=1,level=26,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,27000},{51,1,13500},{52,1,13500},{53,1,10800},{54,1,10800}}},
	{job=1,level=27,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,31500},{51,1,15750},{52,1,15750},{53,1,12600},{54,1,12600}}},
	{job=1,level=28,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,36000},{51,1,18000},{52,1,18000},{53,1,14400},{54,1,14400}}},
	{job=1,level=29,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,40500},{51,1,20250},{52,1,20250},{53,1,16200},{54,1,16200}}},
	{job=1,level=30,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,45000},{51,1,22500},{52,1,22500},{53,1,18000},{54,1,18000}}},
	{job=2,level=0,item={},attr={}},
	{job=2,level=1,item={{6201,1,4},{6530,1,1},{6540,1,2}},attr={{50,1,120},{51,1,60},{52,1,60},{53,1,48},{54,1,48}}},
	{job=2,level=2,item={{6201,1,5},{6530,1,1},{6540,1,2}},attr={{50,1,240},{51,1,120},{52,1,120},{53,1,96},{54,1,96}}},
	{job=2,level=3,item={{6201,1,6},{6530,1,1},{6540,1,2}},attr={{50,1,360},{51,1,180},{52,1,180},{53,1,144},{54,1,144}}},
	{job=2,level=4,item={{6201,1,7},{6530,1,1},{6540,1,2}},attr={{50,1,480},{51,1,240},{52,1,240},{53,1,192},{54,1,192}}},
	{job=2,level=5,item={{6201,1,8},{6530,1,1},{6540,1,2}},attr={{50,1,600},{51,1,300},{52,1,300},{53,1,240},{54,1,240}}},
	{job=2,level=6,item={{6201,1,10},{6531,1,2},{6541,1,3}},attr={{50,1,840},{51,1,420},{52,1,420},{53,1,336},{54,1,336}}},
	{job=2,level=7,item={{6201,1,12},{6531,1,2},{6541,1,3}},attr={{50,1,1080},{51,1,540},{52,1,540},{53,1,432},{54,1,432}}},
	{job=2,level=8,item={{6201,1,14},{6531,1,2},{6541,1,3}},attr={{50,1,1320},{51,1,660},{52,1,660},{53,1,528},{54,1,528}}},
	{job=2,level=9,item={{6201,1,16},{6531,1,2},{6541,1,3}},attr={{50,1,1560},{51,1,780},{52,1,780},{53,1,624},{54,1,624}}},
	{job=2,level=10,item={{6201,1,18},{6531,1,2},{6541,1,3}},attr={{50,1,1800},{51,1,900},{52,1,900},{53,1,720},{54,1,720}}},
	{job=2,level=11,item={{6201,1,20},{6532,1,3},{6542,1,4}},attr={{50,1,2250},{51,1,1125},{52,1,1125},{53,1,900},{54,1,900}}},
	{job=2,level=12,item={{6201,1,22},{6532,1,3},{6542,1,4}},attr={{50,1,2700},{51,1,1350},{52,1,1350},{53,1,1080},{54,1,1080}}},
	{job=2,level=13,item={{6201,1,24},{6532,1,3},{6542,1,4}},attr={{50,1,3150},{51,1,1575},{52,1,1575},{53,1,1260},{54,1,1260}}},
	{job=2,level=14,item={{6201,1,26},{6532,1,3},{6542,1,4}},attr={{50,1,3600},{51,1,1800},{52,1,1800},{53,1,1440},{54,1,1440}}},
	{job=2,level=15,item={{6201,1,28},{6532,1,3},{6542,1,4}},attr={{50,1,4050},{51,1,2025},{52,1,2025},{53,1,1620},{54,1,1620}}},
	{job=2,level=16,item={{6201,1,30},{6533,1,4},{6543,1,4}},attr={{50,1,4590},{51,1,2295},{52,1,2295},{53,1,1836},{54,1,1836}}},
	{job=2,level=17,item={{6201,1,32},{6533,1,4},{6543,1,4}},attr={{50,1,5160},{51,1,2580},{52,1,2580},{53,1,2064},{54,1,2064}}},
	{job=2,level=18,item={{6201,1,35},{6533,1,4},{6543,1,4}},attr={{50,1,5790},{51,1,2895},{52,1,2895},{53,1,2316},{54,1,2316}}},
	{job=2,level=19,item={{6201,1,40},{6533,1,4},{6543,1,4}},attr={{50,1,6480},{51,1,3240},{52,1,3240},{53,1,2592},{54,1,2592}}},
	{job=2,level=20,item={{6201,1,50},{6533,1,4},{6543,1,4}},attr={{50,1,7200},{51,1,3600},{52,1,3600},{53,1,2880},{54,1,2880}}},
	{job=2,level=21,item={{6201,1,60},{6534,1,5},{6544,1,5}},attr={{50,1,8550},{51,1,4275},{52,1,4275},{53,1,3420},{54,1,3420}}},
	{job=2,level=22,item={{6201,1,80},{6534,1,6},{6544,1,6}},attr={{50,1,10275},{51,1,5137},{52,1,5137},{53,1,4110},{54,1,4110}}},
	{job=2,level=23,item={{6201,1,100},{6534,1,7},{6544,1,7}},attr={{50,1,12360},{51,1,6180},{52,1,6180},{53,1,4944},{54,1,4944}}},
	{job=2,level=24,item={{6201,1,150},{6534,1,12},{6544,1,12}},attr={{50,1,16080},{51,1,8040},{52,1,8040},{53,1,6432},{54,1,6432}}},
	{job=2,level=25,item={{6201,1,200},{6534,1,20},{6544,1,20}},attr={{50,1,22500},{51,1,11250},{52,1,11250},{53,1,9000},{54,1,9000}}},
	{job=2,level=26,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,27000},{51,1,13500},{52,1,13500},{53,1,10800},{54,1,10800}}},
	{job=2,level=27,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,31500},{51,1,15750},{52,1,15750},{53,1,12600},{54,1,12600}}},
	{job=2,level=28,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,36000},{51,1,18000},{52,1,18000},{53,1,14400},{54,1,14400}}},
	{job=2,level=29,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,40500},{51,1,20250},{52,1,20250},{53,1,16200},{54,1,16200}}},
	{job=2,level=30,item={{6201,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,45000},{51,1,22500},{52,1,22500},{53,1,18000},{54,1,18000}}},
	{job=3,level=0,item={},attr={}},
	{job=3,level=1,item={{6202,1,4},{6530,1,1},{6540,1,2}},attr={{50,1,120},{51,1,60},{52,1,60},{53,1,48},{54,1,48}}},
	{job=3,level=2,item={{6202,1,5},{6530,1,1},{6540,1,2}},attr={{50,1,240},{51,1,120},{52,1,120},{53,1,96},{54,1,96}}},
	{job=3,level=3,item={{6202,1,6},{6530,1,1},{6540,1,2}},attr={{50,1,360},{51,1,180},{52,1,180},{53,1,144},{54,1,144}}},
	{job=3,level=4,item={{6202,1,7},{6530,1,1},{6540,1,2}},attr={{50,1,480},{51,1,240},{52,1,240},{53,1,192},{54,1,192}}},
	{job=3,level=5,item={{6202,1,8},{6530,1,1},{6540,1,2}},attr={{50,1,600},{51,1,300},{52,1,300},{53,1,240},{54,1,240}}},
	{job=3,level=6,item={{6202,1,10},{6531,1,2},{6541,1,3}},attr={{50,1,840},{51,1,420},{52,1,420},{53,1,336},{54,1,336}}},
	{job=3,level=7,item={{6202,1,12},{6531,1,2},{6541,1,3}},attr={{50,1,1080},{51,1,540},{52,1,540},{53,1,432},{54,1,432}}},
	{job=3,level=8,item={{6202,1,14},{6531,1,2},{6541,1,3}},attr={{50,1,1320},{51,1,660},{52,1,660},{53,1,528},{54,1,528}}},
	{job=3,level=9,item={{6202,1,16},{6531,1,2},{6541,1,3}},attr={{50,1,1560},{51,1,780},{52,1,780},{53,1,624},{54,1,624}}},
	{job=3,level=10,item={{6202,1,18},{6531,1,2},{6541,1,3}},attr={{50,1,1800},{51,1,900},{52,1,900},{53,1,720},{54,1,720}}},
	{job=3,level=11,item={{6202,1,20},{6532,1,3},{6542,1,4}},attr={{50,1,2250},{51,1,1125},{52,1,1125},{53,1,900},{54,1,900}}},
	{job=3,level=12,item={{6202,1,22},{6532,1,3},{6542,1,4}},attr={{50,1,2700},{51,1,1350},{52,1,1350},{53,1,1080},{54,1,1080}}},
	{job=3,level=13,item={{6202,1,24},{6532,1,3},{6542,1,4}},attr={{50,1,3150},{51,1,1575},{52,1,1575},{53,1,1260},{54,1,1260}}},
	{job=3,level=14,item={{6202,1,26},{6532,1,3},{6542,1,4}},attr={{50,1,3600},{51,1,1800},{52,1,1800},{53,1,1440},{54,1,1440}}},
	{job=3,level=15,item={{6202,1,28},{6532,1,3},{6542,1,4}},attr={{50,1,4050},{51,1,2025},{52,1,2025},{53,1,1620},{54,1,1620}}},
	{job=3,level=16,item={{6202,1,30},{6533,1,4},{6543,1,4}},attr={{50,1,4590},{51,1,2295},{52,1,2295},{53,1,1836},{54,1,1836}}},
	{job=3,level=17,item={{6202,1,32},{6533,1,4},{6543,1,4}},attr={{50,1,5160},{51,1,2580},{52,1,2580},{53,1,2064},{54,1,2064}}},
	{job=3,level=18,item={{6202,1,35},{6533,1,4},{6543,1,4}},attr={{50,1,5790},{51,1,2895},{52,1,2895},{53,1,2316},{54,1,2316}}},
	{job=3,level=19,item={{6202,1,40},{6533,1,4},{6543,1,4}},attr={{50,1,6480},{51,1,3240},{52,1,3240},{53,1,2592},{54,1,2592}}},
	{job=3,level=20,item={{6202,1,50},{6533,1,4},{6543,1,4}},attr={{50,1,7200},{51,1,3600},{52,1,3600},{53,1,2880},{54,1,2880}}},
	{job=3,level=21,item={{6202,1,60},{6534,1,5},{6544,1,5}},attr={{50,1,8550},{51,1,4275},{52,1,4275},{53,1,3420},{54,1,3420}}},
	{job=3,level=22,item={{6202,1,80},{6534,1,6},{6544,1,6}},attr={{50,1,10275},{51,1,5137},{52,1,5137},{53,1,4110},{54,1,4110}}},
	{job=3,level=23,item={{6202,1,100},{6534,1,7},{6544,1,7}},attr={{50,1,12360},{51,1,6180},{52,1,6180},{53,1,4944},{54,1,4944}}},
	{job=3,level=24,item={{6202,1,150},{6534,1,12},{6544,1,12}},attr={{50,1,16080},{51,1,8040},{52,1,8040},{53,1,6432},{54,1,6432}}},
	{job=3,level=25,item={{6202,1,200},{6534,1,20},{6544,1,20}},attr={{50,1,22500},{51,1,11250},{52,1,11250},{53,1,9000},{54,1,9000}}},
	{job=3,level=26,item={{6202,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,27000},{51,1,13500},{52,1,13500},{53,1,10800},{54,1,10800}}},
	{job=3,level=27,item={{6202,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,31500},{51,1,15750},{52,1,15750},{53,1,12600},{54,1,12600}}},
	{job=3,level=28,item={{6202,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,36000},{51,1,18000},{52,1,18000},{53,1,14400},{54,1,14400}}},
	{job=3,level=29,item={{6202,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,40500},{51,1,20250},{52,1,20250},{53,1,16200},{54,1,16200}}},
	{job=3,level=30,item={{6202,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,45000},{51,1,22500},{52,1,22500},{53,1,18000},{54,1,18000}}},
	{job=4,level=0,item={},attr={}},
	{job=4,level=1,item={{6203,1,4},{6530,1,1},{6540,1,2}},attr={{50,1,120},{51,1,60},{52,1,60},{53,1,48},{54,1,48}}},
	{job=4,level=2,item={{6203,1,5},{6530,1,1},{6540,1,2}},attr={{50,1,240},{51,1,120},{52,1,120},{53,1,96},{54,1,96}}},
	{job=4,level=3,item={{6203,1,6},{6530,1,1},{6540,1,2}},attr={{50,1,360},{51,1,180},{52,1,180},{53,1,144},{54,1,144}}},
	{job=4,level=4,item={{6203,1,7},{6530,1,1},{6540,1,2}},attr={{50,1,480},{51,1,240},{52,1,240},{53,1,192},{54,1,192}}},
	{job=4,level=5,item={{6203,1,8},{6530,1,1},{6540,1,2}},attr={{50,1,600},{51,1,300},{52,1,300},{53,1,240},{54,1,240}}},
	{job=4,level=6,item={{6203,1,10},{6531,1,2},{6541,1,3}},attr={{50,1,840},{51,1,420},{52,1,420},{53,1,336},{54,1,336}}},
	{job=4,level=7,item={{6203,1,12},{6531,1,2},{6541,1,3}},attr={{50,1,1080},{51,1,540},{52,1,540},{53,1,432},{54,1,432}}},
	{job=4,level=8,item={{6203,1,14},{6531,1,2},{6541,1,3}},attr={{50,1,1320},{51,1,660},{52,1,660},{53,1,528},{54,1,528}}},
	{job=4,level=9,item={{6203,1,16},{6531,1,2},{6541,1,3}},attr={{50,1,1560},{51,1,780},{52,1,780},{53,1,624},{54,1,624}}},
	{job=4,level=10,item={{6203,1,18},{6531,1,2},{6541,1,3}},attr={{50,1,1800},{51,1,900},{52,1,900},{53,1,720},{54,1,720}}},
	{job=4,level=11,item={{6203,1,20},{6532,1,3},{6542,1,4}},attr={{50,1,2250},{51,1,1125},{52,1,1125},{53,1,900},{54,1,900}}},
	{job=4,level=12,item={{6203,1,22},{6532,1,3},{6542,1,4}},attr={{50,1,2700},{51,1,1350},{52,1,1350},{53,1,1080},{54,1,1080}}},
	{job=4,level=13,item={{6203,1,24},{6532,1,3},{6542,1,4}},attr={{50,1,3150},{51,1,1575},{52,1,1575},{53,1,1260},{54,1,1260}}},
	{job=4,level=14,item={{6203,1,26},{6532,1,3},{6542,1,4}},attr={{50,1,3600},{51,1,1800},{52,1,1800},{53,1,1440},{54,1,1440}}},
	{job=4,level=15,item={{6203,1,28},{6532,1,3},{6542,1,4}},attr={{50,1,4050},{51,1,2025},{52,1,2025},{53,1,1620},{54,1,1620}}},
	{job=4,level=16,item={{6203,1,30},{6533,1,4},{6543,1,4}},attr={{50,1,4590},{51,1,2295},{52,1,2295},{53,1,1836},{54,1,1836}}},
	{job=4,level=17,item={{6203,1,32},{6533,1,4},{6543,1,4}},attr={{50,1,5160},{51,1,2580},{52,1,2580},{53,1,2064},{54,1,2064}}},
	{job=4,level=18,item={{6203,1,35},{6533,1,4},{6543,1,4}},attr={{50,1,5790},{51,1,2895},{52,1,2895},{53,1,2316},{54,1,2316}}},
	{job=4,level=19,item={{6203,1,40},{6533,1,4},{6543,1,4}},attr={{50,1,6480},{51,1,3240},{52,1,3240},{53,1,2592},{54,1,2592}}},
	{job=4,level=20,item={{6203,1,50},{6533,1,4},{6543,1,4}},attr={{50,1,7200},{51,1,3600},{52,1,3600},{53,1,2880},{54,1,2880}}},
	{job=4,level=21,item={{6203,1,60},{6534,1,5},{6544,1,5}},attr={{50,1,8550},{51,1,4275},{52,1,4275},{53,1,3420},{54,1,3420}}},
	{job=4,level=22,item={{6203,1,80},{6534,1,6},{6544,1,6}},attr={{50,1,10275},{51,1,5137},{52,1,5137},{53,1,4110},{54,1,4110}}},
	{job=4,level=23,item={{6203,1,100},{6534,1,7},{6544,1,7}},attr={{50,1,12360},{51,1,6180},{52,1,6180},{53,1,4944},{54,1,4944}}},
	{job=4,level=24,item={{6203,1,150},{6534,1,12},{6544,1,12}},attr={{50,1,16080},{51,1,8040},{52,1,8040},{53,1,6432},{54,1,6432}}},
	{job=4,level=25,item={{6203,1,200},{6534,1,20},{6544,1,20}},attr={{50,1,22500},{51,1,11250},{52,1,11250},{53,1,9000},{54,1,9000}}},
	{job=4,level=26,item={{6203,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,27000},{51,1,13500},{52,1,13500},{53,1,10800},{54,1,10800}}},
	{job=4,level=27,item={{6203,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,31500},{51,1,15750},{52,1,15750},{53,1,12600},{54,1,12600}}},
	{job=4,level=28,item={{6203,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,36000},{51,1,18000},{52,1,18000},{53,1,14400},{54,1,14400}}},
	{job=4,level=29,item={{6203,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,40500},{51,1,20250},{52,1,20250},{53,1,16200},{54,1,16200}}},
	{job=4,level=30,item={{6203,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,45000},{51,1,22500},{52,1,22500},{53,1,18000},{54,1,18000}}},
	{job=5,level=0,item={},attr={}},
	{job=5,level=1,item={{6204,1,4},{6530,1,1},{6540,1,2}},attr={{50,1,120},{51,1,60},{52,1,60},{53,1,48},{54,1,48}}},
	{job=5,level=2,item={{6204,1,5},{6530,1,1},{6540,1,2}},attr={{50,1,240},{51,1,120},{52,1,120},{53,1,96},{54,1,96}}},
	{job=5,level=3,item={{6204,1,6},{6530,1,1},{6540,1,2}},attr={{50,1,360},{51,1,180},{52,1,180},{53,1,144},{54,1,144}}},
	{job=5,level=4,item={{6204,1,7},{6530,1,1},{6540,1,2}},attr={{50,1,480},{51,1,240},{52,1,240},{53,1,192},{54,1,192}}},
	{job=5,level=5,item={{6204,1,8},{6530,1,1},{6540,1,2}},attr={{50,1,600},{51,1,300},{52,1,300},{53,1,240},{54,1,240}}},
	{job=5,level=6,item={{6204,1,10},{6531,1,2},{6541,1,3}},attr={{50,1,840},{51,1,420},{52,1,420},{53,1,336},{54,1,336}}},
	{job=5,level=7,item={{6204,1,12},{6531,1,2},{6541,1,3}},attr={{50,1,1080},{51,1,540},{52,1,540},{53,1,432},{54,1,432}}},
	{job=5,level=8,item={{6204,1,14},{6531,1,2},{6541,1,3}},attr={{50,1,1320},{51,1,660},{52,1,660},{53,1,528},{54,1,528}}},
	{job=5,level=9,item={{6204,1,16},{6531,1,2},{6541,1,3}},attr={{50,1,1560},{51,1,780},{52,1,780},{53,1,624},{54,1,624}}},
	{job=5,level=10,item={{6204,1,18},{6531,1,2},{6541,1,3}},attr={{50,1,1800},{51,1,900},{52,1,900},{53,1,720},{54,1,720}}},
	{job=5,level=11,item={{6204,1,20},{6532,1,3},{6542,1,4}},attr={{50,1,2250},{51,1,1125},{52,1,1125},{53,1,900},{54,1,900}}},
	{job=5,level=12,item={{6204,1,22},{6532,1,3},{6542,1,4}},attr={{50,1,2700},{51,1,1350},{52,1,1350},{53,1,1080},{54,1,1080}}},
	{job=5,level=13,item={{6204,1,24},{6532,1,3},{6542,1,4}},attr={{50,1,3150},{51,1,1575},{52,1,1575},{53,1,1260},{54,1,1260}}},
	{job=5,level=14,item={{6204,1,26},{6532,1,3},{6542,1,4}},attr={{50,1,3600},{51,1,1800},{52,1,1800},{53,1,1440},{54,1,1440}}},
	{job=5,level=15,item={{6204,1,28},{6532,1,3},{6542,1,4}},attr={{50,1,4050},{51,1,2025},{52,1,2025},{53,1,1620},{54,1,1620}}},
	{job=5,level=16,item={{6204,1,30},{6533,1,4},{6543,1,4}},attr={{50,1,4590},{51,1,2295},{52,1,2295},{53,1,1836},{54,1,1836}}},
	{job=5,level=17,item={{6204,1,32},{6533,1,4},{6543,1,4}},attr={{50,1,5160},{51,1,2580},{52,1,2580},{53,1,2064},{54,1,2064}}},
	{job=5,level=18,item={{6204,1,35},{6533,1,4},{6543,1,4}},attr={{50,1,5790},{51,1,2895},{52,1,2895},{53,1,2316},{54,1,2316}}},
	{job=5,level=19,item={{6204,1,40},{6533,1,4},{6543,1,4}},attr={{50,1,6480},{51,1,3240},{52,1,3240},{53,1,2592},{54,1,2592}}},
	{job=5,level=20,item={{6204,1,50},{6533,1,4},{6543,1,4}},attr={{50,1,7200},{51,1,3600},{52,1,3600},{53,1,2880},{54,1,2880}}},
	{job=5,level=21,item={{6204,1,60},{6534,1,5},{6544,1,5}},attr={{50,1,8550},{51,1,4275},{52,1,4275},{53,1,3420},{54,1,3420}}},
	{job=5,level=22,item={{6204,1,80},{6534,1,6},{6544,1,6}},attr={{50,1,10275},{51,1,5137},{52,1,5137},{53,1,4110},{54,1,4110}}},
	{job=5,level=23,item={{6204,1,100},{6534,1,7},{6544,1,7}},attr={{50,1,12360},{51,1,6180},{52,1,6180},{53,1,4944},{54,1,4944}}},
	{job=5,level=24,item={{6204,1,150},{6534,1,12},{6544,1,12}},attr={{50,1,16080},{51,1,8040},{52,1,8040},{53,1,6432},{54,1,6432}}},
	{job=5,level=25,item={{6204,1,200},{6534,1,20},{6544,1,20}},attr={{50,1,22500},{51,1,11250},{52,1,11250},{53,1,9000},{54,1,9000}}},
	{job=5,level=26,item={{6204,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,27000},{51,1,13500},{52,1,13500},{53,1,10800},{54,1,10800}}},
	{job=5,level=27,item={{6204,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,31500},{51,1,15750},{52,1,15750},{53,1,12600},{54,1,12600}}},
	{job=5,level=28,item={{6204,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,36000},{51,1,18000},{52,1,18000},{53,1,14400},{54,1,14400}}},
	{job=5,level=29,item={{6204,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,40500},{51,1,20250},{52,1,20250},{53,1,16200},{54,1,16200}}},
	{job=5,level=30,item={{6204,1,250},{6535,1,10},{6545,1,10}},attr={{50,1,45000},{51,1,22500},{52,1,22500},{53,1,18000},{54,1,18000}}},
}

return data
