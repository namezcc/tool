local data = {
	{type=1,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=1,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=1,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=1,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=1,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=2,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=2,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=2,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=2,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=2,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=3,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=3,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=3,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=3,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=3,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=4,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=4,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=4,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=4,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=4,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=5,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=5,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=5,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=5,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=5,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=6,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=6,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=6,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=6,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=6,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=7,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=7,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=7,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=7,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=7,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=8,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=8,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=8,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=8,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=8,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
	{type=9,star=1,cost={{2801,1,2}},attr={{31,1,80},{32,1,160},{33,1,80},{34,1,40},{35,1,40}}},
	{type=9,star=2,cost={{2801,1,2}},attr={{31,1,160},{32,1,320},{33,1,160},{34,1,80},{35,1,80}}},
	{type=9,star=3,cost={{2801,1,2}},attr={{31,1,240},{32,1,480},{33,1,240},{34,1,120},{35,1,120}}},
	{type=9,star=4,cost={{2801,1,2}},attr={{31,1,320},{32,1,640},{33,1,320},{34,1,160},{35,1,160}}},
	{type=9,star=5,cost={{2801,1,2}},attr={{31,1,400},{32,1,800},{33,1,400},{34,1,200},{35,1,200}}},
}

return data
