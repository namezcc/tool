require "Math"

local list = {
    _size = 0,
    _head = nil,
    _tail = nil,
}

function list:push_back( t )
    local node = {
        _data = t
    }

    if self._head == nil then
        self._head = node
        self._tail = node
    else
        self._tail._next = node
        node._prev = self._tail
        self._tail = node
    end
    self._size = self._size + 1
end

function list:pop_front()
    if self._head ~= nil then
        local node = self._head
        self._head = node._next
        if self._head == nil then
            self._tail = nil
        end
        self._size = self._size - 1
        return node
    end
end

require "split"

-- local testtab = {
--     1,2,2,4,5,6,2,4,6,2
-- }

-- for i,v in ipairs(testtab) do
--     if v == 2 then
--         table.remove(testtab,i)
--     end
-- end

-- printTable(testtab)

function get_chr_index(tpat)
    local index = {}
    local l = #tpat
	local i = 1
    while i <= l do
        if tpat[i+1] == "*" then
            i = i + 2
        else
            index[#index + 1] = i
			i = i + 1
        end
    end
    return index
end

function match_for(s,p,cidx)
	local ls = #s
	local lp = #p
	local arrcti = {1}
	local arrpi = {1}
	local mod = {}
	local lsi = 1

	while true do
		local cpti = arrcti[lsi]
		local ci = cidx[cpti] or (lp+1)
		local pi = arrpi[lsi]

		for i = lsi, ls do
			local sc = s[i]
			local cc = p[ci]
			local pc = p[pi]
			local oldm = mod[i]
			if oldm == nil then
				mod[i] = 0
			end
	
			if oldm == nil and (sc == cc or cc == ".") then
				cpti = cpti + 1
				pi = ci + 1
				ci = cidx[cpti] or (lp+1)
				arrcti[i+1] = cpti
				arrpi[i+1] = pi

				if i == ls and cpti > #cidx then
					return true
				end
			else
				mod[i] = 1
				local res = false
				while pi < ci do
					if sc == pc or pc == "." then
						res = true

						if i == ls then
							if cpti > #cidx then
								return true
							else
								res = false
							end
						end
						break
					end
					pi = pi + 2
					pc = p[pi]
				end

				if res then
					arrcti[i+1] = cpti
					arrpi[i+1] = pi
				else
					for j = #mod, 1,-1 do
						mod[j+1] = nil
						if mod[j] == 0 then
							lsi = j
							break
						elseif j == 1 then
							return false
						end
					end
					break
				end
			end
		end
	end
	return false
end

function isMatch( s,p )
    local tstr = string_to_char_vec(s)
    local tpat = string_to_char_vec(p)

    -- local ls = #tstr
    -- local lp = #tpat
    local cidx = get_chr_index(tpat)

	return match_for(tstr,tpat,cidx)
end

function show_match( s,p )
    print(s,p,isMatch(s,p))
end

local tarr = {
    {"aaa","a*a"},
    {"aaaabbbb",".*.*.*.*a.*.*"},
    {"bbcde",".*bcde"},
    {"aaaaaaa","ca*aaa*a*"},
    {"bbacedb","a*ba*c*d*b"},
    {"bbacedb","a*.a*c*.*d*"},
    {"bbacedb","a*bbacedb"},
    {"aa","a*"},
    {"mississippi","mis*is*ip*."},
    {"ab",".*c"},
    {"aaa","ab*a*c*a"},
}

-- for i,v in ipairs(tarr) do
--     show_match(v[1],v[2])
-- end

-- show_match("ab",".*c")

-- 11  9   22
-- 12  11  22
-- 18  11  22
-- 19  11  22

-- 123
-- 121
-- 135

-- 999     989     1001

-- 1221    1111    1331

-- 1991    1881    2002

-- 1234    1221    1331

-- 12321

-- 99999   99899   100001

-- 98765   98789   97779

-- 98798   98789   98889

-- 191     181     202

-- 292     282     303

-- 2000    1991    2002
-- 9000    8998    9009

-- xxx | xxx

-- 19001   19091   18981

-- 97999   98089

-- 98989   99099   98889

-- 99099   99199   98989

-- 98089   98189   97979

-- 95059

-- 95959

-- 18981   19091   18881

-- 17981   17971   18081

-- 17051   17071   16961

-- 19991   20002   19991

-- 20002   19991   10101

-- 9889    9779    9999

-- 1000    999     1001    1111    

-- 191     202      181
-- 1991    2002    1881

-- 1881    1991    1771

-- 1001    999

-- 15051   15151   14941

-- 15951   15851   16061

-- 108999  108801  109901
-- 91  88  99
-- 19  11  22

    -- x9x
    -- x99x
    -- x999x
    -- x0x
    -- x00x
    -- x000x



function roll_up_num( n,ton )
    if n == ton then
        return 10
    else
        return math.fmod(10 - n + ton,10)
    end
end

function roll_down_num( n,ton )
    if n == ton then
        return 10
    else
        return math.fmod(10 - ton + n,10)
    end
end

function get_num( str )
    local s = string_to_char_vec(str,tonumber)
    local l = #s
    local mid = l//2
    if mid == 0 then
        return s[1] - 1
    end

    local index = mid + 1
    local lineidx = index

    for i = index,l do
        if s[i] ~= s[l+1-i] then
            index = i
            break
        end

        if lineidx + 1 == i and s[i] == s[i-1] then
            lineidx = i - 1
        end
    end

    local fi = l + 1 - index

    local roll = 0
    local rup = 0x1
    local rdown = 0x2

    local cr = false
    local ldiff = index - lineidx
	if l == 2 then
		roll = rup | rdown
    elseif ldiff == 1 or ldiff < 0 then
        cr = true
    elseif ldiff == 0 then
        if math.fmod(l,2) == 0 then
			if s[index] == s[fi] then
				cr = true
			end
        else
            cr = true
        end
    end

    if cr then
        if s[lineidx] == 0 then
            roll = rdown
        elseif s[lineidx] == 9 then
            roll = rup
        end
    end


    if roll == 0 then
        if index == mid + 1 then
            s[index] = s[index] - 1
            s[fi] = s[index]
        else
            for i=index,l do
                s[index] = s[l-index+1]
            end
        end
    else
        if lineidx == l then
            index = lineidx
        elseif lineidx >= index then
            index = lineidx + 1
        end

        
        local uptab = {}
        local downtab = {}
        local tidx = index
        while true do
            local upn = 0
            local downn = 0

            local fi = l-tidx+1
            local ton = s[fi]

            if (roll & rup) > 0 and tidx - lineidx <= 1 then
                if fi == 1 and ton == 9 then
                    ton = 1
                end
                upn = roll_up_num(s[tidx],ton)
                if ton == s[fi] and s[tidx]+upn >= 10 then
                    upn = upn + 1
                end
            else
                upn = roll_up_num(s[tidx],ton)
            end

			ton = s[fi]
            if (roll & rdown) > 0 and tidx - lineidx <= 1 then
                if fi == 1 and ton == 1 then
                    ton = 9
                end
                downn = roll_down_num(s[tidx],ton)
                if ton == s[fi] and s[tidx]-downn < 0 then
                    downn = downn + 1
                end
            else
                downn = roll_down_num(s[tidx],ton)
            end

            uptab[#uptab+1] = upn
            downtab[#downtab+1] = downn

            if #uptab > 1 then
                if s[tidx] + upn < 10 then
                    uptab[#uptab-1] = uptab[#uptab-1] + 1
                end
                if s[tidx] - downn >= 0 then
                    downtab[#downtab-1] = downtab[#downtab-1] - 1
                end
                if uptab[#uptab-1] ~= downtab[#downtab-1] then
                    break
                end
            end

            if upn >= 10 or downn >= 10 then
                break
            elseif math.abs(upn-downn) > 1 then
                break
            end

            if tidx == l then
                break
            else
                tidx = tidx + 1
                uptab[#uptab] = upn - 1
                downtab[#downtab] = downn + 1
            end
        end

        local ln = -downtab[1]
        for i=1,#uptab do
            if uptab[i] < downtab[i] then
                ln = uptab[1]
                break
            elseif uptab[i] > downtab[i] then
                break
            end
        end

        if ln < 0 then
            local ldownn = -ln
            local add = math.fmod(ldownn,10)
            local ext = ldownn >= 10 and 1 or 0

            s[index] = s[index] - add
            if s[index] < 0 then
                s[index] = 10 + s[index]
                ext = ext + 1
            end
            if ext > 0 then
                for i=index - 1,1,-1 do
                    if s[i] == 0 then
                        s[i] = 9
                    else
                        s[i] = s[i] - 1
                        break
                    end
                end
                if s[1] == 0 then
                    s[1] = 9
					s[index] = 9
                    s[l] = nil
                    l=l-1
                end
            end
            for i=index+1,l do
                s[i] = s[l-i+1]
            end
        else
            local lupn = ln
            local add = math.fmod(lupn,10)
            local ext = lupn >= 10 and 1 or 0

            s[index] = s[index] + add
            if s[index] >= 10 then
                s[index] = s[index] - 10
                ext = ext + 1
            end
            if ext > 0 then
                for i=index-1,1,-1 do
                    if s[i] == 9 then
                        s[i] = 0
                    else
                        s[i] = s[i] + 1
                        break
                    end
                end
                if s[1] == 0 then
                    s[1] = 1
                    s[l+1] = 1
					s[index] = 0
                    l = l+1
                end
            end
            for i=index+1,l do
                s[i] = s[l-i+1]
            end
        end
    end
    return table.concat( s, "")
end

function get_diff(s1,s2)
	local l1 = #s1
	local l2 = #s2
	local res = {}
	local smax,smin = nil,nil
	if l1 > l2 then
		smax,smin = s1,s2
	elseif l1 < l2 then
		smax,smin = s2,s1
	else
		for i = 1, l1 do
			if s1[i] > s2[i] then
				smax,smin = s1,s2
				break
			elseif s1[i] < s2[i] then
				smax,smin = s2,s1
				break
			end
		end
	end

	local lmax,lmin = #smax,#smin

	for i = 1, lmax do
		local im = lmin - lmax + i
		if im <= 0 then
			res[#res+1] = smax[i]
		else
			local diff = smax[i] - smin[im]
			if diff > 0 then
				res[#res+1] = diff
			elseif diff == 0 then
				if #res > 0 then
					res[#res+1] = diff
				end
			else
				for j = #res, 1,-1 do
					res[j] = res[j] - 1
					if res[j] >= 0 then
						break
					else
						res[j] = 9
					end
				end
				res[#res+1] = 10 + diff
			end
		end
	end

	local zi = 0
	while res[zi+1] == 0 do
		zi = zi + 1
	end
	if zi > 0 then
		local lr = #res
		for i = zi, lr - 1 do
			res[i-zi+1] = res[i+1]
		end
		for i = lr, lr-zi+1,-1 do
			res[i] = nil
		end
	end
	return res
end

function getnum_new(str)
	local org = string_to_char_vec(str,tonumber)
	local s = string_to_char_vec(str,tonumber)
	local s2 = string_to_char_vec(str,tonumber)
    local l = #s
    local mid = l//2
    if mid == 0 then
		s[1] = s[1] - 1
        return s
    end
    local index = mid + 1
    for i = index,l do
        if s[i] ~= s[l+1-i] then
            index = i
            break
        end
    end
	local fi = l - index + 1
	-- up
	local add = 1
	if fi ~= index then
		add = roll_up_num(s[index],s[fi])
	end
	for i = index, 1,-1 do
		local n = s[i]
		n = n + add
		if n >= 10 then
			n = n - 10
			add = 1
			s[i] = n
		else
			s[i] = n
			break
		end
	end
	for i = index, l do
		s[i] = s[l-i+1]
	end
	if s[1] == 0 then
		s[1] = 1
		s[l+1] = 1
	end
	-- down
	add = 1
	if fi ~= index then
		add = roll_down_num(s2[index],s2[fi])
	end
	for i = index, 1,-1 do
		local n = s2[i]
		n = n - add
		if n < 0 then
			n = n + 10
			add = 1
			s2[i] = n
		else
			s2[i] = n
			break
		end
	end
	for i = index, l do
		s2[i] = s2[l-i+1]
	end
	if s2[1] == 0 then
		s2[1] = 9
		s2[l] = nil
	end

	local dup = get_diff(s,org)
	local ddown = get_diff(s2,org)

	local lenu,lend = #dup,#ddown
	if lenu == lend then
		for i = 1, lenu do
			if dup[i] > ddown[i] then
				return table.concat(s2,"")
			elseif dup[i] < ddown[i] then
				return table.concat(s,"")
			end
		end
		return table.concat(s2,"")
	elseif lenu > lend then
		return table.concat(s2,"")
	else
		return table.concat(s,"")
	end
end

function show_getnum( str )
    -- print(str,get_num(str))
	print(str,getnum_new(str))
end

local testdata = {
    "11",
    "22",
    "88",
    "99",
    "191",
    "292",
    "898",
    "1991",
    "2992",
    "8998",
    "999",
    "19991",

}

function show_diff(s1,s2)
	local t1 = string_to_char_vec(s1,tonumber)
	local t2 = string_to_char_vec(s2,tonumber)
	local res = get_diff(t1,t2)
	print(table.concat(res,""))
end

-- for i,v in ipairs(testdata) do
--     show_getnum(v)
-- end

-- show_getnum("10")

-- show_diff("16516","13246")

-- print(roll_up_num(0,0))
-- print(roll_down_num(0,0))

local begnum = 500000000
local makenum = begnum
local rate = 0.75

local makeyear = 25
local die = 85

local data = {
    {num = begnum,year = 20}
}

local checkyear = 1000
local showyear = 20

function show_data(y)
    local num = 0
    for k,v in pairs(data) do
        num = num + v.num
    end
    print("year:",y,"num:",num)
end

function runyear()
    for i=1,checkyear do
        local dead,born = {},{}

        for k,v in ipairs(data) do
            if v.year == makeyear then
                born[#born+1] = {num = math.floor(v.num*rate),year=0}
            end
            v.year = v.year + 1
            if v.year >= die then
                dead[#dead+1] = k
            end
        end

        for i=#dead,1,-1 do
            table.remove(data,dead[i])
        end
        for i,v in ipairs(born) do
            data[#data+1] = v
        end

        if math.fmod(i,showyear) == 0 then
            show_data(i)
        end
    end
    show_data(checkyear) 
end

-- runyear()


function terr()
    local x = 1 + bbb
end

function terr2()
    terr()
end

local v1,v2 = xpcall(terr2,debug.traceback)

print(v1)
print(v2)