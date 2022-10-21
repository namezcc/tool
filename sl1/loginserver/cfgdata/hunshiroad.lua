local data = {
	[8] = {id=8,order=1,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[9] = {id=9,order=1,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[10] = {id=10,order=2,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[11] = {id=11,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[12] = {id=12,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[13] = {id=13,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[14] = {id=14,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[15] = {id=15,order=2,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[16] = {id=16,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[17] = {id=17,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[18] = {id=18,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[19] = {id=19,order=2,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[20] = {id=20,order=3,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[21] = {id=21,order=3,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[22] = {id=22,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[23] = {id=23,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[24] = {id=24,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[25] = {id=25,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[26] = {id=26,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[27] = {id=27,order=3,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[28] = {id=28,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[29] = {id=29,order=3,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[30] = {id=30,order=4,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[31] = {id=31,order=4,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[32] = {id=32,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[33] = {id=33,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[34] = {id=34,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[35] = {id=35,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[36] = {id=36,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[37] = {id=37,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[38] = {id=38,order=4,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[39] = {id=39,order=4,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[40] = {id=40,order=5,reward={{13,1,10},{9180,1,2},{9181,1,2},{1,1,10000}}},
	[41] = {id=41,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[42] = {id=42,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[43] = {id=43,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[44] = {id=44,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[45] = {id=45,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[46] = {id=46,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[47] = {id=47,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[48] = {id=48,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[49] = {id=49,order=5,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[50] = {id=50,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[51] = {id=51,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[52] = {id=52,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[53] = {id=53,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[54] = {id=54,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[55] = {id=55,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[56] = {id=56,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[57] = {id=57,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[58] = {id=58,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[59] = {id=59,order=6,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
	[60] = {id=60,order=7,reward={{13,1,5},{9180,1,1},{9181,1,1},{1,1,2000}}},
}

return data
