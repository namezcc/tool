local data = {
	[0] = {level=0,basic_attr={{50,1,0},{51,1,0},{52,1,0},{53,1,0},{54,1,0}},exp=300,grade=0,break_level=0},
	[1] = {level=1,basic_attr={{50,1,3},{51,1,2},{52,1,2},{53,1,2},{54,1,2}},exp=300,grade=1,break_level=0},
	[2] = {level=2,basic_attr={{50,1,6},{51,1,5},{52,1,5},{53,1,4},{54,1,4}},exp=300,grade=1,break_level=0},
	[3] = {level=3,basic_attr={{50,1,9},{51,1,8},{52,1,8},{53,1,7},{54,1,7}},exp=300,grade=1,break_level=0},
	[4] = {level=4,basic_attr={{50,1,12},{51,1,10},{52,1,10},{53,1,9},{54,1,9}},exp=300,grade=1,break_level=0},
	[5] = {level=5,basic_attr={{50,1,16},{51,1,13},{52,1,13},{53,1,12},{54,1,12}},exp=300,grade=1,break_level=0},
	[6] = {level=6,basic_attr={{50,1,19},{51,1,16},{52,1,16},{53,1,14},{54,1,14}},exp=300,grade=1,break_level=0},
	[7] = {level=7,basic_attr={{50,1,22},{51,1,18},{52,1,18},{53,1,16},{54,1,16}},exp=300,grade=1,break_level=0},
	[8] = {level=8,basic_attr={{50,1,25},{51,1,21},{52,1,21},{53,1,19},{54,1,19}},exp=300,grade=1,break_level=0},
	[9] = {level=9,basic_attr={{50,1,28},{51,1,24},{52,1,24},{53,1,21},{54,1,21}},exp=300,grade=1,break_level=0},
	[10] = {level=10,basic_attr={{50,1,32},{51,1,26},{52,1,26},{53,1,24},{54,1,24}},exp=300,grade=1,break_level=0},
	[11] = {level=11,basic_attr={{50,1,35},{51,1,29},{52,1,29},{53,1,26},{54,1,26}},exp=300,grade=2,break_level=1},
	[12] = {level=12,basic_attr={{50,1,38},{51,1,32},{52,1,32},{53,1,28},{54,1,28}},exp=300,grade=2,break_level=1},
	[13] = {level=13,basic_attr={{50,1,41},{51,1,34},{52,1,34},{53,1,31},{54,1,31}},exp=300,grade=2,break_level=1},
	[14] = {level=14,basic_attr={{50,1,44},{51,1,37},{52,1,37},{53,1,33},{54,1,33}},exp=300,grade=2,break_level=1},
	[15] = {level=15,basic_attr={{50,1,48},{51,1,40},{52,1,40},{53,1,36},{54,1,36}},exp=300,grade=2,break_level=1},
	[16] = {level=16,basic_attr={{50,1,51},{51,1,42},{52,1,42},{53,1,38},{54,1,38}},exp=300,grade=2,break_level=1},
	[17] = {level=17,basic_attr={{50,1,54},{51,1,45},{52,1,45},{53,1,40},{54,1,40}},exp=300,grade=2,break_level=1},
	[18] = {level=18,basic_attr={{50,1,57},{51,1,48},{52,1,48},{53,1,43},{54,1,43}},exp=300,grade=2,break_level=1},
	[19] = {level=19,basic_attr={{50,1,60},{51,1,50},{52,1,50},{53,1,45},{54,1,45}},exp=300,grade=2,break_level=1},
	[20] = {level=20,basic_attr={{50,1,64},{51,1,53},{52,1,53},{53,1,48},{54,1,48}},exp=300,grade=2,break_level=1},
	[21] = {level=21,basic_attr={{50,1,67},{51,1,56},{52,1,56},{53,1,50},{54,1,50}},exp=300,grade=3,break_level=2},
	[22] = {level=22,basic_attr={{50,1,70},{51,1,58},{52,1,58},{53,1,52},{54,1,52}},exp=300,grade=3,break_level=2},
	[23] = {level=23,basic_attr={{50,1,73},{51,1,61},{52,1,61},{53,1,55},{54,1,55}},exp=300,grade=3,break_level=2},
	[24] = {level=24,basic_attr={{50,1,76},{51,1,64},{52,1,64},{53,1,57},{54,1,57}},exp=300,grade=3,break_level=2},
	[25] = {level=25,basic_attr={{50,1,80},{51,1,66},{52,1,66},{53,1,60},{54,1,60}},exp=300,grade=3,break_level=2},
	[26] = {level=26,basic_attr={{50,1,83},{51,1,69},{52,1,69},{53,1,62},{54,1,62}},exp=300,grade=3,break_level=2},
	[27] = {level=27,basic_attr={{50,1,86},{51,1,72},{52,1,72},{53,1,64},{54,1,64}},exp=300,grade=3,break_level=2},
	[28] = {level=28,basic_attr={{50,1,89},{51,1,74},{52,1,74},{53,1,67},{54,1,67}},exp=300,grade=3,break_level=2},
	[29] = {level=29,basic_attr={{50,1,92},{51,1,77},{52,1,77},{53,1,69},{54,1,69}},exp=300,grade=3,break_level=2},
	[30] = {level=30,basic_attr={{50,1,96},{51,1,80},{52,1,80},{53,1,72},{54,1,72}},exp=400,grade=3,break_level=2},
	[31] = {level=31,basic_attr={{50,1,100},{51,1,83},{52,1,83},{53,1,75},{54,1,75}},exp=400,grade=4,break_level=3},
	[32] = {level=32,basic_attr={{50,1,104},{51,1,86},{52,1,86},{53,1,78},{54,1,78}},exp=400,grade=4,break_level=3},
	[33] = {level=33,basic_attr={{50,1,108},{51,1,90},{52,1,90},{53,1,81},{54,1,81}},exp=400,grade=4,break_level=3},
	[34] = {level=34,basic_attr={{50,1,112},{51,1,93},{52,1,93},{53,1,84},{54,1,84}},exp=400,grade=4,break_level=3},
	[35] = {level=35,basic_attr={{50,1,116},{51,1,96},{52,1,96},{53,1,87},{54,1,87}},exp=400,grade=4,break_level=3},
	[36] = {level=36,basic_attr={{50,1,120},{51,1,100},{52,1,100},{53,1,90},{54,1,90}},exp=400,grade=4,break_level=3},
	[37] = {level=37,basic_attr={{50,1,124},{51,1,103},{52,1,103},{53,1,93},{54,1,93}},exp=400,grade=4,break_level=3},
	[38] = {level=38,basic_attr={{50,1,128},{51,1,106},{52,1,106},{53,1,96},{54,1,96}},exp=350,grade=4,break_level=3},
	[39] = {level=39,basic_attr={{50,1,132},{51,1,110},{52,1,110},{53,1,99},{54,1,99}},exp=400,grade=4,break_level=3},
	[40] = {level=40,basic_attr={{50,1,136},{51,1,113},{52,1,113},{53,1,102},{54,1,102}},exp=400,grade=4,break_level=3},
	[41] = {level=41,basic_attr={{50,1,140},{51,1,116},{52,1,116},{53,1,105},{54,1,105}},exp=400,grade=5,break_level=4},
	[42] = {level=42,basic_attr={{50,1,144},{51,1,120},{52,1,120},{53,1,108},{54,1,108}},exp=400,grade=5,break_level=4},
	[43] = {level=43,basic_attr={{50,1,148},{51,1,123},{52,1,123},{53,1,111},{54,1,111}},exp=400,grade=5,break_level=4},
	[44] = {level=44,basic_attr={{50,1,152},{51,1,126},{52,1,126},{53,1,114},{54,1,114}},exp=400,grade=5,break_level=4},
	[45] = {level=45,basic_attr={{50,1,156},{51,1,130},{52,1,130},{53,1,117},{54,1,117}},exp=400,grade=5,break_level=4},
	[46] = {level=46,basic_attr={{50,1,160},{51,1,133},{52,1,133},{53,1,120},{54,1,120}},exp=400,grade=5,break_level=4},
	[47] = {level=47,basic_attr={{50,1,164},{51,1,136},{52,1,136},{53,1,123},{54,1,123}},exp=400,grade=5,break_level=4},
	[48] = {level=48,basic_attr={{50,1,168},{51,1,140},{52,1,140},{53,1,126},{54,1,126}},exp=400,grade=5,break_level=4},
	[49] = {level=49,basic_attr={{50,1,172},{51,1,143},{52,1,143},{53,1,129},{54,1,129}},exp=400,grade=5,break_level=4},
	[50] = {level=50,basic_attr={{50,1,176},{51,1,146},{52,1,146},{53,1,132},{54,1,132}},exp=400,grade=5,break_level=4},
	[51] = {level=51,basic_attr={{50,1,180},{51,1,150},{52,1,150},{53,1,135},{54,1,135}},exp=400,grade=6,break_level=5},
	[52] = {level=52,basic_attr={{50,1,184},{51,1,153},{52,1,153},{53,1,138},{54,1,138}},exp=400,grade=6,break_level=5},
	[53] = {level=53,basic_attr={{50,1,188},{51,1,156},{52,1,156},{53,1,141},{54,1,141}},exp=400,grade=6,break_level=5},
	[54] = {level=54,basic_attr={{50,1,192},{51,1,160},{52,1,160},{53,1,144},{54,1,144}},exp=400,grade=6,break_level=5},
	[55] = {level=55,basic_attr={{50,1,196},{51,1,163},{52,1,163},{53,1,147},{54,1,147}},exp=400,grade=6,break_level=5},
	[56] = {level=56,basic_attr={{50,1,200},{51,1,166},{52,1,166},{53,1,150},{54,1,150}},exp=400,grade=6,break_level=5},
	[57] = {level=57,basic_attr={{50,1,204},{51,1,170},{52,1,170},{53,1,153},{54,1,153}},exp=400,grade=6,break_level=5},
	[58] = {level=58,basic_attr={{50,1,208},{51,1,173},{52,1,173},{53,1,156},{54,1,156}},exp=400,grade=6,break_level=5},
	[59] = {level=59,basic_attr={{50,1,212},{51,1,176},{52,1,176},{53,1,159},{54,1,159}},exp=400,grade=6,break_level=5},
	[60] = {level=60,basic_attr={{50,1,216},{51,1,180},{52,1,180},{53,1,162},{54,1,162}},exp=450,grade=6,break_level=5},
	[61] = {level=61,basic_attr={{50,1,220},{51,1,184},{52,1,184},{53,1,165},{54,1,165}},exp=450,grade=7,break_level=6},
	[62] = {level=62,basic_attr={{50,1,225},{51,1,188},{52,1,188},{53,1,169},{54,1,169}},exp=450,grade=7,break_level=6},
	[63] = {level=63,basic_attr={{50,1,230},{51,1,192},{52,1,192},{53,1,172},{54,1,172}},exp=450,grade=7,break_level=6},
	[64] = {level=64,basic_attr={{50,1,235},{51,1,196},{52,1,196},{53,1,176},{54,1,176}},exp=450,grade=7,break_level=6},
	[65] = {level=65,basic_attr={{50,1,240},{51,1,200},{52,1,200},{53,1,180},{54,1,180}},exp=450,grade=7,break_level=6},
	[66] = {level=66,basic_attr={{50,1,244},{51,1,204},{52,1,204},{53,1,183},{54,1,183}},exp=450,grade=7,break_level=6},
	[67] = {level=67,basic_attr={{50,1,249},{51,1,208},{52,1,208},{53,1,187},{54,1,187}},exp=450,grade=7,break_level=6},
	[68] = {level=68,basic_attr={{50,1,254},{51,1,212},{52,1,212},{53,1,190},{54,1,190}},exp=450,grade=7,break_level=6},
	[69] = {level=69,basic_attr={{50,1,259},{51,1,216},{52,1,216},{53,1,194},{54,1,194}},exp=450,grade=7,break_level=6},
	[70] = {level=70,basic_attr={{50,1,264},{51,1,220},{52,1,220},{53,1,198},{54,1,198}},exp=550,grade=7,break_level=6},
	[71] = {level=71,basic_attr={{50,1,269},{51,1,224},{52,1,224},{53,1,202},{54,1,202}},exp=550,grade=8,break_level=7},
	[72] = {level=72,basic_attr={{50,1,275},{51,1,229},{52,1,229},{53,1,206},{54,1,206}},exp=550,grade=8,break_level=7},
	[73] = {level=73,basic_attr={{50,1,280},{51,1,234},{52,1,234},{53,1,210},{54,1,210}},exp=550,grade=8,break_level=7},
	[74] = {level=74,basic_attr={{50,1,286},{51,1,238},{52,1,238},{53,1,214},{54,1,214}},exp=550,grade=8,break_level=7},
	[75] = {level=75,basic_attr={{50,1,292},{51,1,243},{52,1,243},{53,1,219},{54,1,219}},exp=550,grade=8,break_level=7},
	[76] = {level=76,basic_attr={{50,1,297},{51,1,248},{52,1,248},{53,1,223},{54,1,223}},exp=550,grade=8,break_level=7},
	[77] = {level=77,basic_attr={{50,1,303},{51,1,252},{52,1,252},{53,1,227},{54,1,227}},exp=550,grade=8,break_level=7},
	[78] = {level=78,basic_attr={{50,1,308},{51,1,257},{52,1,257},{53,1,231},{54,1,231}},exp=550,grade=8,break_level=7},
	[79] = {level=79,basic_attr={{50,1,314},{51,1,262},{52,1,262},{53,1,235},{54,1,235}},exp=550,grade=8,break_level=7},
	[80] = {level=80,basic_attr={{50,1,320},{51,1,266},{52,1,266},{53,1,240},{54,1,240}},exp=600,grade=8,break_level=7},
	[81] = {level=81,basic_attr={{50,1,326},{51,1,272},{52,1,272},{53,1,244},{54,1,244}},exp=600,grade=9,break_level=8},
	[82] = {level=82,basic_attr={{50,1,332},{51,1,277},{52,1,277},{53,1,249},{54,1,249}},exp=600,grade=9,break_level=8},
	[83] = {level=83,basic_attr={{50,1,339},{51,1,282},{52,1,282},{53,1,254},{54,1,254}},exp=600,grade=9,break_level=8},
	[84] = {level=84,basic_attr={{50,1,345},{51,1,288},{52,1,288},{53,1,259},{54,1,259}},exp=600,grade=9,break_level=8},
	[85] = {level=85,basic_attr={{50,1,352},{51,1,293},{52,1,293},{53,1,264},{54,1,264}},exp=600,grade=9,break_level=8},
	[86] = {level=86,basic_attr={{50,1,358},{51,1,298},{52,1,298},{53,1,268},{54,1,268}},exp=600,grade=9,break_level=8},
	[87] = {level=87,basic_attr={{50,1,364},{51,1,304},{52,1,304},{53,1,273},{54,1,273}},exp=600,grade=9,break_level=8},
	[88] = {level=88,basic_attr={{50,1,371},{51,1,309},{52,1,309},{53,1,278},{54,1,278}},exp=600,grade=9,break_level=8},
	[89] = {level=89,basic_attr={{50,1,377},{51,1,314},{52,1,314},{53,1,283},{54,1,283}},exp=600,grade=9,break_level=8},
	[90] = {level=90,basic_attr={{50,1,384},{51,1,320},{52,1,320},{53,1,288},{54,1,288}},exp=700,grade=9,break_level=8},
	[91] = {level=91,basic_attr={{50,1,391},{51,1,326},{52,1,326},{53,1,293},{54,1,293}},exp=700,grade=10,break_level=9},
	[92] = {level=92,basic_attr={{50,1,398},{51,1,332},{52,1,332},{53,1,298},{54,1,298}},exp=700,grade=10,break_level=9},
	[93] = {level=93,basic_attr={{50,1,405},{51,1,338},{52,1,338},{53,1,304},{54,1,304}},exp=700,grade=10,break_level=9},
	[94] = {level=94,basic_attr={{50,1,412},{51,1,344},{52,1,344},{53,1,309},{54,1,309}},exp=700,grade=10,break_level=9},
	[95] = {level=95,basic_attr={{50,1,420},{51,1,350},{52,1,350},{53,1,315},{54,1,315}},exp=700,grade=10,break_level=9},
	[96] = {level=96,basic_attr={{50,1,427},{51,1,356},{52,1,356},{53,1,320},{54,1,320}},exp=700,grade=10,break_level=9},
	[97] = {level=97,basic_attr={{50,1,434},{51,1,362},{52,1,362},{53,1,325},{54,1,325}},exp=700,grade=10,break_level=9},
	[98] = {level=98,basic_attr={{50,1,441},{51,1,368},{52,1,368},{53,1,331},{54,1,331}},exp=700,grade=10,break_level=9},
	[99] = {level=99,basic_attr={{50,1,448},{51,1,374},{52,1,374},{53,1,336},{54,1,336}},exp=700,grade=10,break_level=9},
	[100] = {level=100,basic_attr={{50,1,456},{51,1,380},{52,1,380},{53,1,342},{54,1,342}},exp=850,grade=10,break_level=9},
	[101] = {level=101,basic_attr={{50,1,465},{51,1,387},{52,1,387},{53,1,348},{54,1,348}},exp=850,grade=11,break_level=10},
	[102] = {level=102,basic_attr={{50,1,474},{51,1,395},{52,1,395},{53,1,355},{54,1,355}},exp=850,grade=11,break_level=10},
	[103] = {level=103,basic_attr={{50,1,483},{51,1,403},{52,1,403},{53,1,362},{54,1,362}},exp=850,grade=11,break_level=10},
	[104] = {level=104,basic_attr={{50,1,492},{51,1,410},{52,1,410},{53,1,369},{54,1,369}},exp=850,grade=11,break_level=10},
	[105] = {level=105,basic_attr={{50,1,502},{51,1,418},{52,1,418},{53,1,376},{54,1,376}},exp=850,grade=11,break_level=10},
	[106] = {level=106,basic_attr={{50,1,511},{51,1,426},{52,1,426},{53,1,383},{54,1,383}},exp=850,grade=11,break_level=10},
	[107] = {level=107,basic_attr={{50,1,520},{51,1,433},{52,1,433},{53,1,390},{54,1,390}},exp=850,grade=11,break_level=10},
	[108] = {level=108,basic_attr={{50,1,529},{51,1,441},{52,1,441},{53,1,397},{54,1,397}},exp=850,grade=11,break_level=10},
	[109] = {level=109,basic_attr={{50,1,538},{51,1,449},{52,1,449},{53,1,404},{54,1,404}},exp=850,grade=11,break_level=10},
	[110] = {level=110,basic_attr={{50,1,548},{51,1,456},{52,1,456},{53,1,411},{54,1,411}},exp=1050,grade=11,break_level=10},
	[111] = {level=111,basic_attr={{50,1,559},{51,1,465},{52,1,465},{53,1,419},{54,1,419}},exp=1050,grade=12,break_level=11},
	[112] = {level=112,basic_attr={{50,1,570},{51,1,475},{52,1,475},{53,1,427},{54,1,427}},exp=1050,grade=12,break_level=11},
	[113] = {level=113,basic_attr={{50,1,581},{51,1,484},{52,1,484},{53,1,436},{54,1,436}},exp=1050,grade=12,break_level=11},
	[114] = {level=114,basic_attr={{50,1,592},{51,1,493},{52,1,493},{53,1,444},{54,1,444}},exp=1050,grade=12,break_level=11},
	[115] = {level=115,basic_attr={{50,1,603},{51,1,503},{52,1,503},{53,1,452},{54,1,452}},exp=1050,grade=12,break_level=11},
	[116] = {level=116,basic_attr={{50,1,614},{51,1,512},{52,1,512},{53,1,461},{54,1,461}},exp=1050,grade=12,break_level=11},
	[117] = {level=117,basic_attr={{50,1,625},{51,1,521},{52,1,521},{53,1,469},{54,1,469}},exp=1050,grade=12,break_level=11},
	[118] = {level=118,basic_attr={{50,1,636},{51,1,530},{52,1,530},{53,1,477},{54,1,477}},exp=1050,grade=12,break_level=11},
	[119] = {level=119,basic_attr={{50,1,648},{51,1,540},{52,1,540},{53,1,486},{54,1,486}},exp=1050,grade=12,break_level=11},
	[120] = {level=120,basic_attr={{50,1,659},{51,1,549},{52,1,549},{53,1,494},{54,1,494}},exp=1850,grade=12,break_level=11},
	[121] = {level=121,basic_attr={{50,1,679},{51,1,565},{52,1,565},{53,1,509},{54,1,509}},exp=1850,grade=13,break_level=12},
	[122] = {level=122,basic_attr={{50,1,698},{51,1,582},{52,1,582},{53,1,524},{54,1,524}},exp=1850,grade=13,break_level=12},
	[123] = {level=123,basic_attr={{50,1,718},{51,1,598},{52,1,598},{53,1,539},{54,1,539}},exp=1850,grade=13,break_level=12},
	[124] = {level=124,basic_attr={{50,1,738},{51,1,615},{52,1,615},{53,1,553},{54,1,553}},exp=1850,grade=13,break_level=12},
	[125] = {level=125,basic_attr={{50,1,758},{51,1,632},{52,1,632},{53,1,568},{54,1,568}},exp=1850,grade=13,break_level=12},
	[126] = {level=126,basic_attr={{50,1,778},{51,1,648},{52,1,648},{53,1,583},{54,1,583}},exp=1850,grade=13,break_level=12},
	[127] = {level=127,basic_attr={{50,1,798},{51,1,665},{52,1,665},{53,1,598},{54,1,598}},exp=1850,grade=13,break_level=12},
	[128] = {level=128,basic_attr={{50,1,817},{51,1,681},{52,1,681},{53,1,613},{54,1,613}},exp=1850,grade=13,break_level=12},
	[129] = {level=129,basic_attr={{50,1,837},{51,1,698},{52,1,698},{53,1,628},{54,1,628}},exp=1850,grade=13,break_level=12},
	[130] = {level=130,basic_attr={{50,1,857},{51,1,714},{52,1,714},{53,1,643},{54,1,643}},exp=3200,grade=13,break_level=12},
	[131] = {level=131,basic_attr={{50,1,891},{51,1,743},{52,1,743},{53,1,668},{54,1,668}},exp=3200,grade=14,break_level=13},
	[132] = {level=132,basic_attr={{50,1,926},{51,1,771},{52,1,771},{53,1,694},{54,1,694}},exp=3200,grade=14,break_level=13},
	[133] = {level=133,basic_attr={{50,1,960},{51,1,800},{52,1,800},{53,1,720},{54,1,720}},exp=3200,grade=14,break_level=13},
	[134] = {level=134,basic_attr={{50,1,994},{51,1,828},{52,1,828},{53,1,745},{54,1,745}},exp=3200,grade=14,break_level=13},
	[135] = {level=135,basic_attr={{50,1,1028},{51,1,857},{52,1,857},{53,1,771},{54,1,771}},exp=3200,grade=14,break_level=13},
	[136] = {level=136,basic_attr={{50,1,1063},{51,1,885},{52,1,885},{53,1,797},{54,1,797}},exp=3200,grade=14,break_level=13},
	[137] = {level=137,basic_attr={{50,1,1097},{51,1,914},{52,1,914},{53,1,822},{54,1,822}},exp=3200,grade=14,break_level=13},
	[138] = {level=138,basic_attr={{50,1,1131},{51,1,942},{52,1,942},{53,1,848},{54,1,848}},exp=3200,grade=14,break_level=13},
	[139] = {level=139,basic_attr={{50,1,1165},{51,1,971},{52,1,971},{53,1,874},{54,1,874}},exp=3200,grade=14,break_level=13},
	[140] = {level=140,basic_attr={{50,1,1200},{51,1,1000},{52,1,1000},{53,1,900},{54,1,900}},exp=11250,grade=14,break_level=13},
	[141] = {level=141,basic_attr={{50,1,1320},{51,1,1100},{52,1,1100},{53,1,990},{54,1,990}},exp=11250,grade=15,break_level=14},
	[142] = {level=142,basic_attr={{50,1,1440},{51,1,1200},{52,1,1200},{53,1,1080},{54,1,1080}},exp=11250,grade=15,break_level=14},
	[143] = {level=143,basic_attr={{50,1,1560},{51,1,1300},{52,1,1300},{53,1,1170},{54,1,1170}},exp=11250,grade=15,break_level=14},
	[144] = {level=144,basic_attr={{50,1,1680},{51,1,1400},{52,1,1400},{53,1,1260},{54,1,1260}},exp=11250,grade=15,break_level=14},
	[145] = {level=145,basic_attr={{50,1,1800},{51,1,1500},{52,1,1500},{53,1,1350},{54,1,1350}},exp=11250,grade=15,break_level=14},
	[146] = {level=146,basic_attr={{50,1,1920},{51,1,1600},{52,1,1600},{53,1,1440},{54,1,1440}},exp=11250,grade=15,break_level=14},
	[147] = {level=147,basic_attr={{50,1,2040},{51,1,1700},{52,1,1700},{53,1,1530},{54,1,1530}},exp=11250,grade=15,break_level=14},
	[148] = {level=148,basic_attr={{50,1,2160},{51,1,1800},{52,1,1800},{53,1,1620},{54,1,1620}},exp=11250,grade=15,break_level=14},
	[149] = {level=149,basic_attr={{50,1,2280},{51,1,1900},{52,1,1900},{53,1,1710},{54,1,1710}},exp=11250,grade=15,break_level=14},
	[150] = {level=150,basic_attr={{50,1,2400},{51,1,2000},{52,1,2000},{53,1,1800},{54,1,1800}},exp=0,grade=15,break_level=14},
}

return data
