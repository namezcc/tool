local function split(szFullString, szSeparator)  
    local nFindStartIndex = 1  
    local nSplitIndex = 1  
    local nSplitArray = {}  
    while true do  
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
       if not nFindLastIndex then  
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
        break  
       end  
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
       nSplitIndex = nSplitIndex + 1  
    end  
    return nSplitArray  
end
-- sep 默认值 ":"
local function splite_int_vec(str,sep)
	sep = sep or ":"
	local vec = split(str,sep)

	for i, v in ipairs(vec) do
		vec[i] = tonumber(v)
	end

	return vec
end

local function splite_int_vec2(str,sep1,sep2)
	sep1 = sep1 or "|"
	sep2 = sep2 or ":"

	local vec = split(str,sep1)
	local res = {}
	for _, s2 in ipairs(vec) do
		res[#res+1] = splite_int_vec(s2,sep2)
	end
	return res
end

local function combin_vec2(vec,sep1,sep2)
	sep1 = sep1 or ":"
	sep2 = sep2 or "|"
	local vtemp = {}
	for i, v in ipairs(vec) do
		vtemp[i] = table.concat(v,sep1)
	end
	return table.concat(vtemp,sep2)
end

local function split2(str,sp1,sp2)
    local vec = {}
    local d1 = split(str,sp1)
    for _,v in ipairs(d1) do
		local d2 = split(v,sp2)
		if #d2 == 2 then
			vec[d2[1]] = d2[2]
		else
			vec[#vec+1] = d2
		end
	end
	return vec
end

local function combikv(vec,sep1,sep2)
    local str = ''
    for key, value in pairs(vec) do
        if str == '' then
            str = key..sep1..value
        else
            str = str..sep2..key..sep1..value
        end
    end
    return str
end

local function format_content(str,pam)
	local nstr = str
	if #pam == 1 then
		nstr = string.format(str,pam[1])
	elseif #pam == 2 then
		nstr = string.format(str,pam[1],pam[2])
	elseif #pam == 3 then
		nstr = string.format(str,pam[1],pam[2],pam[3])
	end
	return nstr
end

STRING_UTIL = {
	split = split,
	splite_int_vec = splite_int_vec,
    split2 = split2,
    combikv = combikv,
	splite_int_vec2 = splite_int_vec2,
	combin_vec2 = combin_vec2,
	format_content = format_content,
}