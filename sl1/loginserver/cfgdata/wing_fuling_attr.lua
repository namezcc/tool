local data = {
	{id=1,level=1,attr={{31,1,3000},{5,1,300},{6,1,120},{27,1,150},{28,1,150}}},
	{id=1,level=2,attr={{31,1,6000},{5,1,600},{6,1,240},{27,1,300},{28,1,300}}},
	{id=1,level=3,attr={{31,1,9000},{5,1,900},{6,1,360},{27,1,450},{28,1,450}}},
	{id=1,level=4,attr={{31,1,12750},{5,1,1275},{6,1,510},{27,1,638},{28,1,638}}},
	{id=1,level=5,attr={{31,1,16500},{5,1,1650},{6,1,660},{27,1,825},{28,1,825}}},
	{id=1,level=6,attr={{31,1,20250},{5,1,2025},{6,1,810},{27,1,1013},{28,1,1013}}},
	{id=1,level=7,attr={{31,1,24750},{5,1,2475},{6,1,990},{27,1,1238},{28,1,1238}}},
	{id=1,level=8,attr={{31,1,30000},{5,1,3000},{6,1,1200},{27,1,1500},{28,1,1500}}},
	{id=1,level=9,attr={{31,1,36000},{5,1,3600},{6,1,1440},{27,1,1800},{28,1,1800}}},
	{id=1,level=10,attr={{31,1,42750},{5,1,4275},{6,1,1710},{27,1,2138},{28,1,2138}}},
	{id=1,level=11,attr={{31,1,51375},{5,1,5138},{6,1,2055},{27,1,2569},{28,1,2569}}},
	{id=1,level=12,attr={{31,1,61800},{5,1,6180},{6,1,2472},{27,1,3090},{28,1,3090}}},
	{id=1,level=13,attr={{31,1,80400},{5,1,8040},{6,1,3216},{27,1,4020},{28,1,4020}}},
	{id=1,level=14,attr={{31,1,112500},{5,1,11250},{6,1,4500},{27,1,5625},{28,1,5625}}},
	{id=1,level=15,attr={{31,1,225000},{5,1,22500},{6,1,9000},{27,1,11250},{28,1,11250}}},
	{id=2,level=1,attr={{3,1,150},{4,1,150},{29,1,300},{30,1,300},{5,1,300},{6,1,120}}},
	{id=2,level=2,attr={{3,1,300},{4,1,300},{29,1,600},{30,1,600},{5,1,600},{6,1,240}}},
	{id=2,level=3,attr={{3,1,450},{4,1,450},{29,1,900},{30,1,900},{5,1,900},{6,1,360}}},
	{id=2,level=4,attr={{3,1,638},{4,1,638},{29,1,1275},{30,1,1275},{5,1,1275},{6,1,510}}},
	{id=2,level=5,attr={{3,1,825},{4,1,825},{29,1,1650},{30,1,1650},{5,1,1650},{6,1,660}}},
	{id=2,level=6,attr={{3,1,1013},{4,1,1013},{29,1,2025},{30,1,2025},{5,1,2025},{6,1,810}}},
	{id=2,level=7,attr={{3,1,1238},{4,1,1238},{29,1,2475},{30,1,2475},{5,1,2475},{6,1,990}}},
	{id=2,level=8,attr={{3,1,1500},{4,1,1500},{29,1,3000},{30,1,3000},{5,1,3000},{6,1,1200}}},
	{id=2,level=9,attr={{3,1,1800},{4,1,1800},{29,1,3600},{30,1,3600},{5,1,3600},{6,1,1440}}},
	{id=2,level=10,attr={{3,1,2138},{4,1,2138},{29,1,4275},{30,1,4275},{5,1,4275},{6,1,1710}}},
	{id=2,level=11,attr={{3,1,2569},{4,1,2569},{29,1,5138},{30,1,5138},{5,1,5138},{6,1,2055}}},
	{id=2,level=12,attr={{3,1,3090},{4,1,3090},{29,1,6180},{30,1,6180},{5,1,6180},{6,1,2472}}},
	{id=2,level=13,attr={{3,1,4020},{4,1,4020},{29,1,8040},{30,1,8040},{5,1,8040},{6,1,3216}}},
	{id=2,level=14,attr={{3,1,5625},{4,1,5625},{29,1,11250},{30,1,11250},{5,1,11250},{6,1,4500}}},
	{id=2,level=15,attr={{3,1,11250},{4,1,11250},{29,1,22500},{30,1,22500},{5,1,22500},{6,1,9000}}},
	{id=3,level=1,attr={{31,1,3000},{29,1,300},{30,1,300},{5,1,300},{6,1,120}}},
	{id=3,level=2,attr={{31,1,6000},{29,1,600},{30,1,600},{5,1,600},{6,1,240}}},
	{id=3,level=3,attr={{31,1,9000},{29,1,900},{30,1,900},{5,1,900},{6,1,360}}},
	{id=3,level=4,attr={{31,1,12750},{29,1,1275},{30,1,1275},{5,1,1275},{6,1,510}}},
	{id=3,level=5,attr={{31,1,16500},{29,1,1650},{30,1,1650},{5,1,1650},{6,1,660}}},
	{id=3,level=6,attr={{31,1,20250},{29,1,2025},{30,1,2025},{5,1,2025},{6,1,810}}},
	{id=3,level=7,attr={{31,1,24750},{29,1,2475},{30,1,2475},{5,1,2475},{6,1,990}}},
	{id=3,level=8,attr={{31,1,30000},{29,1,3000},{30,1,3000},{5,1,3000},{6,1,1200}}},
	{id=3,level=9,attr={{31,1,36000},{29,1,3600},{30,1,3600},{5,1,3600},{6,1,1440}}},
	{id=3,level=10,attr={{31,1,42750},{29,1,4275},{30,1,4275},{5,1,4275},{6,1,1710}}},
	{id=3,level=11,attr={{31,1,51375},{29,1,5138},{30,1,5138},{5,1,5138},{6,1,2055}}},
	{id=3,level=12,attr={{31,1,61800},{29,1,6180},{30,1,6180},{5,1,6180},{6,1,2472}}},
	{id=3,level=13,attr={{31,1,80400},{29,1,8040},{30,1,8040},{5,1,8040},{6,1,3216}}},
	{id=3,level=14,attr={{31,1,112500},{29,1,11250},{30,1,11250},{5,1,11250},{6,1,4500}}},
	{id=3,level=15,attr={{31,1,225000},{29,1,22500},{30,1,22500},{5,1,22500},{6,1,9000}}},
	{id=4,level=1,attr={{3,1,150},{4,1,150},{5,1,300},{6,1,120},{27,1,150},{28,1,150}}},
	{id=4,level=2,attr={{3,1,300},{4,1,300},{5,1,600},{6,1,240},{27,1,300},{28,1,300}}},
	{id=4,level=3,attr={{3,1,450},{4,1,450},{5,1,900},{6,1,360},{27,1,450},{28,1,450}}},
	{id=4,level=4,attr={{3,1,638},{4,1,638},{5,1,1275},{6,1,510},{27,1,638},{28,1,638}}},
	{id=4,level=5,attr={{3,1,825},{4,1,825},{5,1,1650},{6,1,660},{27,1,825},{28,1,825}}},
	{id=4,level=6,attr={{3,1,1013},{4,1,1013},{5,1,2025},{6,1,810},{27,1,1013},{28,1,1013}}},
	{id=4,level=7,attr={{3,1,1238},{4,1,1238},{5,1,2475},{6,1,990},{27,1,1238},{28,1,1238}}},
	{id=4,level=8,attr={{3,1,1500},{4,1,1500},{5,1,3000},{6,1,1200},{27,1,1500},{28,1,1500}}},
	{id=4,level=9,attr={{3,1,1800},{4,1,1800},{5,1,3600},{6,1,1440},{27,1,1800},{28,1,1800}}},
	{id=4,level=10,attr={{3,1,2138},{4,1,2138},{5,1,4275},{6,1,1710},{27,1,2138},{28,1,2138}}},
	{id=4,level=11,attr={{3,1,2569},{4,1,2569},{5,1,5138},{6,1,2055},{27,1,2569},{28,1,2569}}},
	{id=4,level=12,attr={{3,1,3090},{4,1,3090},{5,1,6180},{6,1,2472},{27,1,3090},{28,1,3090}}},
	{id=4,level=13,attr={{3,1,4020},{4,1,4020},{5,1,8040},{6,1,3216},{27,1,4020},{28,1,4020}}},
	{id=4,level=14,attr={{3,1,5625},{4,1,5625},{5,1,11250},{6,1,4500},{27,1,5625},{28,1,5625}}},
	{id=4,level=15,attr={{3,1,11250},{4,1,11250},{5,1,22500},{6,1,9000},{27,1,11250},{28,1,11250}}},
	{id=5,level=1,attr={{31,1,3000},{29,1,300},{30,1,300},{25,1,150},{26,1,120}}},
	{id=5,level=2,attr={{31,1,6000},{29,1,600},{30,1,600},{25,1,300},{26,1,240}}},
	{id=5,level=3,attr={{31,1,9000},{29,1,900},{30,1,900},{25,1,450},{26,1,360}}},
	{id=5,level=4,attr={{31,1,12750},{29,1,1275},{30,1,1275},{25,1,638},{26,1,510}}},
	{id=5,level=5,attr={{31,1,16500},{29,1,1650},{30,1,1650},{25,1,825},{26,1,660}}},
	{id=5,level=6,attr={{31,1,20250},{29,1,2025},{30,1,2025},{25,1,1013},{26,1,810}}},
	{id=5,level=7,attr={{31,1,24750},{29,1,2475},{30,1,2475},{25,1,1238},{26,1,990}}},
	{id=5,level=8,attr={{31,1,30000},{29,1,3000},{30,1,3000},{25,1,1500},{26,1,1200}}},
	{id=5,level=9,attr={{31,1,36000},{29,1,3600},{30,1,3600},{25,1,1800},{26,1,1440}}},
	{id=5,level=10,attr={{31,1,42750},{29,1,4275},{30,1,4275},{25,1,2138},{26,1,1710}}},
	{id=5,level=11,attr={{31,1,51375},{29,1,5138},{30,1,5138},{25,1,2569},{26,1,2055}}},
	{id=5,level=12,attr={{31,1,61800},{29,1,6180},{30,1,6180},{25,1,3090},{26,1,2472}}},
	{id=5,level=13,attr={{31,1,80400},{29,1,8040},{30,1,8040},{25,1,4020},{26,1,3216}}},
	{id=5,level=14,attr={{31,1,112500},{29,1,11250},{30,1,11250},{25,1,5625},{26,1,4500}}},
	{id=5,level=15,attr={{31,1,225000},{29,1,22500},{30,1,22500},{25,1,11250},{26,1,9000}}},
	{id=6,level=1,attr={{3,1,150},{4,1,150},{25,1,150},{26,1,120},{27,1,150},{28,1,150}}},
	{id=6,level=2,attr={{3,1,300},{4,1,300},{25,1,300},{26,1,240},{27,1,300},{28,1,300}}},
	{id=6,level=3,attr={{3,1,450},{4,1,450},{25,1,450},{26,1,360},{27,1,450},{28,1,450}}},
	{id=6,level=4,attr={{3,1,638},{4,1,638},{25,1,638},{26,1,510},{27,1,638},{28,1,638}}},
	{id=6,level=5,attr={{3,1,825},{4,1,825},{25,1,825},{26,1,660},{27,1,825},{28,1,825}}},
	{id=6,level=6,attr={{3,1,1013},{4,1,1013},{25,1,1013},{26,1,810},{27,1,1013},{28,1,1013}}},
	{id=6,level=7,attr={{3,1,1238},{4,1,1238},{25,1,1238},{26,1,990},{27,1,1238},{28,1,1238}}},
	{id=6,level=8,attr={{3,1,1500},{4,1,1500},{25,1,1500},{26,1,1200},{27,1,1500},{28,1,1500}}},
	{id=6,level=9,attr={{3,1,1800},{4,1,1800},{25,1,1800},{26,1,1440},{27,1,1800},{28,1,1800}}},
	{id=6,level=10,attr={{3,1,2138},{4,1,2138},{25,1,2138},{26,1,1710},{27,1,2138},{28,1,2138}}},
	{id=6,level=11,attr={{3,1,2569},{4,1,2569},{25,1,2569},{26,1,2055},{27,1,2569},{28,1,2569}}},
	{id=6,level=12,attr={{3,1,3090},{4,1,3090},{25,1,3090},{26,1,2472},{27,1,3090},{28,1,3090}}},
	{id=6,level=13,attr={{3,1,4020},{4,1,4020},{25,1,4020},{26,1,3216},{27,1,4020},{28,1,4020}}},
	{id=6,level=14,attr={{3,1,5625},{4,1,5625},{25,1,5625},{26,1,4500},{27,1,5625},{28,1,5625}}},
	{id=6,level=15,attr={{3,1,11250},{4,1,11250},{25,1,11250},{26,1,9000},{27,1,11250},{28,1,11250}}},
	{id=7,level=1,attr={{31,1,3000},{25,1,150},{26,1,120},{27,1,150},{28,1,150}}},
	{id=7,level=2,attr={{31,1,6000},{25,1,300},{26,1,240},{27,1,300},{28,1,300}}},
	{id=7,level=3,attr={{31,1,9000},{25,1,450},{26,1,360},{27,1,450},{28,1,450}}},
	{id=7,level=4,attr={{31,1,12750},{25,1,638},{26,1,510},{27,1,638},{28,1,638}}},
	{id=7,level=5,attr={{31,1,16500},{25,1,825},{26,1,660},{27,1,825},{28,1,825}}},
	{id=7,level=6,attr={{31,1,20250},{25,1,1013},{26,1,810},{27,1,1013},{28,1,1013}}},
	{id=7,level=7,attr={{31,1,24750},{25,1,1238},{26,1,990},{27,1,1238},{28,1,1238}}},
	{id=7,level=8,attr={{31,1,30000},{25,1,1500},{26,1,1200},{27,1,1500},{28,1,1500}}},
	{id=7,level=9,attr={{31,1,36000},{25,1,1800},{26,1,1440},{27,1,1800},{28,1,1800}}},
	{id=7,level=10,attr={{31,1,42750},{25,1,2138},{26,1,1710},{27,1,2138},{28,1,2138}}},
	{id=7,level=11,attr={{31,1,51375},{25,1,2569},{26,1,2055},{27,1,2569},{28,1,2569}}},
	{id=7,level=12,attr={{31,1,61800},{25,1,3090},{26,1,2472},{27,1,3090},{28,1,3090}}},
	{id=7,level=13,attr={{31,1,80400},{25,1,4020},{26,1,3216},{27,1,4020},{28,1,4020}}},
	{id=7,level=14,attr={{31,1,112500},{25,1,5625},{26,1,4500},{27,1,5625},{28,1,5625}}},
	{id=7,level=15,attr={{31,1,225000},{25,1,11250},{26,1,9000},{27,1,11250},{28,1,11250}}},
	{id=8,level=1,attr={{3,1,150},{4,1,150},{29,1,300},{30,1,300},{25,1,150},{26,1,120}}},
	{id=8,level=2,attr={{3,1,300},{4,1,300},{29,1,600},{30,1,600},{25,1,300},{26,1,240}}},
	{id=8,level=3,attr={{3,1,450},{4,1,450},{29,1,900},{30,1,900},{25,1,450},{26,1,360}}},
	{id=8,level=4,attr={{3,1,638},{4,1,638},{29,1,1275},{30,1,1275},{25,1,638},{26,1,510}}},
	{id=8,level=5,attr={{3,1,825},{4,1,825},{29,1,1650},{30,1,1650},{25,1,825},{26,1,660}}},
	{id=8,level=6,attr={{3,1,1013},{4,1,1013},{29,1,2025},{30,1,2025},{25,1,1013},{26,1,810}}},
	{id=8,level=7,attr={{3,1,1238},{4,1,1238},{29,1,2475},{30,1,2475},{25,1,1238},{26,1,990}}},
	{id=8,level=8,attr={{3,1,1500},{4,1,1500},{29,1,3000},{30,1,3000},{25,1,1500},{26,1,1200}}},
	{id=8,level=9,attr={{3,1,1800},{4,1,1800},{29,1,3600},{30,1,3600},{25,1,1800},{26,1,1440}}},
	{id=8,level=10,attr={{3,1,2138},{4,1,2138},{29,1,4275},{30,1,4275},{25,1,2138},{26,1,1710}}},
	{id=8,level=11,attr={{3,1,2569},{4,1,2569},{29,1,5138},{30,1,5138},{25,1,2569},{26,1,2055}}},
	{id=8,level=12,attr={{3,1,3090},{4,1,3090},{29,1,6180},{30,1,6180},{25,1,3090},{26,1,2472}}},
	{id=8,level=13,attr={{3,1,4020},{4,1,4020},{29,1,8040},{30,1,8040},{25,1,4020},{26,1,3216}}},
	{id=8,level=14,attr={{3,1,5625},{4,1,5625},{29,1,11250},{30,1,11250},{25,1,5625},{26,1,4500}}},
	{id=8,level=15,attr={{3,1,11250},{4,1,11250},{29,1,22500},{30,1,22500},{25,1,11250},{26,1,9000}}},
}

return data