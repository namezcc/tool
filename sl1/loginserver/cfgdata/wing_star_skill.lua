local data = {
	{job=1,level=1,skill_level={}},
	{job=1,level=2,skill_level={}},
	{job=1,level=3,skill_level={}},
	{job=1,level=4,skill_level={}},
	{job=1,level=5,skill_level={}},
	{job=1,level=6,skill_level={[6021]=1,[6022]=1,[6023]=1,[6024]=1,[6025]=1}},
	{job=1,level=7,skill_level={[6021]=1,[6022]=1,[6023]=1,[6024]=1,[6025]=1}},
	{job=1,level=8,skill_level={[6021]=1,[6022]=1,[6023]=1,[6024]=1,[6025]=1}},
	{job=1,level=9,skill_level={[6021]=1,[6022]=1,[6023]=1,[6024]=1,[6025]=1}},
	{job=1,level=10,skill_level={[6021]=1,[6022]=1,[6023]=1,[6024]=1,[6025]=1}},
	{job=1,level=11,skill_level={[6021]=2,[6022]=2,[6023]=2,[6024]=2,[6025]=2}},
	{job=1,level=12,skill_level={[6021]=2,[6022]=2,[6023]=2,[6024]=2,[6025]=2}},
	{job=1,level=13,skill_level={[6021]=2,[6022]=2,[6023]=2,[6024]=2,[6025]=2}},
	{job=1,level=14,skill_level={[6021]=2,[6022]=2,[6023]=2,[6024]=2,[6025]=2}},
	{job=1,level=15,skill_level={[6021]=2,[6022]=2,[6023]=2,[6024]=2,[6025]=2}},
	{job=1,level=16,skill_level={[6021]=3,[6022]=3,[6023]=3,[6024]=3,[6025]=3}},
	{job=1,level=17,skill_level={[6021]=3,[6022]=3,[6023]=3,[6024]=3,[6025]=3}},
	{job=1,level=18,skill_level={[6021]=3,[6022]=3,[6023]=3,[6024]=3,[6025]=3}},
	{job=1,level=19,skill_level={[6021]=3,[6022]=3,[6023]=3,[6024]=3,[6025]=3}},
	{job=1,level=20,skill_level={[6021]=3,[6022]=3,[6023]=3,[6024]=3,[6025]=3}},
	{job=1,level=21,skill_level={[6021]=4,[6022]=4,[6023]=4,[6024]=4,[6025]=4}},
	{job=1,level=22,skill_level={[6021]=4,[6022]=4,[6023]=4,[6024]=4,[6025]=4}},
	{job=1,level=23,skill_level={[6021]=4,[6022]=4,[6023]=4,[6024]=4,[6025]=4}},
	{job=1,level=24,skill_level={[6021]=4,[6022]=4,[6023]=4,[6024]=4,[6025]=4}},
	{job=1,level=25,skill_level={[6021]=4,[6022]=4,[6023]=4,[6024]=4,[6025]=4}},
	{job=1,level=26,skill_level={[6021]=5,[6022]=5,[6023]=5,[6024]=5,[6025]=5}},
	{job=1,level=27,skill_level={[6021]=5,[6022]=5,[6023]=5,[6024]=5,[6025]=5}},
	{job=1,level=28,skill_level={[6021]=5,[6022]=5,[6023]=5,[6024]=5,[6025]=5}},
	{job=1,level=29,skill_level={[6021]=5,[6022]=5,[6023]=5,[6024]=5,[6025]=5}},
	{job=1,level=30,skill_level={[6021]=5,[6022]=5,[6023]=5,[6024]=5,[6025]=5}},
	{job=2,level=1,skill_level={}},
	{job=2,level=2,skill_level={}},
	{job=2,level=3,skill_level={}},
	{job=2,level=4,skill_level={}},
	{job=2,level=5,skill_level={}},
	{job=2,level=6,skill_level={[6001]=1,[6002]=1,[6003]=1,[6004]=1,[6005]=1}},
	{job=2,level=7,skill_level={[6001]=1,[6002]=1,[6003]=1,[6004]=1,[6005]=1}},
	{job=2,level=8,skill_level={[6001]=1,[6002]=1,[6003]=1,[6004]=1,[6005]=1}},
	{job=2,level=9,skill_level={[6001]=1,[6002]=1,[6003]=1,[6004]=1,[6005]=1}},
	{job=2,level=10,skill_level={[6001]=1,[6002]=1,[6003]=1,[6004]=1,[6005]=1}},
	{job=2,level=11,skill_level={[6001]=2,[6002]=2,[6003]=2,[6004]=2,[6005]=2}},
	{job=2,level=12,skill_level={[6001]=2,[6002]=2,[6003]=2,[6004]=2,[6005]=2}},
	{job=2,level=13,skill_level={[6001]=2,[6002]=2,[6003]=2,[6004]=2,[6005]=2}},
	{job=2,level=14,skill_level={[6001]=2,[6002]=2,[6003]=2,[6004]=2,[6005]=2}},
	{job=2,level=15,skill_level={[6001]=2,[6002]=2,[6003]=2,[6004]=2,[6005]=2}},
	{job=2,level=16,skill_level={[6001]=3,[6002]=3,[6003]=3,[6004]=3,[6005]=3}},
	{job=2,level=17,skill_level={[6001]=3,[6002]=3,[6003]=3,[6004]=3,[6005]=3}},
	{job=2,level=18,skill_level={[6001]=3,[6002]=3,[6003]=3,[6004]=3,[6005]=3}},
	{job=2,level=19,skill_level={[6001]=3,[6002]=3,[6003]=3,[6004]=3,[6005]=3}},
	{job=2,level=20,skill_level={[6001]=3,[6002]=3,[6003]=3,[6004]=3,[6005]=3}},
	{job=2,level=21,skill_level={[6001]=4,[6002]=4,[6003]=4,[6004]=4,[6005]=4}},
	{job=2,level=22,skill_level={[6001]=4,[6002]=4,[6003]=4,[6004]=4,[6005]=4}},
	{job=2,level=23,skill_level={[6001]=4,[6002]=4,[6003]=4,[6004]=4,[6005]=4}},
	{job=2,level=24,skill_level={[6001]=4,[6002]=4,[6003]=4,[6004]=4,[6005]=4}},
	{job=2,level=25,skill_level={[6001]=4,[6002]=4,[6003]=4,[6004]=4,[6005]=4}},
	{job=2,level=26,skill_level={[6001]=5,[6002]=5,[6003]=5,[6004]=5,[6005]=5}},
	{job=2,level=27,skill_level={[6001]=5,[6002]=5,[6003]=5,[6004]=5,[6005]=5}},
	{job=2,level=28,skill_level={[6001]=5,[6002]=5,[6003]=5,[6004]=5,[6005]=5}},
	{job=2,level=29,skill_level={[6001]=5,[6002]=5,[6003]=5,[6004]=5,[6005]=5}},
	{job=2,level=30,skill_level={[6001]=5,[6002]=5,[6003]=5,[6004]=5,[6005]=5}},
	{job=3,level=1,skill_level={}},
	{job=3,level=2,skill_level={}},
	{job=3,level=3,skill_level={}},
	{job=3,level=4,skill_level={}},
	{job=3,level=5,skill_level={}},
	{job=3,level=6,skill_level={[6031]=1,[6032]=1,[6033]=1,[6034]=1,[6035]=1}},
	{job=3,level=7,skill_level={[6031]=1,[6032]=1,[6033]=1,[6034]=1,[6035]=1}},
	{job=3,level=8,skill_level={[6031]=1,[6032]=1,[6033]=1,[6034]=1,[6035]=1}},
	{job=3,level=9,skill_level={[6031]=1,[6032]=1,[6033]=1,[6034]=1,[6035]=1}},
	{job=3,level=10,skill_level={[6031]=1,[6032]=1,[6033]=1,[6034]=1,[6035]=1}},
	{job=3,level=11,skill_level={[6031]=2,[6032]=2,[6033]=2,[6034]=2,[6035]=2}},
	{job=3,level=12,skill_level={[6031]=2,[6032]=2,[6033]=2,[6034]=2,[6035]=2}},
	{job=3,level=13,skill_level={[6031]=2,[6032]=2,[6033]=2,[6034]=2,[6035]=2}},
	{job=3,level=14,skill_level={[6031]=2,[6032]=2,[6033]=2,[6034]=2,[6035]=2}},
	{job=3,level=15,skill_level={[6031]=2,[6032]=2,[6033]=2,[6034]=2,[6035]=2}},
	{job=3,level=16,skill_level={[6031]=3,[6032]=3,[6033]=3,[6034]=3,[6035]=3}},
	{job=3,level=17,skill_level={[6031]=3,[6032]=3,[6033]=3,[6034]=3,[6035]=3}},
	{job=3,level=18,skill_level={[6031]=3,[6032]=3,[6033]=3,[6034]=3,[6035]=3}},
	{job=3,level=19,skill_level={[6031]=3,[6032]=3,[6033]=3,[6034]=3,[6035]=3}},
	{job=3,level=20,skill_level={[6031]=3,[6032]=3,[6033]=3,[6034]=3,[6035]=3}},
	{job=3,level=21,skill_level={[6031]=4,[6032]=4,[6033]=4,[6034]=4,[6035]=4}},
	{job=3,level=22,skill_level={[6031]=4,[6032]=4,[6033]=4,[6034]=4,[6035]=4}},
	{job=3,level=23,skill_level={[6031]=4,[6032]=4,[6033]=4,[6034]=4,[6035]=4}},
	{job=3,level=24,skill_level={[6031]=4,[6032]=4,[6033]=4,[6034]=4,[6035]=4}},
	{job=3,level=25,skill_level={[6031]=4,[6032]=4,[6033]=4,[6034]=4,[6035]=4}},
	{job=3,level=26,skill_level={[6031]=5,[6032]=5,[6033]=5,[6034]=5,[6035]=5}},
	{job=3,level=27,skill_level={[6031]=5,[6032]=5,[6033]=5,[6034]=5,[6035]=5}},
	{job=3,level=28,skill_level={[6031]=5,[6032]=5,[6033]=5,[6034]=5,[6035]=5}},
	{job=3,level=29,skill_level={[6031]=5,[6032]=5,[6033]=5,[6034]=5,[6035]=5}},
	{job=3,level=30,skill_level={[6031]=5,[6032]=5,[6033]=5,[6034]=5,[6035]=5}},
	{job=4,level=1,skill_level={}},
	{job=4,level=2,skill_level={}},
	{job=4,level=3,skill_level={}},
	{job=4,level=4,skill_level={}},
	{job=4,level=5,skill_level={}},
	{job=4,level=6,skill_level={[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1}},
	{job=4,level=7,skill_level={[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1}},
	{job=4,level=8,skill_level={[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1}},
	{job=4,level=9,skill_level={[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1}},
	{job=4,level=10,skill_level={[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1}},
	{job=4,level=11,skill_level={[6011]=2,[6012]=2,[6013]=2,[6014]=2,[6015]=2}},
	{job=4,level=12,skill_level={[6011]=2,[6012]=2,[6013]=2,[6014]=2,[6015]=2}},
	{job=4,level=13,skill_level={[6011]=2,[6012]=2,[6013]=2,[6014]=2,[6015]=2}},
	{job=4,level=14,skill_level={[6011]=2,[6012]=2,[6013]=2,[6014]=2,[6015]=2}},
	{job=4,level=15,skill_level={[6011]=2,[6012]=2,[6013]=2,[6014]=2,[6015]=2}},
	{job=4,level=16,skill_level={[6011]=3,[6012]=3,[6013]=3,[6014]=3,[6015]=3}},
	{job=4,level=17,skill_level={[6011]=3,[6012]=3,[6013]=3,[6014]=3,[6015]=3}},
	{job=4,level=18,skill_level={[6011]=3,[6012]=3,[6013]=3,[6014]=3,[6015]=3}},
	{job=4,level=19,skill_level={[6011]=3,[6012]=3,[6013]=3,[6014]=3,[6015]=3}},
	{job=4,level=20,skill_level={[6011]=3,[6012]=3,[6013]=3,[6014]=3,[6015]=3}},
	{job=4,level=21,skill_level={[6011]=4,[6012]=4,[6013]=4,[6014]=4,[6015]=4}},
	{job=4,level=22,skill_level={[6011]=4,[6012]=4,[6013]=4,[6014]=4,[6015]=4}},
	{job=4,level=23,skill_level={[6011]=4,[6012]=4,[6013]=4,[6014]=4,[6015]=4}},
	{job=4,level=24,skill_level={[6011]=4,[6012]=4,[6013]=4,[6014]=4,[6015]=4}},
	{job=4,level=25,skill_level={[6011]=4,[6012]=4,[6013]=4,[6014]=4,[6015]=4}},
	{job=4,level=26,skill_level={[6011]=5,[6012]=5,[6013]=5,[6014]=5,[6015]=5}},
	{job=4,level=27,skill_level={[6011]=5,[6012]=5,[6013]=5,[6014]=5,[6015]=5}},
	{job=4,level=28,skill_level={[6011]=5,[6012]=5,[6013]=5,[6014]=5,[6015]=5}},
	{job=4,level=29,skill_level={[6011]=5,[6012]=5,[6013]=5,[6014]=5,[6015]=5}},
	{job=4,level=30,skill_level={[6011]=5,[6012]=5,[6013]=5,[6014]=5,[6015]=5}},
	{job=5,level=1,skill_level={}},
	{job=5,level=2,skill_level={}},
	{job=5,level=3,skill_level={}},
	{job=5,level=4,skill_level={}},
	{job=5,level=5,skill_level={}},
	{job=5,level=6,skill_level={[6041]=1,[6042]=1,[6043]=1,[6044]=1,[6045]=1}},
	{job=5,level=7,skill_level={[6041]=1,[6042]=1,[6043]=1,[6044]=1,[6045]=1}},
	{job=5,level=8,skill_level={[6041]=1,[6042]=1,[6043]=1,[6044]=1,[6045]=1}},
	{job=5,level=9,skill_level={[6041]=1,[6042]=1,[6043]=1,[6044]=1,[6045]=1}},
	{job=5,level=10,skill_level={[6041]=1,[6042]=1,[6043]=1,[6044]=1,[6045]=1}},
	{job=5,level=11,skill_level={[6041]=2,[6042]=2,[6043]=2,[6044]=2,[6045]=2}},
	{job=5,level=12,skill_level={[6041]=2,[6042]=2,[6043]=2,[6044]=2,[6045]=2}},
	{job=5,level=13,skill_level={[6041]=2,[6042]=2,[6043]=2,[6044]=2,[6045]=2}},
	{job=5,level=14,skill_level={[6041]=2,[6042]=2,[6043]=2,[6044]=2,[6045]=2}},
	{job=5,level=15,skill_level={[6041]=2,[6042]=2,[6043]=2,[6044]=2,[6045]=2}},
	{job=5,level=16,skill_level={[6041]=3,[6042]=3,[6043]=3,[6044]=3,[6045]=3}},
	{job=5,level=17,skill_level={[6041]=3,[6042]=3,[6043]=3,[6044]=3,[6045]=3}},
	{job=5,level=18,skill_level={[6041]=3,[6042]=3,[6043]=3,[6044]=3,[6045]=3}},
	{job=5,level=19,skill_level={[6041]=3,[6042]=3,[6043]=3,[6044]=3,[6045]=3}},
	{job=5,level=20,skill_level={[6041]=3,[6042]=3,[6043]=3,[6044]=3,[6045]=3}},
	{job=5,level=21,skill_level={[6041]=4,[6042]=4,[6043]=4,[6044]=4,[6045]=4}},
	{job=5,level=22,skill_level={[6041]=4,[6042]=4,[6043]=4,[6044]=4,[6045]=4}},
	{job=5,level=23,skill_level={[6041]=4,[6042]=4,[6043]=4,[6044]=4,[6045]=4}},
	{job=5,level=24,skill_level={[6041]=4,[6042]=4,[6043]=4,[6044]=4,[6045]=4}},
	{job=5,level=25,skill_level={[6041]=4,[6042]=4,[6043]=4,[6044]=4,[6045]=4}},
	{job=5,level=26,skill_level={[6041]=5,[6042]=5,[6043]=5,[6044]=5,[6045]=5}},
	{job=5,level=27,skill_level={[6041]=5,[6042]=5,[6043]=5,[6044]=5,[6045]=5}},
	{job=5,level=28,skill_level={[6041]=5,[6042]=5,[6043]=5,[6044]=5,[6045]=5}},
	{job=5,level=29,skill_level={[6041]=5,[6042]=5,[6043]=5,[6044]=5,[6045]=5}},
	{job=5,level=30,skill_level={[6041]=5,[6042]=5,[6043]=5,[6044]=5,[6045]=5}},
}

return data
