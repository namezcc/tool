require "split"

local act_index = 0
local now_state = "s1"
local acts = {}

function get_action_conf()
    return acts[act_index]
end

local testData = 0

local action = {
    go_state = function()
        local conf = get_action_conf()
        now_state = conf.act._p[1]
        print("go state",now_state)
    end,

    act_1 = function()
        testData = testData + 1
    end,

    act_2 = function()
        testData = testData + 1
    end,

    act_3 = function()
        testData = testData + 1
    end,
}

local condition = {
    cond_1 = function ( )
        return testData > 10
    end,
    cond_2 = function ( )
        return testData > 20
    end,
    cond_3 = function ( )
        
    end,
}

local statetab = {}

local act_root = {
    ["s1"] = {
        {
            act = {_t = "act_1",_p={}},
        },
        {
            act = {_t = "act_2",_p={}},
        },
        {
            act = {_t = "act_3",_p={}},
        },
        {
            act = {_t = "go_state",_p={"s2"}},
            cond = {_t="cond_1",_p={}},
        },
    },
    ["s2"] = {
        {
            act = {_t = "act_1",_p={}},
        },
        {
            act = {_t = "act_2",_p={}},
        },
        {
            act = {_t = "act_3",_p={}},
        },
        {
            act = {_t = "go_state",_p={"s3"}},
            cond = {_t="cond_2",_p={}},
        },
    },
}

function run_state(  )

    acts = act_root[now_state]

    if acts == nil then
        print("over")
        return false
    end

    for i,v in ipairs(acts) do
        act_index = i
        if v.cond ~= nil then
            if condition[v.cond._t] == nil then
                print("nil cond func",v.cond)
                return
            end

            if condition[v.cond._t]() == true then
                action[v.act._t]()
            end
        else
            action[v.act._t]()
        end
    end
    return true
end


local op_func = {
    ["+"] = function( v1,v2 )
        if v2 == nil then
            return v1
        end
        return v1+v2
    end,
    ["-"] = function( v1,v2 )
        if v2 == nil then
            return -v1
        end
        return v1-v2
    end,
    ["*"] = function( v1,v2 )
        return v1*v2
    end,
    ["/"] = function( v1,v2 )
        return v1/v2
    end,
    ["^"] = function( v1,v2 )
        return v1^v2
    end,
    ["sin"] = function( v )
        return math.sin(v)
    end
}

-- local op_func = {
--     ["+"] = "+",
--     ["-"] = "-",
--     ["*"] = "*",
--     ["/"] = "/",
--     ["^"] = "^",
--     ["sin"] = "sin",
-- }

function is_number(s)
    local n1 = string.byte("0")
    local n2 = string.byte("9")
    local ns = string.byte(s)
    return ns>=n1 and ns <= n2
end

function is_letter(s)
	if s == "" then
		return false
	end
    local ns = string.byte(s)
    local a1 = string.byte("a")
    local a2 = string.byte("z")
    local b1 = string.byte("A")
    local b2 = string.byte("Z")

    if (ns>=a1 and ns <= a2) or (ns>=b1 and ns <= b2) then
        return true
    end
end

function jumpspace(str,pos)
    local p = str:match("^[%s\n]*()",pos)
    return p or pos
end

function get_one_char( str,pos )
    return str:sub(pos,pos)
end

function parse_number(str,pos)
    local pat = "^(%d[%d%.]*)%s*()"
    local s,p = str:match(pat,pos)
    return s,p
end

function parse_word( str,pos )
    local pat = "^([%a]+)%s*()"
    local s,p = str:match(pat,pos)
    return s,p
end

