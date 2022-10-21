require "split"

function getTabel( tab,key )
	local st = tab[key]
	if st == nil then
		st = {}
		tab[key] = st
	end
	return st
end

local _text = [[
<?php
$Platform_Reward = array(
%s
);
]]

local _plat = [[
'%s' => array(
%s
),]]

local fname = "F:/cbcq/server/bin/cfgdata/platform_reward.cfg"

local start = false

local platdata = {}

function genData( line )
    if start == false then
        local have = string.find(line,"%[data%]")
        if have ~= nil then
            start = true
        end
        return
    end

    local vec = Split(line,'\t')

    local plt = vec[1]
    local group = vec[2]
    local reward = vec[4]

    local rt = getTabel(platdata,plt)
    rt[#rt + 1] = string.format('\t"%s"=>"%s"',group,reward);
end

function printFile()
	local stab = {}

	for k,v in pairs(platdata) do
		local str = table.concat( v, ",\n")
		stab[#stab+1] = string.format(_plat,k,str)
	end

	local str = table.concat( stab, ",\n")
	print(string.format(_text,str))
end

readFileLine(fname,genData)
printFile()

