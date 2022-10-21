require "class"
ppp = require "persent"

-- 分割字符串 p1:字符串 p2:分隔符
function Split(szFullString, szSeparator)  
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

function SplitPrint(str,sep)
    local tab = Split(str,sep)
    for i,v in ipairs(tab) do
        print(v)
    end
end

-- 分割字符串2 p1:string p2:分隔符1 优先 p2:分割符2
function Split2(str,sp1,sp2)
	local d1 = Split(str,sp1)
	for i,v in ipairs(d1) do
  		local d2 = Split(v,sp2)
  		print(table.concat( d2, "  "))
	end
end

-- 分割打印
function SplitTabAndP(tab,sp1 )
	for i,v in ipairs(tab) do
		local d = Split(v,sp1)
		print(table.concat( d, " "))
	end
end

-- 模式匹配
function Match(str,pat)
	local data = {}
	for s in string.gmatch(str,pat) do
		if s ~= nil and s ~= "" then
			table.insert(data,s)
		end
	end
	return data
end

function split_each_char( str )
  local vec = {}

  local i = 1
  while true do
    local c = string.sub(str,i,i)
    local b = string.byte(c)

    if b > 128 then
      vec[#vec+1] = string.sub(str,i,i+2)
      i = i + 3
    else
      vec[#vec+1] = c
      i = i + 1
    end

    if i>#str then
      break
    end
  end
  return vec
end

function parse_int_vector( str )
  local d = Match(str,"%d+")
  for i,v in ipairs(d) do
    d[i] = tonumber(v)
  end
  return d
end

function printTable( tab )
  print(ppp.block(tab))
end

-- 打印2层 table lk:链接符
function printTable2( tab,lk )
	for i,v in ipairs(tab) do
		print(table.concat( v, lk))
	end
end

-- 处理文件行
function readFileLine( fname,func )
    local handle = io.open(fname,"r")
    repeat
        line = handle:read('*l')
        if line ~= nil then
            func(line)
        end
    until line == nil
    handle:close()
end

function string_to_char_vec(str,func)
  local vec = {}

  for i=1,string.len(str) do
	if func then
		vec[i] = func(string.sub(str,i,i))
	else
		vec[i] = string.sub(str,i,i)
	end
  end

  return vec
end

function gcSubTable( tab,key )
  local t = tab[key]
  if t then
    return t
  end
  t = {}
  tab[key] = t
  return t
end

function timeStampTodate( tm )
  return os.date("%Y-%m-%d %H:%M:%S",tm)
end

function haveStr( str,mat )
    local x = string.find(str,mat)
    return x ~= nil
end

myfile = class("myfile")

function myfile:open( fname,opt )
    self._hand = io.open(fname,opt)
end

function myfile:write( str )
    self._hand:write(str)
end

function myfile:close()
    self._hand:close()
end