function split_func_str( str )
    local pos = 1
    local len = str:len()
    local vec = {}
    pos = jumpspace(str,pos)

    while pos <= len do
        local c = get_one_char(str,pos)

        if is_number(c) then
            local s,p = parse_number(str,pos)
            vec[#vec+1] = tonumber(s)
            pos = p
        elseif is_letter(c) then
            local nc = get_one_char(str,pos+1)
            if is_letter(nc) then
                local s,p = parse_word(str,pos)
                vec[#vec+1] = s
                pos = p
            else
                vec[#vec+1] = c
                pos = pos + 1
            end
        else
            vec[#vec+1] = c
            pos = pos + 1
        end

        pos = jumpspace(str,pos)
    end
    return vec
end


VT_NUM = 1
VT_VAR = 2
VT_FUNC = 3

function new_func_obj()
    return {
        _v = nil,
        _func = nil,
        _fstr = nil,
        _vfunc = nil,
        _vfstr = nil,
    }
end

function Assert( msg )
    assert(nil,msg)
end

function get_next_str(sp)
    sp.pos = sp.pos + 1
    return sp.vec[sp.pos]
end

function parse_value(s,sp)
    if type(s) == "string" then
        if string.len(s) == 1 then
            if s == "(" then
                return parse_func(sp)
            elseif is_letter(s) then
                local func = op_func[s]
                if func then
                    Assert("error op func nil "..s)
                end
                return s
            else
                if s == "+" or s == "-" then
                    return parse_func(sp,true),op_func[s],s
                else
                    Assert("error func str")
                end
            end
        else
            local ns = get_next_str(sp)
            if ns ~= "(" then
                Assert("error func not (")
            end
            local func = op_func[s]
            if func == nil then
                Assert("error op func nil "..s)
            end
            return parse_func(sp),func,s
        end
    else
        return s
    end
end

function parse_opt( s,sp )
    if type(s) == "string" then
        if string.len(s) == 1 then
            local func = op_func[s]
            if func == nil then
                Assert("error opt "..s)
            end
            return func
        else
            Assert("error opt "..s)
        end
    else
        Assert("error opt "..s)
    end
end

function parse_func(sp,single)
    local fvec = {}
    local s = get_next_str(sp)

    local fs = new_func_obj()
    while s do
        if s == ")" then
            break
        end

        if #fvec == 0 then
            -- if s == "+" or s == "-" then
            --     fs._func = parse_opt(s,sp)
            --     fs._fstr = s
            --     s = get_next_str(sp)
            -- end

            local v,vf,vfstr = parse_value(s,sp)
            fs._v = v
            fs._vfunc = vf
            fs._vfstr = vfstr
        else
            fs._func = parse_opt(s,sp)
            fs._fstr = s

            s = get_next_str(sp)
            local v,vf,vfstr = parse_value(s,sp)
            fs._v = v
            fs._vfunc = vf
            fs._vfstr = vfstr
        end

        fvec[#fvec+1] = fs
        if single then
            break
        end
        fs = new_func_obj()
        s = get_next_str(sp)
    end
    return fvec
end

function get_func_level(fstr)
    if fstr == "+" or fstr == "-" then
        return 1
    elseif fstr == "*" or fstr == "/" then
        return 2
    elseif fstr == "^" then
        return 3
    end
    return 0
end

function do_func_check_stack( fvec,pos )
    if pos >= #fvec then
        return false
    end

    local lv1 = get_func_level(fvec[pos]._fstr)
    local lv2 = get_func_level(fvec[pos+1]._fstr)

    if lv2 == 3 then
        return true
    else
        return lv2 > lv1
    end
end

function get_val( fs,var )
    local v = 0
    if type(fs._v) == "number" then
        v = fs._v
    elseif type(fs._v) == "string" then
        v = var[fs._v]
    elseif type(fs._v) == "table" then
        v = do_func_vec(fs._v,var)
    end
    if fs._vfunc then
        v = fs._vfunc(v)
    end
    return v
end

function do_func_vec( fvec,var,pos )
    pos = pos or 1
    local val = get_val(fvec[pos],var)
    local len = #fvec
    pos = pos + 1

    while pos <= len do
        local fs = fvec[pos]
        if do_func_check_stack(fvec,pos) then
            local v2,np = do_func_vec(fvec,var,pos)
            val = fs._func(val,v2)
            pos = np
        else
            local v2 = get_val(fs,var)
            val = fs._func(val,v2)
        end
        pos = pos + 1
    end
    return val,pos
end

function make_func( fvec )
    local f = function( var )
        return do_func_vec(fvec,var)
    end
    return f
end

function parse_func_str(str)
    local vec = split_func_str(str)
    local sp = {
        vec = vec,
        pos = 0,
    }
    return parse_func(sp)
end

-- local fstr = "-x+x*-sin(y^1+100/sin(x))+1"
local fstr = "-x+x^2"

local fvec = parse_func_str(fstr)
local func = make_func(fvec)

local var = {x=5,y=0}

-- printTable(parse_func_str(fstr))

local val = func(var)
-- local x,y=2,0
-- local val = -x+x*-math.sin(y+100/math.sin(x))+1

local clockvec = {}

function setClock()
    clockvec[#clockvec+1] = os.clock()
end

function showClock(s)
    clockvec[#clockvec+1] = os.clock()
    local v1 = clockvec[#clockvec-1]
    local v2 = clockvec[#clockvec]
    local v = v2-v1
    print(s,v1,v2,v)
end

local testvec = {}
local testnum = 1500
local movenum = 50

local groupnum = 100


function init()
    for i=1,testnum do
        testvec[i] = i
    end
end

function initGroup()
    local vec = nil
    for i=1,testnum do
        if vec == nil then
            vec = {}
            testvec[#testvec+1] = vec
        end
        vec[#vec+1] = i
        if #vec >= groupnum then
            vec = nil
        end
    end
end

-- init()
initGroup()

function moveone()
    for i=1,movenum do
        table.remove(testvec,1)
    end
end

function move1_g()
    for i=1,movenum do
        local vec = testvec[1]
        table.remove(vec,1)
        if #vec == 0 then
            table.remove(testvec,1)
        end
    end
end

function move2()
    local len = #testvec
    for i=1,movenum do
        testvec[i],testvec[len-i-1] = testvec[len-i-1],testvec[i]
    end
    for i=1,movenum do
        testvec[len-i-1] = nil
    end
end

function move3()
    for i=1,testnum-movenum do
        testvec[i] = testvec[i+movenum]
    end
    for i=testnum-movenum+1,testnum do
        testvec[i] = nil
    end
end

function move4()
    local newvec = {}
    for i=movenum+1,testnum do
        -- newvec[#newvec+1] = testvec[i]
        newvec[i-movenum] = testvec[i]
    end
end


FAMILY_POSITION = {
    FP_LEADER = 1,
    FP_FBZ = 2,
    FP_LIT = 3,     --力堂
    FP_WUT = 4,     --武堂
    FP_YUT = 5,     --御堂
    FP_MINT = 6,    --敏堂
    FP_YAOT = 7,    --药堂
    FP_JINGYING = 8,    --精英
    FP_MEMBER = 9,
}

local fp = FAMILY_POSITION
local testnnn = 100000

function test_global()
    local n = 1
    for i=1,testnnn do
        n = n + FAMILY_POSITION.FP_JINGYING
    end
end

function test_local()
    local n = 1
    for i=1,testnnn do
        n = n + fp.FP_JINGYING
    end
end

setClock()
-- moveone()
-- showClock("11")
-- move2()
-- showClock("move2")
-- move3()
-- showClock("move3")
-- move4()
-- showClock("move4")
-- move1_g()
-- showClock("move1_g")

-- test_global()
-- showClock("global")
-- test_local()
-- showClock("local")
-- local function set_bit_on(v,b)
--     return v|(1<<(b-1))
-- end

-- local function set_bit_off(v,b)
--     return v&(~(1<<(b-1)))
-- end

-- local num = 0
-- local n1 = set_bit_on(num,64)
-- local n2 = n1

-- print(n1,n2)
