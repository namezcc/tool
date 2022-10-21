require "split"
require "class"
local list = require "list"
-- local datapath = "F:/cbphp/"
local datapath = "."

ACT_INDEX = 1
REM_ACT_INDEX = 1
CELL_AUTO_INDEX = 0
IN_ACTIVE_TICK = 5
TO_LONG_CELL_TICK = IN_ACTIVE_TICK
DEACTIVE_TICK = 50
CASH_ACT_TICK = 4*DEACTIVE_TICK*8
REM_CASH_TICK = 5

local stepread = {}
local up_index = {}
local down_index = {}
local readact = 0
local ly = nil
local step_read_start = false

function push_read_step(n,lname,index,real)
	if step_read_start == false then
		return
	end

	if ly ~= lname or readact ~= ACT_INDEX then
		readact = ACT_INDEX
		ly = lname
		stepread[#stepread+1] = {
			_acti = ACT_INDEX,
			_ly = lname,
			_msg = {},
			_index = {},
		}
	end

	local m = stepread[#stepread]
	-- if not index then
		local msg = n._msg or (n._index..".")
		if real then
			msg = msg..":"
		end
		if n._long_cell then
			msg = msg.."*"
		end
		m._msg[#m._msg+1] = msg
	-- end
	m._index[#m._index+1] = n._index

	if n._long_cell then
		down_index[#down_index+1] = n._index
	else
		up_index[#up_index+1] = n._index
	end
end

function push_down_index(n)
	down_index[#down_index+1] = n._index
end

function show_read_step()
	local fstep = myfile.new()
	local fact = myfile.new()

	fstep:open(datapath.."/step.csv","w")
	fact:open(datapath.."/acts.csv","w")

	fstep:write("[\n")

	for i, v in ipairs(stepread) do
		if #v._msg > 0 then
			local s = table.concat(v._msg," ")
			print(v._ly," ------- ",v._acti)
			print(s)
		end

		local js = table.concat(v._index,",")
		fstep:write("[")
		fstep:write(js)
		fstep:write("]")

		if i ~= #stepread then
			fstep:write(",\n")
		else
			fstep:write("\n")
		end
	end
	stepread = {}

	fstep:write("]\n")
	fstep:close()

	fact:write("[\n")
	fact:write("[")
	fact:write(table.concat(up_index,","))
	fact:write("],\n")
	fact:write("[")
	fact:write(table.concat(down_index,","))
	fact:write("]\n")
	fact:write("]\n")
	fact:close()
end

function dumpCell(mem,lv,fnode,flink)
	lv = lv or 0
	lv = lv + 1

	if fnode == nil then
		fnode = myfile.new()
		flink = myfile.new()
	
		fnode:open(datapath.."/node.csv","w")
		flink:open(datapath.."/link.csv","w")

		fnode:write("id,l,h,long,msg\n")
    	flink:write("s,e,long\n")
	end

    local nodedata = {}
    local linkdata = {}

    for k,n in pairs(mem._testcell) do
        
        local nd = {}

        nd[1] = n._index
        nd[2] = lv
		nd[3] = n._msg and 0 or 1
		nd[4] = n._long_cell and 1 or 0
		nd[5] = n._msg or ""
		nodedata[#nodedata+1] = nd

		for _, lk in pairs(n._link) do
			local ld = {}
			ld[1] = n._index
			ld[2] = lk._n._index
			ld[3] = lk._long_cell and 1 or 0

			linkdata[#linkdata+1] = ld
		end
    end

    for i,v in ipairs(nodedata) do
        fnode:write(table.concat(v, ","))
		fnode:write("\n")
    end

    for i,v in ipairs(linkdata) do
        flink:write(table.concat(v, ","))
		flink:write("\n")
    end

	for i, nm in ipairs(mem._memory) do
		dumpCell(nm,lv,fnode,flink)
	end

	if lv == 1 then
		fnode:close()
		flink:close()
	end
end

function add_act_index(idx)
	if idx then
		ACT_INDEX = ACT_INDEX + idx
	else
		ACT_INDEX = ACT_INDEX + 1
	end
end

function add_rem_act_index()
	REM_ACT_INDEX = REM_ACT_INDEX + 1
end

function is_inactive(n)
	return ACT_INDEX - n._acti < IN_ACTIVE_TICK
end

function is_in_rem_cash(n)
	return ACT_INDEX - n._acti < REM_CASH_TICK
end

function is_in_real_active(n)
	return ACT_INDEX - n._real_acti < DEACTIVE_TICK
end

function is_in_cash_active(n)
	return ACT_INDEX - n._cash_acti < CASH_ACT_TICK
end

function is_deactive(n,checkwait)
	if checkwait == nil and n._touch ~= nil then
		return (ACT_INDEX - n._acti >= DEACTIVE_TICK) or n._touch < n._active_touch
	else
		return ACT_INDEX - n._acti >= DEACTIVE_TICK
	end
end

function is_in_unact(n)
	return n._un_acti > 0 and ACT_INDEX - n._un_acti < DEACTIVE_TICK
end

function set_unact(n)
	n._un_acti = ACT_INDEX
end

function is_link_inactive(lk,wait)
	if wait then
		return ACT_INDEX - lk._waiti < IN_ACTIVE_TICK
	else
		return ACT_INDEX - lk._acti < IN_ACTIVE_TICK
	end
end

function is_useable(lk)
	return lk._acti <= ACT_INDEX
	-- return lk._lv > 1
end

function is_in_long_cell(n)
	local diff = ACT_INDEX - n._acti
	return diff >= TO_LONG_CELL_TICK and diff < DEACTIVE_TICK
end

function link(last,n,index,checklong)
    index = index or n._index

    local l = last._link[index]
	checklong = checklong or last

    if l == nil then
        l = {
            _lv = 0,
			-- _acti = 0,
			_acti = ACT_INDEX, -- + DEACTIVE_TICK,
			_waiti = 0,
            _rem_acti = 0,
            _n = n,
            _long_cell = n._long_cell,
			_link_acti = 0,
        }

		if last._mem ~= n._mem then
			l._acti = 0
		end

		n._belink = n._belink + 1
        if checklong._long_cell == false then
            if n._msg == nil and n._long_cell == false then
				n._active_touch = n._active_touch + 1
            end
        else
            l._from_long_cell = true
        end

        last._link[index] = l
    end

	l._link_acti = ACT_INDEX
    l._lv = l._lv + 2
end

function get_link_lv(lk)
	local lv = lk._lv
	if lk._link_acti == ACT_INDEX then
		lv = lv - 2
	end
	return lv
end

function is_link( beg,n )

    for i,v in pairs(beg._link) do
        if v._n == n then
            return true
        end
    end

    return false
end

function is_link_acts(n,acttab)
	for k, lk in pairs(n._link) do
		if acttab[lk._n._index] ~= nil then
			return true
		end
	end
end

function is_touch( lk,fix )
	local act = lk._rem_acti == REM_ACT_INDEX
	if fix and is_deactive(lk) == false then
		act = true
	end
    return act
end

function is_touch_half(n,fix)
	local act = n._rem_acti == REM_ACT_INDEX
	if fix and is_deactive(n) == false then
		act = true
	end
    return act and n._active_touch > 1 and n._touch > 0
end

function is_long_touch( n,fix )
	local act = n._rem_acti == REM_ACT_INDEX
	if fix and is_deactive(n) == false then
		act = true
	end
    return act and n._long_touch > 0
end

function get_act_key( act,n )
    local key = tostring(n._index)
    for i,v in ipairs(act) do
		key = key.."-"..v._index
    end
    return key
end

function rem_touch_cell(lk,fix)
    local n = lk._n

	local change = lk._rem_acti ~= REM_ACT_INDEX
	if fix and is_deactive(lk) == false then
		change = false
	end

    if change then
		local nc = n._rem_acti ~= REM_ACT_INDEX
		if fix and is_deactive(n) == false then
			nc = false
		end

        if nc then
            n._rem_acti = REM_ACT_INDEX
            n._touch = 0
            n._long_touch = 0
        end

		lk._rem_acti = REM_ACT_INDEX
        if lk._from_long_cell then
            n._long_touch = n._long_touch + 1
        else
            n._touch = n._touch + 1
        end
    end
    
    return n._touch >= n._active_touch
end

local memroy = class("memroy")

function memroy:ctor(tp)
	self._type = tp
    self._testcell = {}
	self._read_msg = {}
    self._cell = {}
    self._msg = {}
	self._msg_read = {}
    self._msg_acti = 0
    self._rem_msg = {}
    self._msg_func = nil
	self._long_act_cell = {}
	self._last_act = {}
    self._cash = list.new()
	self._center_mem = nil
	self._long_cell = nil
	self._group_cash = {}
	self._rem_cash = {}
	self._memory = {}
	self._long_node = {}
	self._act_cash = {}
	self._last_real = true
end

function memroy:push_read_msg(s,real,long)
	if not long and #self._read_msg > 0 and self._read_msg[#self._read_msg]._real == false then
		return
	end

	self._read_msg[#self._read_msg+1] = {
		_s = s,
		_real = real,
	}
end

function memroy:set_center_mem(mem)
	self._center_mem = mem
end

function memroy:set_msg_func( func )
    self._msg_func = func
end

function memroy:cell_msg( m,rem )
    if rem then
        self._rem_msg[#self._rem_msg+1] = m
    else
        self._msg_acti = ACT_INDEX
        self._msg[#self._msg+1] = m

    end
end

function memroy:push_cash( msg )
    self._cash:push_back(msg)
    if self._cash:size() > 10 then
        self._cash:pop_front()
    end
end

function memroy:do_msg(rem)
    if rem == nil and (#self._msg > 0 or #self._msg_read > 0) then
        if ACT_INDEX - self._msg_acti < IN_ACTIVE_TICK then
            return
        end

        if self._msg_func and #self._msg > 0 then
            -- self._msg_func(self._msg,false)
			-- self:push_cash(self._msg)
        	self._msg = {}
        end
		
		if self._msg_func and #self._msg_read > 0 then
            self._msg_func(self._msg_read,false,"read",self._msg_acti)
			self._msg_read = {}
        end
    end

    if #self._rem_msg > 0 then
        -- if self._msg_func then
        --     self._msg_func(self._rem_msg,true,"rem",ACT_INDEX)
        -- end
        self:push_cash(self._rem_msg)
        self._rem_msg = {}
    end
end

function memroy:show_cell()
	print("mem type ------",self._type,"-------------")
    for i,v in pairs(self._testcell) do
        print("index:",v._index,"msg:",(v._msg or ""),"bl:",v._belink,v._active_touch,(v._long_cell and "long" or ""))

        for k,lk in pairs(v._link) do
            local ln = lk._n
            -- print("\tkey:",k,"index:",ln._index,(ln._msg or ""))
            print("\tindex:",ln._index,(ln._msg or ""))
        end

        print("")
    end
end

function memroy:is_self_cell(n)
	return n._mem == self
end

function memroy:cell()
    CELL_AUTO_INDEX = CELL_AUTO_INDEX + 1

	local mem = self
    local c =  {
        _msg = nil,
        _link = {},
        _acti = ACT_INDEX,          --活动轮次
		_real_acti = ACT_INDEX,
		_cash_acti = 0,
		_un_acti = 0,				--抑制时间
		_rem_acti = 0,
        _belink = 0,        --被连接数
		_active_touch = 0,	--触发需要激活次数
        _touch = 0,         --激活次数
        _long_touch = 0,
		_real_touch = 0,
        _index = CELL_AUTO_INDEX,
        _long_cell = false,
		_mem = mem,
    }

    c.do_msg = function(_,fix)
        if c._msg then
            mem:cell_msg(c._msg,fix)
        end
    end

	c.push_long_cell = function (_,from)
		c._mem:push_long_cell(c,from)
	end

    self._testcell[c._index] = c
    return c
end

function memroy:get_root_msg( v )
    local n = self._cell[v]
    if n == nil then
        n = self:cell()
        n._msg = v
        self._cell[v] = n
    end
    return n
end

function memroy:get_link_cell( n,index,long )
    local lk = n._link[index]
    if lk == nil then
        local c = self:cell()
        if long then
            c._acti = 0
            c._long_cell = true
        end
		self:set_active(c,true)
        return c
    end
	self:set_active(lk._n,true)
    return lk._n
end

function memroy:set_active( n,real )
    n._acti = ACT_INDEX
    n._touch = n._active_touch
	if real then
		n._real_acti = ACT_INDEX

		if self._center_mem == nil then
			n._cash_acti = ACT_INDEX
		end
	end
end

function memroy:get_down_long(n)
	for k, lk in pairs(n._link) do
		if lk._long_cell and self:is_self_cell(lk._n) == false then
			return lk._n
		end
	end
end

function memroy:make_mem(v,lastact,longcell,longlk,real)

    local n = self:get_root_msg(v)

	push_read_step(n,self._type,false,real)

	self:set_active(n,real)

	self._msg_acti = ACT_INDEX
	
    local act = {}
    act[#act+1] = n

	if self._center_mem == nil and longlk == nil and longcell ~= nil then
		local index = get_act_key({},n)
		longlk = self:get_link_cell(longcell,index,true)
		link(longcell,longlk,index)
		link(longlk,n)
	end

    if #lastact > 0 then
        local actindex = get_act_key(lastact,n)
        local lk = self:get_link_cell(lastact[1],actindex)
        link(lk,n)

		local downlong = self:get_down_long(n)
		if downlong then
			link(lk,downlong)
		end
		
        if longlk then
            link(longlk,lk)
        end

        for i,lc in ipairs(lastact) do
            link(lc,lk,actindex)
        end
		act[#act+1] = lk
    end

	self._msg_read[#self._msg_read+1] = v
	self:remem(v)

	if real then
		self._group_cash[#self._group_cash+1] = act[#act]
	end
	return act,longlk
end

function memroy:set_last_act(act)
	self._last_act = act
end

function memroy:get_last_act()
	local act = {}
	for i, n in ipairs(self._last_act) do
		if is_inactive(n) then
			act[#act+1] = n
		end
	end
	return act
end

function memroy:set_long_cell(n)
	self._long_cell = n

	if self._center_mem and #self._group_cash > 0 then

		local lastgroup = self._group_cash
		self._group_cash = {}

		local cn = self._center_mem:get_root_msg(n._index)

		--已经连接
		if cn._link[n._index] ~= nil then
			local haveact = false
			local uplk = nil
			for k, lk in pairs(n._link) do
				if lk._n._msg == n._index then
					uplk = lk
				end
				
				if (lk._n._msg == nil or self:is_self_cell(lk._n) == false) and is_deactive(lk) == false then
					haveact = true
					break
				end
			end
			if haveact == false and uplk then
				self:touch_cell(uplk)
				self:push_node_msg(n,uplk._n)
			end
			return
		end

		self:push_node_msg(n,cn)
		local lk = self:get_link_cell(cn,n._index,true)
		link(cn,lk,n._index)
		for i, gn in ipairs(lastgroup) do
			link(lk,gn)
		end
	end
end

function memroy:get_long_cell()
	local long = nil
	if self._long_cell ~= nil then
		if is_in_long_cell(self._long_cell) then
			long = self._long_cell
		else
			self._long_cell = nil
		end
	end
	return long
end

function memroy:set_long_link_cell(n)
	self._last_long_cell = n
end

function memroy:get_long_link_cell()
	if self._last_long_cell == nil then
		return nil
	end

	if is_inactive(self._last_long_cell) then
		return self._last_long_cell
	else
		return nil
	end
end

function memroy:read_msg( str,idx )
    local word = Split(str," ")

    for i,w in ipairs(word) do
        local vec = split_each_char(w)

		if i > 1 then
			add_act_index(TO_LONG_CELL_TICK)
			self:run()
		end

		local lastact = self:get_last_act()
		local longcell = self:get_long_cell()
        local longlk = self:get_long_link_cell()
		

        for i,s in ipairs(vec) do
            lastact,longlk = self:make_mem(s,lastact,longcell,longlk,true)
        end

		self:set_last_act(lastact)
		self:set_long_link_cell(longlk)
    end

	if idx then
		add_act_index(idx)
		self:run()
	else
		add_act_index(TO_LONG_CELL_TICK)
		self:run()
		add_act_index(TO_LONG_CELL_TICK)
		self:run()
	end
end

function memroy:get_real(real)
	-- return real
	return self._last_real
end

function memroy:read_one_msg( str,real )
    local lastact = self:get_last_act()
    local longcell = self:get_long_cell()
    local longlk = self:get_long_link_cell()
    
	if type(str) == "string" and string.len(str) > 1 then
		local vec = split_each_char(str)
		for i, s in ipairs(vec) do
			if self:get_real(real) == false then
				lastact = {}
				longlk = nil
			end
			lastact,longlk = self:make_mem(s,lastact,longcell,longlk,real)
			self._last_real = real
		end
	else
		if self:get_real(real) == false then
			lastact = {}
			longlk = nil
		end
		lastact,longlk = self:make_mem(str,lastact,longcell,longlk,real)
	end

	
	if real then
		self:set_last_act(lastact)
		self:set_long_link_cell(longlk)
	end

	self._last_real = real
end

function memroy:checkToLongCell()
	if #self._last_act == 0 then
		return
	end

	local long = nil
	for i, n in ipairs(self._last_act) do
		if is_in_long_cell(n) then
			if long == nil then
				long = n
			else
				if long._msg then
					long = n
				end
			end
		end
	end

	if long then
		self:set_long_cell(long)
		self._last_act = {}
	end
end

function memroy:push_active_long_cell(n)
	if is_in_unact(n) == false then
		n:push_long_cell(n._mem ~= self)
		set_unact(n)
		return true
	end
	return false
end

function memroy:push_long_cell(n,fromup)
	-- if #self._long_act_cell > 0 then
	-- 	return
	-- end
	self._long_act_cell[#self._long_act_cell+1] = {
		_n = n,
		_from = fromup,
	}
end

function memroy:active_long_cell()
	if #self._long_act_cell == 0 then
		return
	end

	local tab = self._long_act_cell
	self._long_act_cell = {}

	-- local long = self:get_long_cell()

	for i, n in ipairs(tab) do
		self:rem_node(n._n,nil,true,n._from)
        self:do_msg(true)

		-- if long then
		-- 	link(long,n._n)
		-- end
	end
end

function memroy:read_cash_msg()
	if #self._read_msg == 0 then
		return
	end

	local vec = self._read_msg
	self._read_msg = {}

	for i, v in ipairs(vec) do
		self:read_one_msg(v._s,v._real)
	end
end

function memroy:push_down_long(n,fix)
	for k, l in pairs(n._link) do
		if l._long_cell and self:is_self_cell(l._n) == false and is_touch(l,fix) == false and rem_touch_cell(l,fix) then
			self:push_active_long_cell(l._n)
		end
	end
end

function memroy:cell_active( n,act,fix)
    local longact = {}
    local msg = {}

    for k,lk in pairs(n._link) do
		if self:is_self_cell(lk._n) then
			if lk._long_cell then
				-- long -> long 不触发
				-- if is_touch(lk,fix) == false and rem_touch_cell(lk,fix) then
				-- 	self:push_active_long_cell(lk._n)
				-- end
			else
				if lk._n._msg == nil then
					if is_long_touch(lk._n,fix) then
						longact[#longact+1] = lk
					end
				else
					if is_touch(lk,fix) == false and rem_touch_cell(lk,fix) then
						msg[#msg+1] = lk
						--第一个节点
						-- if n._long_cell then
						-- 	self:push_down_long(lk._n,fix)
						-- end
					end
				end
			end
		else
			if lk._long_cell then
				--往下
				-- if n._msg == nil then
				-- 	if is_touch(lk,fix) == false and rem_touch_cell(lk,fix) then
				-- 		self:push_active_long_cell(lk._n)
				-- 	end
				-- end
			end
		end
    end

	for i, lk in ipairs(msg) do
		act[#act+1] = lk._n
	end

    if #longact > 0 then
        local link = false
        for i,lk in ipairs(longact) do
            if is_touch(lk,fix) == false then
				if rem_touch_cell(lk,fix)  then
					link = true
					act[#act+1] = lk._n
				end
			else
				link = true
            end
        end
        if link then
            return
        end
    end

    for k,lk in pairs(n._link) do
		if self:is_self_cell(lk._n) and lk._n._msg == nil and lk._long_cell == false and is_touch(lk,fix) == false then
			if rem_touch_cell(lk,fix) and n._long_cell then
				act[#act + 1] = lk._n
			end
		end
    end
end

function memroy:rem_node( n ,fix,rem,fromup)
	if fix == nil then
		add_rem_act_index()
	end

	if not fromup then
		return
	end

	local msgnode = {}

    local nextact = {}

	push_read_step(n,self._type,false,false)

    self:cell_active(n,nextact,fix)

    while #nextact > 0
    do
        local tmplast = {}
        local tmpnext = {}

        for i,v in ipairs(nextact) do
            if v._msg then
				v:do_msg(rem ~= nil)
				msgnode[#msgnode+1] = v
            end

            self:cell_active(v,tmpnext,fix)
            tmplast[#tmplast+1] = v
        end

        nextact = tmpnext
    end

	local havedown = false
	
	for k, lk in pairs(msgnode[1]._link) do
		if lk._long_cell and self:is_self_cell(lk._n) == false then
			havedown = true
			break
		end
	end

	if havedown then
		for i, nd in ipairs(msgnode) do
			if is_deactive(nd) then
				local haveway = false
				-- for k, lk in pairs(nd._link) do
				-- 	if self:is_self_cell(lk._n) and is_deactive(lk._n) == false then
				-- 		haveway = true
				-- 		break
				-- 	end
				-- end

				if haveway == false then
					-- self:set_active(nd)
					for k, lk in pairs(nd._link) do
						if lk._long_cell and self:is_self_cell(lk._n) == false then
							if is_deactive(lk) then
								self:touch_cell(lk)
								self:push_active_long_cell(lk._n)
							end
						end
					end
				end
			end
		end
	end

	if fromup then
		for i, nd in ipairs(msgnode) do
			if is_in_real_active(nd) == false then
				self:push_read_msg(nd._msg,false,true)
			end
		end
	end
	
	for i, nd in ipairs(msgnode) do
		-- self:push_read_msg(nd._msg,false)
		push_down_index(nd)
	end
	-- if fromup then
	-- end
end

function memroy:is_link_node_act(n)
	for k, lk in pairs(n._link) do
		if self:is_self_cell(lk._n) and lk._long_cell == false then
			if is_deactive(lk._n) == false then
				return true
			end
		end
	end
	return false
end

function real_point(lk)
	local p = is_in_real_active(lk._n) and 2 or 0
	if lk._n._msg then
		p = p - 1
	end
	return p
end

function get_best_lk(tmp,noreal)
	local best = nil
	for i, lk in ipairs(tmp) do
		if best == nil then
			best = lk
		else
			local br = real_point(best)
			local lr = real_point(lk)
			if noreal then
				br = 0
				lr = 0
			end
			if lr > br then
				best = lk
			elseif lr == br then
				local blv = get_link_lv(best)
				local llv = get_link_lv(lk)
				if llv > blv then
					best = lk
				-- elseif llv == blv then
				-- 	if get_wait_index_num(lk._n) > get_wait_index_num(best._n) then
				-- 		best = lk
				-- 	elseif get_wait_index_num(lk._n) == get_wait_index_num(best._n) then
				-- 		if lk._acti < best._acti then
				-- 			best = lk
				-- 		end
				-- 	end
				end
			end
		end
	end
	return best
end

function memroy:act_links(lks,n,upway)
	local lk = get_best_lk(lks)
	local lkup = nil
	if is_in_real_active(n) == false then
		if is_in_real_active(lk._n) == false then
			upway[#upway+1] = lk
			local lk2 = get_best_lk(upway,true)
			if self:is_self_cell(lk2._n) == false then
				lkup = lk2
			end
		end
	else
		if is_in_real_active(lk._n) == false then
			for i, v in ipairs(upway) do
				self:touch_cell(v)
				self:push_node_msg(n,v._n)
			end
		else
			upway[#upway+1] = lk
			local lk2 = get_best_lk(upway,true)
			if self:is_self_cell(lk2._n) == false then
				lkup = lk2
			end
		end
	end

	if lk._long_cell then
		self:touch_cell(lk)
		self:push_active_long_cell(lk._n)
	else
		self:touch_cell(lk)
		push_read_step(lk._n,self._type,true,false)
		if lk._n._msg then
			lk._n:do_msg()
			-- set_unact(lk._n)
		end
		self._rem_cash[lk._n._index] = lk._n
	end

	if lkup then
		self:touch_cell(lkup)
		self:push_node_msg(n,lkup._n)
	end
end

function memroy:check_link_act()

	-- local rem = {}
	local incash = true
	for k, n in pairs(self._rem_cash) do
		if is_in_rem_cash(n) == false then
			-- rem[#rem+1] = n
			incash = false
			break
		end
	end
	if incash then
		return
	end

	self:rem_cash()
end

function memroy:get_active_link(act)
	local res = {}
	local cash = self._rem_cash
	-- local remove = {}

	local auto = {}

	if act then
		for k, n in pairs(cash) do
			local actlk = {}
			local alllk = {}

			for kl, lk in pairs(n._link) do
				if self:is_self_cell(lk._n) and is_deactive(lk) and get_link_lv(lk) > 0 then
					if is_link(lk._n,act) then
						actlk[#actlk+1] = lk
					end
					alllk[#alllk+1] = lk
				end
			end

			if #actlk == 0 then
				if #alllk > 0 then
					-- auto[k] = n
				end
			else
				for i, lk in ipairs(actlk) do
					res[#res+1] = lk
				end
			end
		end
	else
		auto = cash
	end

	for k, n in pairs(auto) do
		local alllk = {}
		local cashact = false
		for kl, lk in pairs(n._link) do
			if self:is_self_cell(lk._n) and is_deactive(lk) and get_link_lv(lk) > 0 then
				if self._center_mem == nil and is_in_cash_active(lk._n) then
					res[#res+1] = lk
					cashact = true
				else
					alllk[#alllk+1] = lk
				end
			end
		end

		if cashact == false then
			if n._msg then
				local lk = get_best_lk(alllk,true)
				res[#res+1] = lk
			else
				for i, lk in ipairs(alllk) do
					self:touch_cell(lk)
				end
			end
		end
	end

	return res
end

function memroy:push_node_msg(n,cn)
	if is_in_unact(cn) then
		return
	end
	self._center_mem:set_long_unact(cn)
	self._center_mem:push_long_node(n,is_in_real_active(n))
end

function memroy:touch_cell(lk)
    local n = lk._n

    if is_deactive(lk) then

		if self:is_self_cell(n) then
			if is_deactive(n,true) then
				n._acti = ACT_INDEX
				n._touch = 0
				n._long_touch = 0
				n._real_touch = 0
			end
			if lk._from_long_cell then
				n._long_touch = n._long_touch + 1
			else
				n._touch = n._touch + 1
			end
		end

        lk._acti = ACT_INDEX
		lk._waiti = ACT_INDEX
		lk._lv = lk._lv + 1
    end
    
    return n._touch >= n._active_touch
end

function memroy:real_touch(n)
	if is_deactive(n,true) then
		n._acti = ACT_INDEX
		n._touch = 0
		n._long_touch = 0
		n._real_touch = 0
	end
	n._real_touch = n._real_touch + 1
	return n._real_touch >= n._active_touch
end

function memroy:set_long_unact(n)
	-- if is_in_real_active(n) == false then
	-- 	return
	-- end
	for k, lk in pairs(n._link) do
		if lk._long_cell and self:is_self_cell(lk._n) == false then
			lk._n._un_acti = ACT_INDEX
		end
	end
end

function memroy:check_real(n,act)
	local real = false
	for k, lk in pairs(n._link) do
		if lk._n == act then
			n._real_acti = ACT_INDEX
			real = true
			break
		end
	end
	if real then
		for k, lk in pairs(n._link) do
			if self:is_self_cell(lk._n) and lk._n._msg == nil and lk._long_cell == false then
				self:real_touch(lk._n)
			end
		end
	end
	return real
end

function memroy:act_real(act)
	if is_in_real_active(act) then
		for i, n in ipairs(self._act_cash) do
			self:check_real(n,act)
		end
	end

	self._act_cash = {}

	if is_in_real_active(act) then
		for i, lk in pairs(act._link) do
			if lk._msg == nil and lk._long_cell == false and self:is_self_cell(lk._n) then
				if self:real_touch(lk._n) then
					self._act_cash[#self._act_cash+1] = lk._n
				end
			end
		end
	end
end

function memroy:rem_cash(act)
	while true do
		local actlink = self:get_active_link(act)

		self._rem_cash = {}

		if #actlink == 0 then
			break
		end

		local tmp = {}

		for i, lk in ipairs(actlink) do
			if self:touch_cell(lk) then
				tmp[lk._n._index] = lk._n
			elseif act == nil then
				if is_in_cash_active(lk._n) then
					tmp[lk._n._index] = lk._n
				end
			end
		end

		for nk, n in pairs(tmp) do
			push_read_step(n,self._type,true,false)
			if n._long_cell then
				self:push_active_long_cell(n)
			else
				if act == nil or is_link(n,act) then
					self._rem_cash[nk] = n
				end
				for k, nlk in pairs(n._link) do
					if is_deactive(nlk) then
						if self:is_self_cell(nlk._n) then
							if nlk._n._msg then
								if nlk._n ~= act then
									nlk._n:do_msg()
									if is_deactive(nlk._n) then
										push_read_step(nlk._n,self._type,false,false)
									end
									set_unact(nlk._n)
									self:touch_cell(nlk)
									if act == nil then
										self._rem_cash[nlk._n._index] = nlk._n
										self:push_read_msg(nlk._n._msg,false)
									end
								end
							end
						else
							self:touch_cell(nlk)
							if nlk._long_cell then
								--下
								self:push_active_long_cell(nlk._n)
							else
								--上
								if is_in_real_active(n) then
									self:push_node_msg(n,nlk._n)
								end
							end
						end
					end
				end
			end

		end

		if act ~= nil then
			break
		end
	end
end

function memroy:remem(s)
	local act = self:get_root_msg(s)
	set_unact(act)

	if is_in_real_active(act) == false then
		return
	end

	self:act_real(act)

	for k, lk in pairs(act._link) do
		if self:is_self_cell(lk._n) == false and lk._n._msg ~= nil then
			self:touch_cell(lk)
			self:push_node_msg(act,lk._n)
		end
	end

	self:rem_cash(act)

	self._rem_cash[act._index] = act
end

function memroy:push_long_node(n,real)
	self._long_node[#self._long_node+1] = {
		_n = n,
		_real = real,
	}
end

function memroy:read_one_node_msg( s,longnode,real )
    local lastact = self:get_last_act()
    local longcell = self:get_long_cell()
    local longlk = self:get_long_link_cell()
    
	if self:get_real(real) == false then
		lastact = {}
		longlk = nil
	end

    lastact,longlk = self:make_mem(s,lastact,longcell,longlk,real)

	if longnode._link[longnode._index] == nil then
		link(longnode,lastact[1],longnode._index)
	end

	if real then
		self:set_last_act(lastact)
		self:set_long_link_cell(longlk)
	end
	self._last_real = real
end

function memroy:read_long_node()
	if #self._long_node == 0 then
		return
	end

	local vec = self._long_node
	self._long_node = {}

	for i, v in ipairs(vec) do
		self:read_one_node_msg(v._n._index,v._n,v._real)
	end
end

function memroy:add_memory(mem)
	mem:set_center_mem(self)
	self._memory[#self._memory+1] = mem
end

function memroy:run_memory()
	for i, v in ipairs(self._memory) do
		v:run()
	end
end

function memroy:run()
	self:checkToLongCell()
	self:check_link_act()
	
	self:run_memory()
	self:read_long_node()
	self:read_cash_msg()

    self:do_msg()

	self:active_long_cell()
end

function memroy:run_idx(idx)
	idx = idx or 1
    for i=1,idx do
        add_act_index(1)
        self:run()
    end
end

function add_layer( mem,name,num )
    for i=1,num do
        local ly = memroy.new(name.."_"..i)
        ly:add_memory(mem)
        mem = ly
    end
    return mem
end

local memlisten = memroy.new("ls")
local memtalk = memroy.new("tk")
local memrole = memroy.new("role")      --主体

--没有com更精准

local centermem = memroy.new("center")
-- centermem:add_memory(memrole)

centermem:add_memory(add_layer(memlisten,"lscom",0))
centermem:add_memory(add_layer(memtalk,"tkcom",0))


local main = add_layer(centermem,"work",1)

function show_msg( name,msg,rem,desc,idx)
    print(name," ---------- ",(rem and "rem" or ""),idx,desc or "")
    print(table.concat( msg, " "))
end

function set_msg_func( mem,name )
    mem:set_msg_func(function( msg,rem,desc,idx )
        show_msg(name,msg,rem,desc,idx)
    end)
end

-- set_msg_func(lscom,"lscom")

set_msg_func(memlisten,"ls")
set_msg_func(memtalk,"talk")
set_msg_func(centermem,"center")


function read_word( tab,mvec )
    for i,v in ipairs(tab) do
		for _, m in ipairs(mvec) do
			m:read_msg(v,TO_LONG_CELL_TICK)
		end
		add_act_index(DEACTIVE_TICK)
    end
end

function read_vecword( tab,memvec)
    for i,v in ipairs(tab) do
        for k,m in ipairs(memvec) do
            if v[k] then
                m:push_read_msg(v[k],true)
                -- if k == 1 then
                --     memrole:push_read_msg("z")
                -- end
            end
			main:run_idx()
        end
        main:run_idx(DEACTIVE_TICK*4)
    end
end

-- read_word(words,{memlisten})

function read_msg_idx( msg,desc )
    print("                               --------------   ",desc)
    memlisten:push_read_msg(msg,true)
    main:run_idx(DEACTIVE_TICK*4)
end

local words = {
    -- "ab gh",
    -- "abcdf",
    -- "ss 111",
    -- "123",
    -- "ssss",
    -- "ss cas",
    -- "ab cd",
    -- "cd ab",
    -- "cx wq",
    -- "fg fswa",
    -- "ae iop",
    -- "iow",
    -- "s dhj",
    -- "b dhk",
    -- "c nm",
    "cd hjk",
    -- "acdbe",
    -- "cdhjk",
    
}

local msggroup = {
    -- {"a","a"},
    -- {"b","b"},
    -- {"c","c"},
    -- {"zad ww"},
    -- {"cb","sty"}
    -- {"cd","hjk"},
    {"ab","cd"},
    {"qw","qw"},
    {"zx","zx"},
}


read_vecword(msggroup,{memlisten,memtalk})
main:run_idx(DEACTIVE_TICK*4)

read_msg_idx("sp","")




read_msg_idx("spab","start")

read_msg_idx("spab","1111")

read_msg_idx("spab","2222")

read_msg_idx("spab","3333")

-- read_msg_idx("sp","6666")


read_msg_idx("spqw","start")
step_read_start = true
read_msg_idx("spqw","1111")

-- read_msg_idx("sp","6666")
-- read_msg_idx("spqw","2222")

-- read_msg_idx("spqw","3333")
-- step_read_start = true
-- read_msg_idx("spqw","4444")


-- read_msg_idx("spzx","1111")

-- read_msg_idx("spzx","2222")

-- read_msg_idx("spzx","3333")
-- step_read_start = true
-- read_msg_idx("spzx","4444")

-- read_msg_idx("spzx","5555")

-- read_msg_idx("sp","5555")

print("\n             ------     showstep  ---------       ")
show_read_step()

dumpCell(main)

-- print("        ***   3333    ")

-- memlisten:push_read_msg("spab")
-- main:run_idx(DEACTIVE_TICK*4)


-- print("********************")
-- memlisten:push_read_msg("spab")

-- -- memrole:push_read_msg("z")
-- main:run_idx(DEACTIVE_TICK*4)

-- local memtest = memroy.new("test")

-- memtest:set_msg_func(function( msg,rem,desc )
--     print("test ---------- ",(rem and "rem" or ""),desc or "")
--     print(table.concat( msg, ""))
-- end)