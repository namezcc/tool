local data = {
	{type=1,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=1,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=1,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=1,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=1,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=1,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=1,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=1,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=1,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=1,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=1,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=1,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=1,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=1,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=1,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=1,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=2,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=2,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=2,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=2,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=2,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=2,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=2,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=2,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=2,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=2,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=2,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=2,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=2,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=2,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=2,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=2,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=3,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=3,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=3,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=3,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=3,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=3,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=3,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=3,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=3,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=3,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=3,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=3,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=3,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=3,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=3,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=3,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=4,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=4,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=4,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=4,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=4,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=4,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=4,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=4,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=4,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=4,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=4,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=4,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=4,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=4,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=4,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=4,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=5,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=5,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=5,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=5,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=5,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=5,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=5,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=5,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=5,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=5,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=5,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=5,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=5,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=5,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=5,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=5,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=6,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=6,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=6,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=6,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=6,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=6,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=6,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=6,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=6,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=6,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=6,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=6,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=6,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=6,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=6,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=6,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=7,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=7,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=7,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=7,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=7,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=7,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=7,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=7,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=7,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=7,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=7,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=7,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=7,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=7,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=7,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=7,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
	{type=8,level=0,delv=0,player_lv=0,item={},rate=100,attr_add=0},
	{type=8,level=1,delv=0,player_lv=11,item={{7502,1,2}},rate=95,attr_add=500},
	{type=8,level=2,delv=0,player_lv=21,item={{7502,1,4}},rate=90,attr_add=1000},
	{type=8,level=3,delv=1,player_lv=31,item={{7502,1,6}},rate=85,attr_add=1500},
	{type=8,level=4,delv=0,player_lv=41,item={{7502,1,8},{7503,1,1}},rate=80,attr_add=2000},
	{type=8,level=5,delv=1,player_lv=51,item={{7502,1,10},{7503,1,2}},rate=75,attr_add=3000},
	{type=8,level=6,delv=1,player_lv=61,item={{7502,1,12},{7503,1,4}},rate=70,attr_add=4000},
	{type=8,level=7,delv=0,player_lv=71,item={{7502,1,14},{7503,1,6}},rate=65,attr_add=6000},
	{type=8,level=8,delv=1,player_lv=81,item={{7502,1,16},{7503,1,8}},rate=60,attr_add=8000},
	{type=8,level=9,delv=1,player_lv=91,item={{7502,1,20},{7503,1,10}},rate=55,attr_add=10000},
	{type=8,level=10,delv=0,player_lv=95,item={{7502,1,24},{7503,1,12}},rate=50,attr_add=12500},
	{type=8,level=11,delv=1,player_lv=96,item={{7502,1,28},{7503,1,14}},rate=45,attr_add=15000},
	{type=8,level=12,delv=1,player_lv=97,item={{7502,1,32},{7503,1,16}},rate=40,attr_add=17500},
	{type=8,level=13,delv=0,player_lv=98,item={{7502,1,36},{7503,1,18}},rate=35,attr_add=20000},
	{type=8,level=14,delv=1,player_lv=99,item={{7502,1,40},{7503,1,20}},rate=30,attr_add=24000},
	{type=8,level=15,delv=1,player_lv=100,item={{7502,1,50},{7503,1,25}},rate=25,attr_add=30000},
}

return data
