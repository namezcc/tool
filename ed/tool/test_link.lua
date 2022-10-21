
local layer = 10
local node_num = 100
local link_num = 5
local trigper = 51

local root = {}

function get_node()
    return {
        _v = false,
        _link = {},
        _lv = 0,
    }
end

function build_link(r)
    for i=1,layer do
        local ln = {}
        r[i] = ln

        local lastlayer = r[i-1]

        for j=1,node_num do
            local n = get_node()
            ln[j] = n

            if lastlayer ~= nil then
                for l=1,link_num do
                    local lindex = j + l - math.floor(link_num/2 + 1)
                    local lastn = lastlayer[lindex]
                    if lastn then
                        n._link[#n._link+1] = lastn
                    end
                end
            end
        end
    end
end

function test_val(r,sv)
    local res = {}

    for i=1,#r do
        local ly = r[i]
        local op = {}
        res[i] = op
        for j=1,#ly do
            local n = ly[j]
            if i == 1 then
                local rv = math.random(0,1)
                if sv then
                    rv = sv[j]
                end

                if rv == 1 then
                    op[#op+1] = j
                    n._v = true
                    n._lv = n._lv + 1
                else
                    n._v = false
                end
            else
                local linkn = #n._link
                local tn = 0
                for nidx=1,linkn do
                    if n._link[nidx]._v then
                        tn = tn + 1
                    end
                end

                if (n._lv > 0 and tn > 0) or tn*100/linkn >= trigper then
                    n._v = true
                    n._lv = n._lv + 1
                    op[#op+1] = j
                else
                    n._v = false
                end
            end
        end
    end
    return res
end

function show_test(r,sv,all)
    local op = test_val(r,sv)

    if all then
        for i,v in ipairs(op) do
            print(table.concat( v, ","))
        end
    else
        print(table.concat( op[1], ","))
        print(table.concat( op[#op], ",")) 
    end
end

function get_test_val( vec )
    local sv = {}
    for i,v in ipairs(vec) do
        sv[v] = 1
    end
    return sv
end


build_link(root)

local sv = get_test_val({1,2,3,8,9,10})
show_test(root,sv)

print("-------------------")
sv = get_test_val({2})
show_test(root,sv,1)

-- for i=1,10 do
--     print("----------------------")
--     show_test()
-- end

-- for i=1,#op do
--    print(table.concat( op[i], ","))
-- end