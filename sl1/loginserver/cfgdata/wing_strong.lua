local data = {
	[0] = {level=0,need_order=0,exp=0,attr={}},
	[1] = {level=1,need_order=0,exp=2000,attr={{31,1,20},{50,1,40},{51,1,20},{53,1,16},{54,1,16}}},
	[2] = {level=2,need_order=0,exp=2000,attr={{31,1,40},{50,1,80},{51,1,40},{53,1,32},{54,1,32}}},
	[3] = {level=3,need_order=0,exp=2000,attr={{31,1,60},{50,1,120},{51,1,60},{53,1,48},{54,1,48}}},
	[4] = {level=4,need_order=0,exp=2000,attr={{31,1,80},{50,1,160},{51,1,80},{53,1,64},{54,1,64}}},
	[5] = {level=5,need_order=0,exp=2000,attr={{31,1,100},{50,1,200},{51,1,100},{53,1,80},{54,1,80}}},
	[6] = {level=6,need_order=0,exp=2000,attr={{31,1,120},{50,1,240},{51,1,120},{53,1,96},{54,1,96}}},
	[7] = {level=7,need_order=0,exp=2000,attr={{31,1,140},{50,1,280},{51,1,140},{53,1,112},{54,1,112}}},
	[8] = {level=8,need_order=0,exp=2000,attr={{31,1,160},{50,1,320},{51,1,160},{53,1,128},{54,1,128}}},
	[9] = {level=9,need_order=0,exp=2000,attr={{31,1,180},{50,1,360},{51,1,180},{53,1,144},{54,1,144}}},
	[10] = {level=10,need_order=0,exp=2000,attr={{31,1,200},{50,1,400},{51,1,200},{53,1,160},{54,1,160}}},
	[11] = {level=11,need_order=1,exp=2000,attr={{31,1,220},{50,1,440},{51,1,220},{53,1,176},{54,1,176}}},
	[12] = {level=12,need_order=1,exp=2000,attr={{31,1,240},{50,1,480},{51,1,240},{53,1,192},{54,1,192}}},
	[13] = {level=13,need_order=1,exp=2000,attr={{31,1,260},{50,1,520},{51,1,260},{53,1,208},{54,1,208}}},
	[14] = {level=14,need_order=1,exp=2000,attr={{31,1,280},{50,1,560},{51,1,280},{53,1,224},{54,1,224}}},
	[15] = {level=15,need_order=1,exp=2000,attr={{31,1,300},{50,1,600},{51,1,300},{53,1,240},{54,1,240}}},
	[16] = {level=16,need_order=1,exp=2000,attr={{31,1,320},{50,1,640},{51,1,320},{53,1,256},{54,1,256}}},
	[17] = {level=17,need_order=1,exp=2000,attr={{31,1,340},{50,1,680},{51,1,340},{53,1,272},{54,1,272}}},
	[18] = {level=18,need_order=1,exp=2000,attr={{31,1,360},{50,1,720},{51,1,360},{53,1,288},{54,1,288}}},
	[19] = {level=19,need_order=1,exp=2000,attr={{31,1,380},{50,1,760},{51,1,380},{53,1,304},{54,1,304}}},
	[20] = {level=20,need_order=1,exp=2000,attr={{31,1,400},{50,1,800},{51,1,400},{53,1,320},{54,1,320}}},
	[21] = {level=21,need_order=2,exp=2000,attr={{31,1,420},{50,1,840},{51,1,420},{53,1,336},{54,1,336}}},
	[22] = {level=22,need_order=2,exp=2000,attr={{31,1,440},{50,1,880},{51,1,440},{53,1,352},{54,1,352}}},
	[23] = {level=23,need_order=2,exp=2000,attr={{31,1,460},{50,1,920},{51,1,460},{53,1,368},{54,1,368}}},
	[24] = {level=24,need_order=2,exp=2000,attr={{31,1,480},{50,1,960},{51,1,480},{53,1,384},{54,1,384}}},
	[25] = {level=25,need_order=2,exp=2000,attr={{31,1,500},{50,1,1000},{51,1,500},{53,1,400},{54,1,400}}},
	[26] = {level=26,need_order=2,exp=2000,attr={{31,1,520},{50,1,1040},{51,1,520},{53,1,416},{54,1,416}}},
	[27] = {level=27,need_order=2,exp=2000,attr={{31,1,540},{50,1,1080},{51,1,540},{53,1,432},{54,1,432}}},
	[28] = {level=28,need_order=2,exp=2000,attr={{31,1,560},{50,1,1120},{51,1,560},{53,1,448},{54,1,448}}},
	[29] = {level=29,need_order=2,exp=2000,attr={{31,1,580},{50,1,1160},{51,1,580},{53,1,464},{54,1,464}}},
	[30] = {level=30,need_order=2,exp=2000,attr={{31,1,600},{50,1,1200},{51,1,600},{53,1,480},{54,1,480}}},
	[31] = {level=31,need_order=3,exp=2000,attr={{31,1,620},{50,1,1240},{51,1,620},{53,1,496},{54,1,496}}},
	[32] = {level=32,need_order=3,exp=2000,attr={{31,1,640},{50,1,1280},{51,1,640},{53,1,512},{54,1,512}}},
	[33] = {level=33,need_order=3,exp=2000,attr={{31,1,660},{50,1,1320},{51,1,660},{53,1,528},{54,1,528}}},
	[34] = {level=34,need_order=3,exp=2000,attr={{31,1,680},{50,1,1360},{51,1,680},{53,1,544},{54,1,544}}},
	[35] = {level=35,need_order=3,exp=2000,attr={{31,1,700},{50,1,1400},{51,1,700},{53,1,560},{54,1,560}}},
	[36] = {level=36,need_order=3,exp=2000,attr={{31,1,720},{50,1,1440},{51,1,720},{53,1,576},{54,1,576}}},
	[37] = {level=37,need_order=3,exp=2000,attr={{31,1,740},{50,1,1480},{51,1,740},{53,1,592},{54,1,592}}},
	[38] = {level=38,need_order=3,exp=2000,attr={{31,1,760},{50,1,1520},{51,1,760},{53,1,608},{54,1,608}}},
	[39] = {level=39,need_order=3,exp=2000,attr={{31,1,780},{50,1,1560},{51,1,780},{53,1,624},{54,1,624}}},
	[40] = {level=40,need_order=3,exp=2000,attr={{31,1,800},{50,1,1600},{51,1,800},{53,1,640},{54,1,640}}},
	[41] = {level=41,need_order=4,exp=2000,attr={{31,1,820},{50,1,1640},{51,1,820},{53,1,656},{54,1,656}}},
	[42] = {level=42,need_order=4,exp=2000,attr={{31,1,840},{50,1,1680},{51,1,840},{53,1,672},{54,1,672}}},
	[43] = {level=43,need_order=4,exp=2000,attr={{31,1,860},{50,1,1720},{51,1,860},{53,1,688},{54,1,688}}},
	[44] = {level=44,need_order=4,exp=2000,attr={{31,1,880},{50,1,1760},{51,1,880},{53,1,704},{54,1,704}}},
	[45] = {level=45,need_order=4,exp=2000,attr={{31,1,900},{50,1,1800},{51,1,900},{53,1,720},{54,1,720}}},
	[46] = {level=46,need_order=4,exp=2000,attr={{31,1,920},{50,1,1840},{51,1,920},{53,1,736},{54,1,736}}},
	[47] = {level=47,need_order=4,exp=2000,attr={{31,1,940},{50,1,1880},{51,1,940},{53,1,752},{54,1,752}}},
	[48] = {level=48,need_order=4,exp=2000,attr={{31,1,960},{50,1,1920},{51,1,960},{53,1,768},{54,1,768}}},
	[49] = {level=49,need_order=4,exp=2000,attr={{31,1,980},{50,1,1960},{51,1,980},{53,1,784},{54,1,784}}},
	[50] = {level=50,need_order=4,exp=2000,attr={{31,1,1000},{50,1,2000},{51,1,1000},{53,1,800},{54,1,800}}},
	[51] = {level=51,need_order=5,exp=12500,attr={{31,1,1125},{50,1,2250},{51,1,1125},{53,1,900},{54,1,900}}},
	[52] = {level=52,need_order=5,exp=2500,attr={{31,1,1150},{50,1,2300},{51,1,1150},{53,1,920},{54,1,920}}},
	[53] = {level=53,need_order=5,exp=2500,attr={{31,1,1175},{50,1,2350},{51,1,1175},{53,1,940},{54,1,940}}},
	[54] = {level=54,need_order=5,exp=2500,attr={{31,1,1200},{50,1,2400},{51,1,1200},{53,1,960},{54,1,960}}},
	[55] = {level=55,need_order=5,exp=2500,attr={{31,1,1225},{50,1,2450},{51,1,1225},{53,1,980},{54,1,980}}},
	[56] = {level=56,need_order=5,exp=2500,attr={{31,1,1250},{50,1,2500},{51,1,1250},{53,1,1000},{54,1,1000}}},
	[57] = {level=57,need_order=5,exp=2500,attr={{31,1,1275},{50,1,2550},{51,1,1275},{53,1,1020},{54,1,1020}}},
	[58] = {level=58,need_order=5,exp=2500,attr={{31,1,1300},{50,1,2600},{51,1,1300},{53,1,1040},{54,1,1040}}},
	[59] = {level=59,need_order=5,exp=2500,attr={{31,1,1325},{50,1,2650},{51,1,1325},{53,1,1060},{54,1,1060}}},
	[60] = {level=60,need_order=5,exp=2500,attr={{31,1,1350},{50,1,2700},{51,1,1350},{53,1,1080},{54,1,1080}}},
	[61] = {level=61,need_order=6,exp=3000,attr={{31,1,1380},{50,1,2760},{51,1,1380},{53,1,1104},{54,1,1104}}},
	[62] = {level=62,need_order=6,exp=3000,attr={{31,1,1410},{50,1,2820},{51,1,1410},{53,1,1128},{54,1,1128}}},
	[63] = {level=63,need_order=6,exp=3000,attr={{31,1,1440},{50,1,2880},{51,1,1440},{53,1,1152},{54,1,1152}}},
	[64] = {level=64,need_order=6,exp=3000,attr={{31,1,1470},{50,1,2940},{51,1,1470},{53,1,1176},{54,1,1176}}},
	[65] = {level=65,need_order=6,exp=3000,attr={{31,1,1500},{50,1,3000},{51,1,1500},{53,1,1200},{54,1,1200}}},
	[66] = {level=66,need_order=6,exp=3000,attr={{31,1,1530},{50,1,3060},{51,1,1530},{53,1,1224},{54,1,1224}}},
	[67] = {level=67,need_order=6,exp=3000,attr={{31,1,1560},{50,1,3120},{51,1,1560},{53,1,1248},{54,1,1248}}},
	[68] = {level=68,need_order=6,exp=3000,attr={{31,1,1590},{50,1,3180},{51,1,1590},{53,1,1272},{54,1,1272}}},
	[69] = {level=69,need_order=6,exp=3000,attr={{31,1,1620},{50,1,3240},{51,1,1620},{53,1,1296},{54,1,1296}}},
	[70] = {level=70,need_order=6,exp=3000,attr={{31,1,1650},{50,1,3300},{51,1,1650},{53,1,1320},{54,1,1320}}},
	[71] = {level=71,need_order=7,exp=3500,attr={{31,1,1685},{50,1,3370},{51,1,1685},{53,1,1348},{54,1,1348}}},
	[72] = {level=72,need_order=7,exp=3500,attr={{31,1,1720},{50,1,3440},{51,1,1720},{53,1,1376},{54,1,1376}}},
	[73] = {level=73,need_order=7,exp=3500,attr={{31,1,1755},{50,1,3510},{51,1,1755},{53,1,1404},{54,1,1404}}},
	[74] = {level=74,need_order=7,exp=3500,attr={{31,1,1790},{50,1,3580},{51,1,1790},{53,1,1432},{54,1,1432}}},
	[75] = {level=75,need_order=7,exp=3500,attr={{31,1,1825},{50,1,3650},{51,1,1825},{53,1,1460},{54,1,1460}}},
	[76] = {level=76,need_order=7,exp=3500,attr={{31,1,1860},{50,1,3720},{51,1,1860},{53,1,1488},{54,1,1488}}},
	[77] = {level=77,need_order=7,exp=3500,attr={{31,1,1895},{50,1,3790},{51,1,1895},{53,1,1516},{54,1,1516}}},
	[78] = {level=78,need_order=7,exp=3500,attr={{31,1,1930},{50,1,3860},{51,1,1930},{53,1,1544},{54,1,1544}}},
	[79] = {level=79,need_order=7,exp=3500,attr={{31,1,1965},{50,1,3930},{51,1,1965},{53,1,1572},{54,1,1572}}},
	[80] = {level=80,need_order=7,exp=3500,attr={{31,1,2000},{50,1,4000},{51,1,2000},{53,1,1600},{54,1,1600}}},
	[81] = {level=81,need_order=8,exp=4000,attr={{31,1,2040},{50,1,4080},{51,1,2040},{53,1,1632},{54,1,1632}}},
	[82] = {level=82,need_order=8,exp=4000,attr={{31,1,2080},{50,1,4160},{51,1,2080},{53,1,1664},{54,1,1664}}},
	[83] = {level=83,need_order=8,exp=4000,attr={{31,1,2120},{50,1,4240},{51,1,2120},{53,1,1696},{54,1,1696}}},
	[84] = {level=84,need_order=8,exp=4000,attr={{31,1,2160},{50,1,4320},{51,1,2160},{53,1,1728},{54,1,1728}}},
	[85] = {level=85,need_order=8,exp=4000,attr={{31,1,2200},{50,1,4400},{51,1,2200},{53,1,1760},{54,1,1760}}},
	[86] = {level=86,need_order=8,exp=4000,attr={{31,1,2240},{50,1,4480},{51,1,2240},{53,1,1792},{54,1,1792}}},
	[87] = {level=87,need_order=8,exp=4000,attr={{31,1,2280},{50,1,4560},{51,1,2280},{53,1,1824},{54,1,1824}}},
	[88] = {level=88,need_order=8,exp=4000,attr={{31,1,2320},{50,1,4640},{51,1,2320},{53,1,1856},{54,1,1856}}},
	[89] = {level=89,need_order=8,exp=4000,attr={{31,1,2360},{50,1,4720},{51,1,2360},{53,1,1888},{54,1,1888}}},
	[90] = {level=90,need_order=8,exp=4000,attr={{31,1,2400},{50,1,4800},{51,1,2400},{53,1,1920},{54,1,1920}}},
	[91] = {level=91,need_order=9,exp=4500,attr={{31,1,2445},{50,1,4890},{51,1,2445},{53,1,1956},{54,1,1956}}},
	[92] = {level=92,need_order=9,exp=4500,attr={{31,1,2490},{50,1,4980},{51,1,2490},{53,1,1992},{54,1,1992}}},
	[93] = {level=93,need_order=9,exp=4500,attr={{31,1,2535},{50,1,5070},{51,1,2535},{53,1,2028},{54,1,2028}}},
	[94] = {level=94,need_order=9,exp=4500,attr={{31,1,2580},{50,1,5160},{51,1,2580},{53,1,2064},{54,1,2064}}},
	[95] = {level=95,need_order=9,exp=4500,attr={{31,1,2625},{50,1,5250},{51,1,2625},{53,1,2100},{54,1,2100}}},
	[96] = {level=96,need_order=9,exp=4500,attr={{31,1,2670},{50,1,5340},{51,1,2670},{53,1,2136},{54,1,2136}}},
	[97] = {level=97,need_order=9,exp=4500,attr={{31,1,2715},{50,1,5430},{51,1,2715},{53,1,2172},{54,1,2172}}},
	[98] = {level=98,need_order=9,exp=4500,attr={{31,1,2760},{50,1,5520},{51,1,2760},{53,1,2208},{54,1,2208}}},
	[99] = {level=99,need_order=9,exp=4500,attr={{31,1,2805},{50,1,5610},{51,1,2805},{53,1,2244},{54,1,2244}}},
	[100] = {level=100,need_order=9,exp=4500,attr={{31,1,2850},{50,1,5700},{51,1,2850},{53,1,2280},{54,1,2280}}},
	[101] = {level=101,need_order=10,exp=5750,attr={{31,1,2908},{50,1,5815},{51,1,2908},{53,1,2326},{54,1,2326}}},
	[102] = {level=102,need_order=10,exp=5750,attr={{31,1,2965},{50,1,5930},{51,1,2965},{53,1,2372},{54,1,2372}}},
	[103] = {level=103,need_order=10,exp=5750,attr={{31,1,3023},{50,1,6045},{51,1,3023},{53,1,2418},{54,1,2418}}},
	[104] = {level=104,need_order=10,exp=5750,attr={{31,1,3080},{50,1,6160},{51,1,3080},{53,1,2464},{54,1,2464}}},
	[105] = {level=105,need_order=10,exp=5750,attr={{31,1,3138},{50,1,6275},{51,1,3138},{53,1,2510},{54,1,2510}}},
	[106] = {level=106,need_order=10,exp=5750,attr={{31,1,3195},{50,1,6390},{51,1,3195},{53,1,2556},{54,1,2556}}},
	[107] = {level=107,need_order=10,exp=5750,attr={{31,1,3253},{50,1,6505},{51,1,3253},{53,1,2602},{54,1,2602}}},
	[108] = {level=108,need_order=10,exp=5750,attr={{31,1,3310},{50,1,6620},{51,1,3310},{53,1,2648},{54,1,2648}}},
	[109] = {level=109,need_order=10,exp=5750,attr={{31,1,3368},{50,1,6735},{51,1,3368},{53,1,2694},{54,1,2694}}},
	[110] = {level=110,need_order=10,exp=5750,attr={{31,1,3425},{50,1,6850},{51,1,3425},{53,1,2740},{54,1,2740}}},
	[111] = {level=111,need_order=11,exp=6950,attr={{31,1,3495},{50,1,6989},{51,1,3495},{53,1,2796},{54,1,2796}}},
	[112] = {level=112,need_order=11,exp=6950,attr={{31,1,3564},{50,1,7128},{51,1,3564},{53,1,2851},{54,1,2851}}},
	[113] = {level=113,need_order=11,exp=6950,attr={{31,1,3634},{50,1,7267},{51,1,3634},{53,1,2907},{54,1,2907}}},
	[114] = {level=114,need_order=11,exp=6950,attr={{31,1,3703},{50,1,7406},{51,1,3703},{53,1,2962},{54,1,2962}}},
	[115] = {level=115,need_order=11,exp=6950,attr={{31,1,3773},{50,1,7545},{51,1,3773},{53,1,3018},{54,1,3018}}},
	[116] = {level=116,need_order=11,exp=6950,attr={{31,1,3842},{50,1,7684},{51,1,3842},{53,1,3074},{54,1,3074}}},
	[117] = {level=117,need_order=11,exp=6950,attr={{31,1,3912},{50,1,7823},{51,1,3912},{53,1,3129},{54,1,3129}}},
	[118] = {level=118,need_order=11,exp=6950,attr={{31,1,3981},{50,1,7962},{51,1,3981},{53,1,3185},{54,1,3185}}},
	[119] = {level=119,need_order=11,exp=6950,attr={{31,1,4051},{50,1,8101},{51,1,4051},{53,1,3240},{54,1,3240}}},
	[120] = {level=120,need_order=11,exp=6950,attr={{31,1,4120},{50,1,8240},{51,1,4120},{53,1,3296},{54,1,3296}}},
	[121] = {level=121,need_order=12,exp=12400,attr={{31,1,4244},{50,1,8488},{51,1,4244},{53,1,3395},{54,1,3395}}},
	[122] = {level=122,need_order=12,exp=12400,attr={{31,1,4368},{50,1,8736},{51,1,4368},{53,1,3494},{54,1,3494}}},
	[123] = {level=123,need_order=12,exp=12400,attr={{31,1,4492},{50,1,8984},{51,1,4492},{53,1,3594},{54,1,3594}}},
	[124] = {level=124,need_order=12,exp=12400,attr={{31,1,4616},{50,1,9232},{51,1,4616},{53,1,3693},{54,1,3693}}},
	[125] = {level=125,need_order=12,exp=12400,attr={{31,1,4740},{50,1,9480},{51,1,4740},{53,1,3792},{54,1,3792}}},
	[126] = {level=126,need_order=12,exp=12400,attr={{31,1,4864},{50,1,9728},{51,1,4864},{53,1,3891},{54,1,3891}}},
	[127] = {level=127,need_order=12,exp=12400,attr={{31,1,4988},{50,1,9976},{51,1,4988},{53,1,3990},{54,1,3990}}},
	[128] = {level=128,need_order=12,exp=12400,attr={{31,1,5112},{50,1,10224},{51,1,5112},{53,1,4090},{54,1,4090}}},
	[129] = {level=129,need_order=12,exp=12400,attr={{31,1,5236},{50,1,10472},{51,1,5236},{53,1,4189},{54,1,4189}}},
	[130] = {level=130,need_order=12,exp=12400,attr={{31,1,5360},{50,1,10720},{51,1,5360},{53,1,4288},{54,1,4288}}},
	[131] = {level=131,need_order=13,exp=21400,attr={{31,1,5574},{50,1,11148},{51,1,5574},{53,1,4459},{54,1,4459}}},
	[132] = {level=132,need_order=13,exp=21400,attr={{31,1,5788},{50,1,11576},{51,1,5788},{53,1,4630},{54,1,4630}}},
	[133] = {level=133,need_order=13,exp=21400,attr={{31,1,6002},{50,1,12004},{51,1,6002},{53,1,4802},{54,1,4802}}},
	[134] = {level=134,need_order=13,exp=21400,attr={{31,1,6216},{50,1,12432},{51,1,6216},{53,1,4973},{54,1,4973}}},
	[135] = {level=135,need_order=13,exp=21400,attr={{31,1,6430},{50,1,12860},{51,1,6430},{53,1,5144},{54,1,5144}}},
	[136] = {level=136,need_order=13,exp=21400,attr={{31,1,6644},{50,1,13288},{51,1,6644},{53,1,5315},{54,1,5315}}},
	[137] = {level=137,need_order=13,exp=21400,attr={{31,1,6858},{50,1,13716},{51,1,6858},{53,1,5486},{54,1,5486}}},
	[138] = {level=138,need_order=13,exp=21400,attr={{31,1,7072},{50,1,14144},{51,1,7072},{53,1,5658},{54,1,5658}}},
	[139] = {level=139,need_order=13,exp=21400,attr={{31,1,7286},{50,1,14572},{51,1,7286},{53,1,5829},{54,1,5829}}},
	[140] = {level=140,need_order=13,exp=21400,attr={{31,1,7500},{50,1,15000},{51,1,7500},{53,1,6000},{54,1,6000}}},
	[141] = {level=141,need_order=14,exp=75000,attr={{31,1,8250},{50,1,16500},{51,1,8250},{53,1,6600},{54,1,6600}}},
	[142] = {level=142,need_order=14,exp=75000,attr={{31,1,9000},{50,1,18000},{51,1,9000},{53,1,7200},{54,1,7200}}},
	[143] = {level=143,need_order=14,exp=75000,attr={{31,1,9750},{50,1,19500},{51,1,9750},{53,1,7800},{54,1,7800}}},
	[144] = {level=144,need_order=14,exp=75000,attr={{31,1,10500},{50,1,21000},{51,1,10500},{53,1,8400},{54,1,8400}}},
	[145] = {level=145,need_order=14,exp=75000,attr={{31,1,11250},{50,1,22500},{51,1,11250},{53,1,9000},{54,1,9000}}},
	[146] = {level=146,need_order=14,exp=75000,attr={{31,1,12000},{50,1,24000},{51,1,12000},{53,1,9600},{54,1,9600}}},
	[147] = {level=147,need_order=14,exp=75000,attr={{31,1,12750},{50,1,25500},{51,1,12750},{53,1,10200},{54,1,10200}}},
	[148] = {level=148,need_order=14,exp=75000,attr={{31,1,13500},{50,1,27000},{51,1,13500},{53,1,10800},{54,1,10800}}},
	[149] = {level=149,need_order=14,exp=75000,attr={{31,1,14250},{50,1,28500},{51,1,14250},{53,1,11400},{54,1,11400}}},
	[150] = {level=150,need_order=14,exp=75000,attr={{31,1,15000},{50,1,30000},{51,1,15000},{53,1,12000},{54,1,12000}}},
}

return data
