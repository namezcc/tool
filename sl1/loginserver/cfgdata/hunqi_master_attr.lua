local data = {
	{type=1,qulity=2,level=3,godid=1,cost_item={{1,1,500}}},
	{type=1,qulity=2,level=4,godid=1,cost_item={{1,1,500}}},
	{type=1,qulity=2,level=5,godid=1,cost_item={{1,1,500}}},
	{type=1,qulity=2,level=6,godid=2,cost_item={{1,1,1000}}},
	{type=1,qulity=2,level=7,godid=2,cost_item={{1,1,1000}}},
	{type=1,qulity=2,level=8,godid=2,cost_item={{1,1,1000}}},
	{type=1,qulity=2,level=9,godid=2,cost_item={{1,1,1000}}},
	{type=1,qulity=2,level=10,godid=3,cost_item={{1,1,1500}}},
	{type=1,qulity=2,level=11,godid=3,cost_item={{1,1,1500}}},
	{type=1,qulity=2,level=12,godid=3,cost_item={{1,1,1500}}},
	{type=1,qulity=2,level=13,godid=3,cost_item={{1,1,1500}}},
	{type=1,qulity=2,level=14,godid=3,cost_item={{1,1,1500}}},
	{type=1,qulity=2,level=15,godid=4,cost_item={{1,1,2000}}},
	{type=1,qulity=3,level=3,godid=6,cost_item={{1,1,1000}}},
	{type=1,qulity=3,level=4,godid=6,cost_item={{1,1,1000}}},
	{type=1,qulity=3,level=5,godid=6,cost_item={{1,1,1000}}},
	{type=1,qulity=3,level=6,godid=7,cost_item={{1,1,2000}}},
	{type=1,qulity=3,level=7,godid=7,cost_item={{1,1,2000}}},
	{type=1,qulity=3,level=8,godid=7,cost_item={{1,1,2000}}},
	{type=1,qulity=3,level=9,godid=7,cost_item={{1,1,2000}}},
	{type=1,qulity=3,level=10,godid=8,cost_item={{1,1,3000}}},
	{type=1,qulity=3,level=11,godid=8,cost_item={{1,1,3000}}},
	{type=1,qulity=3,level=12,godid=8,cost_item={{1,1,3000}}},
	{type=1,qulity=3,level=13,godid=8,cost_item={{1,1,3000}}},
	{type=1,qulity=3,level=14,godid=8,cost_item={{1,1,3000}}},
	{type=1,qulity=3,level=15,godid=9,cost_item={{1,1,4000}}},
	{type=1,qulity=4,level=3,godid=11,cost_item={{1,1,2000}}},
	{type=1,qulity=4,level=4,godid=11,cost_item={{1,1,2000}}},
	{type=1,qulity=4,level=5,godid=11,cost_item={{1,1,2000}}},
	{type=1,qulity=4,level=6,godid=12,cost_item={{1,1,4000}}},
	{type=1,qulity=4,level=7,godid=12,cost_item={{1,1,4000}}},
	{type=1,qulity=4,level=8,godid=12,cost_item={{1,1,4000}}},
	{type=1,qulity=4,level=9,godid=12,cost_item={{1,1,4000}}},
	{type=1,qulity=4,level=10,godid=13,cost_item={{1,1,6000}}},
	{type=1,qulity=4,level=11,godid=13,cost_item={{1,1,6000}}},
	{type=1,qulity=4,level=12,godid=13,cost_item={{1,1,6000}}},
	{type=1,qulity=4,level=13,godid=13,cost_item={{1,1,6000}}},
	{type=1,qulity=4,level=14,godid=13,cost_item={{1,1,6000}}},
	{type=1,qulity=4,level=15,godid=14,cost_item={{1,1,8000}}},
	{type=1,qulity=5,level=3,godid=16,cost_item={{1,1,4000}}},
	{type=1,qulity=5,level=4,godid=16,cost_item={{1,1,4000}}},
	{type=1,qulity=5,level=5,godid=16,cost_item={{1,1,4000}}},
	{type=1,qulity=5,level=6,godid=17,cost_item={{1,1,8000}}},
	{type=1,qulity=5,level=7,godid=17,cost_item={{1,1,8000}}},
	{type=1,qulity=5,level=8,godid=17,cost_item={{1,1,8000}}},
	{type=1,qulity=5,level=9,godid=17,cost_item={{1,1,8000}}},
	{type=1,qulity=5,level=10,godid=18,cost_item={{1,1,12000}}},
	{type=1,qulity=5,level=11,godid=18,cost_item={{1,1,12000}}},
	{type=1,qulity=5,level=12,godid=18,cost_item={{1,1,12000}}},
	{type=1,qulity=5,level=13,godid=18,cost_item={{1,1,12000}}},
	{type=1,qulity=5,level=14,godid=18,cost_item={{1,1,12000}}},
	{type=1,qulity=5,level=15,godid=19,cost_item={{1,1,16000}}},
	{type=1,qulity=6,level=3,godid=21,cost_item={{1,1,8000}}},
	{type=1,qulity=6,level=4,godid=21,cost_item={{1,1,8000}}},
	{type=1,qulity=6,level=5,godid=21,cost_item={{1,1,8000}}},
	{type=1,qulity=6,level=6,godid=22,cost_item={{1,1,16000}}},
	{type=1,qulity=6,level=7,godid=22,cost_item={{1,1,16000}}},
	{type=1,qulity=6,level=8,godid=22,cost_item={{1,1,16000}}},
	{type=1,qulity=6,level=9,godid=22,cost_item={{1,1,16000}}},
	{type=1,qulity=6,level=10,godid=23,cost_item={{1,1,24000}}},
	{type=1,qulity=6,level=11,godid=23,cost_item={{1,1,24000}}},
	{type=1,qulity=6,level=12,godid=23,cost_item={{1,1,24000}}},
	{type=1,qulity=6,level=13,godid=23,cost_item={{1,1,24000}}},
	{type=1,qulity=6,level=14,godid=23,cost_item={{1,1,24000}}},
	{type=1,qulity=6,level=15,godid=24,cost_item={{1,1,32000}}},
	{type=2,qulity=2,level=3,godid=1,cost_item={{1,1,500}}},
	{type=2,qulity=2,level=4,godid=1,cost_item={{1,1,500}}},
	{type=2,qulity=2,level=5,godid=1,cost_item={{1,1,500}}},
	{type=2,qulity=2,level=6,godid=2,cost_item={{1,1,1000}}},
	{type=2,qulity=2,level=7,godid=2,cost_item={{1,1,1000}}},
	{type=2,qulity=2,level=8,godid=2,cost_item={{1,1,1000}}},
	{type=2,qulity=2,level=9,godid=2,cost_item={{1,1,1000}}},
	{type=2,qulity=2,level=10,godid=3,cost_item={{1,1,1500}}},
	{type=2,qulity=2,level=11,godid=3,cost_item={{1,1,1500}}},
	{type=2,qulity=2,level=12,godid=3,cost_item={{1,1,1500}}},
	{type=2,qulity=2,level=13,godid=3,cost_item={{1,1,1500}}},
	{type=2,qulity=2,level=14,godid=3,cost_item={{1,1,1500}}},
	{type=2,qulity=2,level=15,godid=4,cost_item={{1,1,2000}}},
	{type=2,qulity=3,level=3,godid=6,cost_item={{1,1,1000}}},
	{type=2,qulity=3,level=4,godid=6,cost_item={{1,1,1000}}},
	{type=2,qulity=3,level=5,godid=6,cost_item={{1,1,1000}}},
	{type=2,qulity=3,level=6,godid=7,cost_item={{1,1,2000}}},
	{type=2,qulity=3,level=7,godid=7,cost_item={{1,1,2000}}},
	{type=2,qulity=3,level=8,godid=7,cost_item={{1,1,2000}}},
	{type=2,qulity=3,level=9,godid=7,cost_item={{1,1,2000}}},
	{type=2,qulity=3,level=10,godid=8,cost_item={{1,1,3000}}},
	{type=2,qulity=3,level=11,godid=8,cost_item={{1,1,3000}}},
	{type=2,qulity=3,level=12,godid=8,cost_item={{1,1,3000}}},
	{type=2,qulity=3,level=13,godid=8,cost_item={{1,1,3000}}},
	{type=2,qulity=3,level=14,godid=8,cost_item={{1,1,3000}}},
	{type=2,qulity=3,level=15,godid=9,cost_item={{1,1,4000}}},
	{type=2,qulity=4,level=3,godid=11,cost_item={{1,1,2000}}},
	{type=2,qulity=4,level=4,godid=11,cost_item={{1,1,2000}}},
	{type=2,qulity=4,level=5,godid=11,cost_item={{1,1,2000}}},
	{type=2,qulity=4,level=6,godid=12,cost_item={{1,1,4000}}},
	{type=2,qulity=4,level=7,godid=12,cost_item={{1,1,4000}}},
	{type=2,qulity=4,level=8,godid=12,cost_item={{1,1,4000}}},
	{type=2,qulity=4,level=9,godid=12,cost_item={{1,1,4000}}},
	{type=2,qulity=4,level=10,godid=13,cost_item={{1,1,6000}}},
	{type=2,qulity=4,level=11,godid=13,cost_item={{1,1,6000}}},
	{type=2,qulity=4,level=12,godid=13,cost_item={{1,1,6000}}},
	{type=2,qulity=4,level=13,godid=13,cost_item={{1,1,6000}}},
	{type=2,qulity=4,level=14,godid=13,cost_item={{1,1,6000}}},
	{type=2,qulity=4,level=15,godid=14,cost_item={{1,1,8000}}},
	{type=2,qulity=5,level=3,godid=16,cost_item={{1,1,4000}}},
	{type=2,qulity=5,level=4,godid=16,cost_item={{1,1,4000}}},
	{type=2,qulity=5,level=5,godid=16,cost_item={{1,1,4000}}},
	{type=2,qulity=5,level=6,godid=17,cost_item={{1,1,8000}}},
	{type=2,qulity=5,level=7,godid=17,cost_item={{1,1,8000}}},
	{type=2,qulity=5,level=8,godid=17,cost_item={{1,1,8000}}},
	{type=2,qulity=5,level=9,godid=17,cost_item={{1,1,8000}}},
	{type=2,qulity=5,level=10,godid=18,cost_item={{1,1,12000}}},
	{type=2,qulity=5,level=11,godid=18,cost_item={{1,1,12000}}},
	{type=2,qulity=5,level=12,godid=18,cost_item={{1,1,12000}}},
	{type=2,qulity=5,level=13,godid=18,cost_item={{1,1,12000}}},
	{type=2,qulity=5,level=14,godid=18,cost_item={{1,1,12000}}},
	{type=2,qulity=5,level=15,godid=19,cost_item={{1,1,16000}}},
	{type=2,qulity=6,level=3,godid=21,cost_item={{1,1,8000}}},
	{type=2,qulity=6,level=4,godid=21,cost_item={{1,1,8000}}},
	{type=2,qulity=6,level=5,godid=21,cost_item={{1,1,8000}}},
	{type=2,qulity=6,level=6,godid=22,cost_item={{1,1,16000}}},
	{type=2,qulity=6,level=7,godid=22,cost_item={{1,1,16000}}},
	{type=2,qulity=6,level=8,godid=22,cost_item={{1,1,16000}}},
	{type=2,qulity=6,level=9,godid=22,cost_item={{1,1,16000}}},
	{type=2,qulity=6,level=10,godid=23,cost_item={{1,1,24000}}},
	{type=2,qulity=6,level=11,godid=23,cost_item={{1,1,24000}}},
	{type=2,qulity=6,level=12,godid=23,cost_item={{1,1,24000}}},
	{type=2,qulity=6,level=13,godid=23,cost_item={{1,1,24000}}},
	{type=2,qulity=6,level=14,godid=23,cost_item={{1,1,24000}}},
	{type=2,qulity=6,level=15,godid=24,cost_item={{1,1,32000}}},
	{type=3,qulity=2,level=3,godid=1,cost_item={{1,1,500}}},
	{type=3,qulity=2,level=4,godid=1,cost_item={{1,1,500}}},
	{type=3,qulity=2,level=5,godid=1,cost_item={{1,1,500}}},
	{type=3,qulity=2,level=6,godid=2,cost_item={{1,1,1000}}},
	{type=3,qulity=2,level=7,godid=2,cost_item={{1,1,1000}}},
	{type=3,qulity=2,level=8,godid=2,cost_item={{1,1,1000}}},
	{type=3,qulity=2,level=9,godid=2,cost_item={{1,1,1000}}},
	{type=3,qulity=2,level=10,godid=3,cost_item={{1,1,1500}}},
	{type=3,qulity=2,level=11,godid=3,cost_item={{1,1,1500}}},
	{type=3,qulity=2,level=12,godid=3,cost_item={{1,1,1500}}},
	{type=3,qulity=2,level=13,godid=3,cost_item={{1,1,1500}}},
	{type=3,qulity=2,level=14,godid=3,cost_item={{1,1,1500}}},
	{type=3,qulity=2,level=15,godid=4,cost_item={{1,1,2000}}},
	{type=3,qulity=3,level=3,godid=6,cost_item={{1,1,1000}}},
	{type=3,qulity=3,level=4,godid=6,cost_item={{1,1,1000}}},
	{type=3,qulity=3,level=5,godid=6,cost_item={{1,1,1000}}},
	{type=3,qulity=3,level=6,godid=7,cost_item={{1,1,2000}}},
	{type=3,qulity=3,level=7,godid=7,cost_item={{1,1,2000}}},
	{type=3,qulity=3,level=8,godid=7,cost_item={{1,1,2000}}},
	{type=3,qulity=3,level=9,godid=7,cost_item={{1,1,2000}}},
	{type=3,qulity=3,level=10,godid=8,cost_item={{1,1,3000}}},
	{type=3,qulity=3,level=11,godid=8,cost_item={{1,1,3000}}},
	{type=3,qulity=3,level=12,godid=8,cost_item={{1,1,3000}}},
	{type=3,qulity=3,level=13,godid=8,cost_item={{1,1,3000}}},
	{type=3,qulity=3,level=14,godid=8,cost_item={{1,1,3000}}},
	{type=3,qulity=3,level=15,godid=9,cost_item={{1,1,4000}}},
	{type=3,qulity=4,level=3,godid=11,cost_item={{1,1,2000}}},
	{type=3,qulity=4,level=4,godid=11,cost_item={{1,1,2000}}},
	{type=3,qulity=4,level=5,godid=11,cost_item={{1,1,2000}}},
	{type=3,qulity=4,level=6,godid=12,cost_item={{1,1,4000}}},
	{type=3,qulity=4,level=7,godid=12,cost_item={{1,1,4000}}},
	{type=3,qulity=4,level=8,godid=12,cost_item={{1,1,4000}}},
	{type=3,qulity=4,level=9,godid=12,cost_item={{1,1,4000}}},
	{type=3,qulity=4,level=10,godid=13,cost_item={{1,1,6000}}},
	{type=3,qulity=4,level=11,godid=13,cost_item={{1,1,6000}}},
	{type=3,qulity=4,level=12,godid=13,cost_item={{1,1,6000}}},
	{type=3,qulity=4,level=13,godid=13,cost_item={{1,1,6000}}},
	{type=3,qulity=4,level=14,godid=13,cost_item={{1,1,6000}}},
	{type=3,qulity=4,level=15,godid=14,cost_item={{1,1,8000}}},
	{type=3,qulity=5,level=3,godid=16,cost_item={{1,1,4000}}},
	{type=3,qulity=5,level=4,godid=16,cost_item={{1,1,4000}}},
	{type=3,qulity=5,level=5,godid=16,cost_item={{1,1,4000}}},
	{type=3,qulity=5,level=6,godid=17,cost_item={{1,1,8000}}},
	{type=3,qulity=5,level=7,godid=17,cost_item={{1,1,8000}}},
	{type=3,qulity=5,level=8,godid=17,cost_item={{1,1,8000}}},
	{type=3,qulity=5,level=9,godid=17,cost_item={{1,1,8000}}},
	{type=3,qulity=5,level=10,godid=18,cost_item={{1,1,12000}}},
	{type=3,qulity=5,level=11,godid=18,cost_item={{1,1,12000}}},
	{type=3,qulity=5,level=12,godid=18,cost_item={{1,1,12000}}},
	{type=3,qulity=5,level=13,godid=18,cost_item={{1,1,12000}}},
	{type=3,qulity=5,level=14,godid=18,cost_item={{1,1,12000}}},
	{type=3,qulity=5,level=15,godid=19,cost_item={{1,1,16000}}},
	{type=3,qulity=6,level=3,godid=21,cost_item={{1,1,8000}}},
	{type=3,qulity=6,level=4,godid=21,cost_item={{1,1,8000}}},
	{type=3,qulity=6,level=5,godid=21,cost_item={{1,1,8000}}},
	{type=3,qulity=6,level=6,godid=22,cost_item={{1,1,16000}}},
	{type=3,qulity=6,level=7,godid=22,cost_item={{1,1,16000}}},
	{type=3,qulity=6,level=8,godid=22,cost_item={{1,1,16000}}},
	{type=3,qulity=6,level=9,godid=22,cost_item={{1,1,16000}}},
	{type=3,qulity=6,level=10,godid=23,cost_item={{1,1,24000}}},
	{type=3,qulity=6,level=11,godid=23,cost_item={{1,1,24000}}},
	{type=3,qulity=6,level=12,godid=23,cost_item={{1,1,24000}}},
	{type=3,qulity=6,level=13,godid=23,cost_item={{1,1,24000}}},
	{type=3,qulity=6,level=14,godid=23,cost_item={{1,1,24000}}},
	{type=3,qulity=6,level=15,godid=24,cost_item={{1,1,32000}}},
	{type=4,qulity=2,level=3,godid=26,cost_item={{1,1,500}}},
	{type=4,qulity=2,level=4,godid=26,cost_item={{1,1,500}}},
	{type=4,qulity=2,level=5,godid=26,cost_item={{1,1,500}}},
	{type=4,qulity=2,level=6,godid=27,cost_item={{1,1,1000}}},
	{type=4,qulity=2,level=7,godid=27,cost_item={{1,1,1000}}},
	{type=4,qulity=2,level=8,godid=27,cost_item={{1,1,1000}}},
	{type=4,qulity=2,level=9,godid=27,cost_item={{1,1,1000}}},
	{type=4,qulity=2,level=10,godid=28,cost_item={{1,1,1500}}},
	{type=4,qulity=2,level=11,godid=28,cost_item={{1,1,1500}}},
	{type=4,qulity=2,level=12,godid=28,cost_item={{1,1,1500}}},
	{type=4,qulity=2,level=13,godid=28,cost_item={{1,1,1500}}},
	{type=4,qulity=2,level=14,godid=28,cost_item={{1,1,1500}}},
	{type=4,qulity=2,level=15,godid=29,cost_item={{1,1,2000}}},
	{type=4,qulity=3,level=3,godid=31,cost_item={{1,1,1000}}},
	{type=4,qulity=3,level=4,godid=31,cost_item={{1,1,1000}}},
	{type=4,qulity=3,level=5,godid=31,cost_item={{1,1,1000}}},
	{type=4,qulity=3,level=6,godid=32,cost_item={{1,1,2000}}},
	{type=4,qulity=3,level=7,godid=32,cost_item={{1,1,2000}}},
	{type=4,qulity=3,level=8,godid=32,cost_item={{1,1,2000}}},
	{type=4,qulity=3,level=9,godid=32,cost_item={{1,1,2000}}},
	{type=4,qulity=3,level=10,godid=33,cost_item={{1,1,3000}}},
	{type=4,qulity=3,level=11,godid=33,cost_item={{1,1,3000}}},
	{type=4,qulity=3,level=12,godid=33,cost_item={{1,1,3000}}},
	{type=4,qulity=3,level=13,godid=33,cost_item={{1,1,3000}}},
	{type=4,qulity=3,level=14,godid=33,cost_item={{1,1,3000}}},
	{type=4,qulity=3,level=15,godid=34,cost_item={{1,1,4000}}},
	{type=4,qulity=4,level=3,godid=36,cost_item={{1,1,2000}}},
	{type=4,qulity=4,level=4,godid=36,cost_item={{1,1,2000}}},
	{type=4,qulity=4,level=5,godid=36,cost_item={{1,1,2000}}},
	{type=4,qulity=4,level=6,godid=37,cost_item={{1,1,4000}}},
	{type=4,qulity=4,level=7,godid=37,cost_item={{1,1,4000}}},
	{type=4,qulity=4,level=8,godid=37,cost_item={{1,1,4000}}},
	{type=4,qulity=4,level=9,godid=37,cost_item={{1,1,4000}}},
	{type=4,qulity=4,level=10,godid=38,cost_item={{1,1,6000}}},
	{type=4,qulity=4,level=11,godid=38,cost_item={{1,1,6000}}},
	{type=4,qulity=4,level=12,godid=38,cost_item={{1,1,6000}}},
	{type=4,qulity=4,level=13,godid=38,cost_item={{1,1,6000}}},
	{type=4,qulity=4,level=14,godid=38,cost_item={{1,1,6000}}},
	{type=4,qulity=4,level=15,godid=39,cost_item={{1,1,8000}}},
	{type=4,qulity=5,level=3,godid=41,cost_item={{1,1,4000}}},
	{type=4,qulity=5,level=4,godid=41,cost_item={{1,1,4000}}},
	{type=4,qulity=5,level=5,godid=41,cost_item={{1,1,4000}}},
	{type=4,qulity=5,level=6,godid=42,cost_item={{1,1,8000}}},
	{type=4,qulity=5,level=7,godid=42,cost_item={{1,1,8000}}},
	{type=4,qulity=5,level=8,godid=42,cost_item={{1,1,8000}}},
	{type=4,qulity=5,level=9,godid=42,cost_item={{1,1,8000}}},
	{type=4,qulity=5,level=10,godid=43,cost_item={{1,1,12000}}},
	{type=4,qulity=5,level=11,godid=43,cost_item={{1,1,12000}}},
	{type=4,qulity=5,level=12,godid=43,cost_item={{1,1,12000}}},
	{type=4,qulity=5,level=13,godid=43,cost_item={{1,1,12000}}},
	{type=4,qulity=5,level=14,godid=43,cost_item={{1,1,12000}}},
	{type=4,qulity=5,level=15,godid=44,cost_item={{1,1,16000}}},
	{type=4,qulity=6,level=3,godid=46,cost_item={{1,1,8000}}},
	{type=4,qulity=6,level=4,godid=46,cost_item={{1,1,8000}}},
	{type=4,qulity=6,level=5,godid=46,cost_item={{1,1,8000}}},
	{type=4,qulity=6,level=6,godid=47,cost_item={{1,1,16000}}},
	{type=4,qulity=6,level=7,godid=47,cost_item={{1,1,16000}}},
	{type=4,qulity=6,level=8,godid=47,cost_item={{1,1,16000}}},
	{type=4,qulity=6,level=9,godid=47,cost_item={{1,1,16000}}},
	{type=4,qulity=6,level=10,godid=48,cost_item={{1,1,24000}}},
	{type=4,qulity=6,level=11,godid=48,cost_item={{1,1,24000}}},
	{type=4,qulity=6,level=12,godid=48,cost_item={{1,1,24000}}},
	{type=4,qulity=6,level=13,godid=48,cost_item={{1,1,24000}}},
	{type=4,qulity=6,level=14,godid=48,cost_item={{1,1,24000}}},
	{type=4,qulity=6,level=15,godid=49,cost_item={{1,1,32000}}},
	{type=5,qulity=2,level=3,godid=26,cost_item={{1,1,500}}},
	{type=5,qulity=2,level=4,godid=26,cost_item={{1,1,500}}},
	{type=5,qulity=2,level=5,godid=26,cost_item={{1,1,500}}},
	{type=5,qulity=2,level=6,godid=27,cost_item={{1,1,1000}}},
	{type=5,qulity=2,level=7,godid=27,cost_item={{1,1,1000}}},
	{type=5,qulity=2,level=8,godid=27,cost_item={{1,1,1000}}},
	{type=5,qulity=2,level=9,godid=27,cost_item={{1,1,1000}}},
	{type=5,qulity=2,level=10,godid=28,cost_item={{1,1,1500}}},
	{type=5,qulity=2,level=11,godid=28,cost_item={{1,1,1500}}},
	{type=5,qulity=2,level=12,godid=28,cost_item={{1,1,1500}}},
	{type=5,qulity=2,level=13,godid=28,cost_item={{1,1,1500}}},
	{type=5,qulity=2,level=14,godid=28,cost_item={{1,1,1500}}},
	{type=5,qulity=2,level=15,godid=29,cost_item={{1,1,2000}}},
	{type=5,qulity=3,level=3,godid=31,cost_item={{1,1,1000}}},
	{type=5,qulity=3,level=4,godid=31,cost_item={{1,1,1000}}},
	{type=5,qulity=3,level=5,godid=31,cost_item={{1,1,1000}}},
	{type=5,qulity=3,level=6,godid=32,cost_item={{1,1,2000}}},
	{type=5,qulity=3,level=7,godid=32,cost_item={{1,1,2000}}},
	{type=5,qulity=3,level=8,godid=32,cost_item={{1,1,2000}}},
	{type=5,qulity=3,level=9,godid=32,cost_item={{1,1,2000}}},
	{type=5,qulity=3,level=10,godid=33,cost_item={{1,1,3000}}},
	{type=5,qulity=3,level=11,godid=33,cost_item={{1,1,3000}}},
	{type=5,qulity=3,level=12,godid=33,cost_item={{1,1,3000}}},
	{type=5,qulity=3,level=13,godid=33,cost_item={{1,1,3000}}},
	{type=5,qulity=3,level=14,godid=33,cost_item={{1,1,3000}}},
	{type=5,qulity=3,level=15,godid=34,cost_item={{1,1,4000}}},
	{type=5,qulity=4,level=3,godid=36,cost_item={{1,1,2000}}},
	{type=5,qulity=4,level=4,godid=36,cost_item={{1,1,2000}}},
	{type=5,qulity=4,level=5,godid=36,cost_item={{1,1,2000}}},
	{type=5,qulity=4,level=6,godid=37,cost_item={{1,1,4000}}},
	{type=5,qulity=4,level=7,godid=37,cost_item={{1,1,4000}}},
	{type=5,qulity=4,level=8,godid=37,cost_item={{1,1,4000}}},
	{type=5,qulity=4,level=9,godid=37,cost_item={{1,1,4000}}},
	{type=5,qulity=4,level=10,godid=38,cost_item={{1,1,6000}}},
	{type=5,qulity=4,level=11,godid=38,cost_item={{1,1,6000}}},
	{type=5,qulity=4,level=12,godid=38,cost_item={{1,1,6000}}},
	{type=5,qulity=4,level=13,godid=38,cost_item={{1,1,6000}}},
	{type=5,qulity=4,level=14,godid=38,cost_item={{1,1,6000}}},
	{type=5,qulity=4,level=15,godid=39,cost_item={{1,1,8000}}},
	{type=5,qulity=5,level=3,godid=41,cost_item={{1,1,4000}}},
	{type=5,qulity=5,level=4,godid=41,cost_item={{1,1,4000}}},
	{type=5,qulity=5,level=5,godid=41,cost_item={{1,1,4000}}},
	{type=5,qulity=5,level=6,godid=42,cost_item={{1,1,8000}}},
	{type=5,qulity=5,level=7,godid=42,cost_item={{1,1,8000}}},
	{type=5,qulity=5,level=8,godid=42,cost_item={{1,1,8000}}},
	{type=5,qulity=5,level=9,godid=42,cost_item={{1,1,8000}}},
	{type=5,qulity=5,level=10,godid=43,cost_item={{1,1,12000}}},
	{type=5,qulity=5,level=11,godid=43,cost_item={{1,1,12000}}},
	{type=5,qulity=5,level=12,godid=43,cost_item={{1,1,12000}}},
	{type=5,qulity=5,level=13,godid=43,cost_item={{1,1,12000}}},
	{type=5,qulity=5,level=14,godid=43,cost_item={{1,1,12000}}},
	{type=5,qulity=5,level=15,godid=44,cost_item={{1,1,16000}}},
	{type=5,qulity=6,level=3,godid=46,cost_item={{1,1,8000}}},
	{type=5,qulity=6,level=4,godid=46,cost_item={{1,1,8000}}},
	{type=5,qulity=6,level=5,godid=46,cost_item={{1,1,8000}}},
	{type=5,qulity=6,level=6,godid=47,cost_item={{1,1,16000}}},
	{type=5,qulity=6,level=7,godid=47,cost_item={{1,1,16000}}},
	{type=5,qulity=6,level=8,godid=47,cost_item={{1,1,16000}}},
	{type=5,qulity=6,level=9,godid=47,cost_item={{1,1,16000}}},
	{type=5,qulity=6,level=10,godid=48,cost_item={{1,1,24000}}},
	{type=5,qulity=6,level=11,godid=48,cost_item={{1,1,24000}}},
	{type=5,qulity=6,level=12,godid=48,cost_item={{1,1,24000}}},
	{type=5,qulity=6,level=13,godid=48,cost_item={{1,1,24000}}},
	{type=5,qulity=6,level=14,godid=48,cost_item={{1,1,24000}}},
	{type=5,qulity=6,level=15,godid=49,cost_item={{1,1,32000}}},
	{type=6,qulity=2,level=3,godid=26,cost_item={{1,1,500}}},
	{type=6,qulity=2,level=4,godid=26,cost_item={{1,1,500}}},
	{type=6,qulity=2,level=5,godid=26,cost_item={{1,1,500}}},
	{type=6,qulity=2,level=6,godid=27,cost_item={{1,1,1000}}},
	{type=6,qulity=2,level=7,godid=27,cost_item={{1,1,1000}}},
	{type=6,qulity=2,level=8,godid=27,cost_item={{1,1,1000}}},
	{type=6,qulity=2,level=9,godid=27,cost_item={{1,1,1000}}},
	{type=6,qulity=2,level=10,godid=28,cost_item={{1,1,1500}}},
	{type=6,qulity=2,level=11,godid=28,cost_item={{1,1,1500}}},
	{type=6,qulity=2,level=12,godid=28,cost_item={{1,1,1500}}},
	{type=6,qulity=2,level=13,godid=28,cost_item={{1,1,1500}}},
	{type=6,qulity=2,level=14,godid=28,cost_item={{1,1,1500}}},
	{type=6,qulity=2,level=15,godid=29,cost_item={{1,1,2000}}},
	{type=6,qulity=3,level=3,godid=31,cost_item={{1,1,1000}}},
	{type=6,qulity=3,level=4,godid=31,cost_item={{1,1,1000}}},
	{type=6,qulity=3,level=5,godid=31,cost_item={{1,1,1000}}},
	{type=6,qulity=3,level=6,godid=32,cost_item={{1,1,2000}}},
	{type=6,qulity=3,level=7,godid=32,cost_item={{1,1,2000}}},
	{type=6,qulity=3,level=8,godid=32,cost_item={{1,1,2000}}},
	{type=6,qulity=3,level=9,godid=32,cost_item={{1,1,2000}}},
	{type=6,qulity=3,level=10,godid=33,cost_item={{1,1,3000}}},
	{type=6,qulity=3,level=11,godid=33,cost_item={{1,1,3000}}},
	{type=6,qulity=3,level=12,godid=33,cost_item={{1,1,3000}}},
	{type=6,qulity=3,level=13,godid=33,cost_item={{1,1,3000}}},
	{type=6,qulity=3,level=14,godid=33,cost_item={{1,1,3000}}},
	{type=6,qulity=3,level=15,godid=34,cost_item={{1,1,4000}}},
	{type=6,qulity=4,level=3,godid=36,cost_item={{1,1,2000}}},
	{type=6,qulity=4,level=4,godid=36,cost_item={{1,1,2000}}},
	{type=6,qulity=4,level=5,godid=36,cost_item={{1,1,2000}}},
	{type=6,qulity=4,level=6,godid=37,cost_item={{1,1,4000}}},
	{type=6,qulity=4,level=7,godid=37,cost_item={{1,1,4000}}},
	{type=6,qulity=4,level=8,godid=37,cost_item={{1,1,4000}}},
	{type=6,qulity=4,level=9,godid=37,cost_item={{1,1,4000}}},
	{type=6,qulity=4,level=10,godid=38,cost_item={{1,1,6000}}},
	{type=6,qulity=4,level=11,godid=38,cost_item={{1,1,6000}}},
	{type=6,qulity=4,level=12,godid=38,cost_item={{1,1,6000}}},
	{type=6,qulity=4,level=13,godid=38,cost_item={{1,1,6000}}},
	{type=6,qulity=4,level=14,godid=38,cost_item={{1,1,6000}}},
	{type=6,qulity=4,level=15,godid=39,cost_item={{1,1,8000}}},
	{type=6,qulity=5,level=3,godid=41,cost_item={{1,1,4000}}},
	{type=6,qulity=5,level=4,godid=41,cost_item={{1,1,4000}}},
	{type=6,qulity=5,level=5,godid=41,cost_item={{1,1,4000}}},
	{type=6,qulity=5,level=6,godid=42,cost_item={{1,1,8000}}},
	{type=6,qulity=5,level=7,godid=42,cost_item={{1,1,8000}}},
	{type=6,qulity=5,level=8,godid=42,cost_item={{1,1,8000}}},
	{type=6,qulity=5,level=9,godid=42,cost_item={{1,1,8000}}},
	{type=6,qulity=5,level=10,godid=43,cost_item={{1,1,12000}}},
	{type=6,qulity=5,level=11,godid=43,cost_item={{1,1,12000}}},
	{type=6,qulity=5,level=12,godid=43,cost_item={{1,1,12000}}},
	{type=6,qulity=5,level=13,godid=43,cost_item={{1,1,12000}}},
	{type=6,qulity=5,level=14,godid=43,cost_item={{1,1,12000}}},
	{type=6,qulity=5,level=15,godid=44,cost_item={{1,1,16000}}},
	{type=6,qulity=6,level=3,godid=46,cost_item={{1,1,8000}}},
	{type=6,qulity=6,level=4,godid=46,cost_item={{1,1,8000}}},
	{type=6,qulity=6,level=5,godid=46,cost_item={{1,1,8000}}},
	{type=6,qulity=6,level=6,godid=47,cost_item={{1,1,16000}}},
	{type=6,qulity=6,level=7,godid=47,cost_item={{1,1,16000}}},
	{type=6,qulity=6,level=8,godid=47,cost_item={{1,1,16000}}},
	{type=6,qulity=6,level=9,godid=47,cost_item={{1,1,16000}}},
	{type=6,qulity=6,level=10,godid=48,cost_item={{1,1,24000}}},
	{type=6,qulity=6,level=11,godid=48,cost_item={{1,1,24000}}},
	{type=6,qulity=6,level=12,godid=48,cost_item={{1,1,24000}}},
	{type=6,qulity=6,level=13,godid=48,cost_item={{1,1,24000}}},
	{type=6,qulity=6,level=14,godid=48,cost_item={{1,1,24000}}},
	{type=6,qulity=6,level=15,godid=49,cost_item={{1,1,32000}}},
}

return data
