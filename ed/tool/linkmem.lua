
local l1_width = 4
local linknum = 4
local outwidth = l1_width + linknum - 1

function newnode(id)
    local node = {
        _id = id,
        _link = {},
        _act = 0,
        _belink = 0,
    }
    return node
end

function linknode( n1,n2 )
    n1._link[n2._id] = n2
    n2._belink = n2._belink + 1
end

local l1tab = {}
local l2tab = {}

function initdata()
    for i=1,l1_width*l1_width do
        l1tab[i] = newnode(i)
    end
    for i=1,outwidth*outwidth do
        l2tab[i] = newnode(i)
    end

    for i1=1,l1_width do
        for j1=1,l1_width do
            local l1i = (i1-1)*l1_width + j1
            local nd = l1tab[l1i]

            for i2=1,linknum do
                for j2=1,linknum do
                    local x = i1 - 1 + i2
                    local l2i = (x-1)*outwidth + j1 -1 + j2
                    local n2 = l2tab[l2i]

                    linknode(nd,n2)
                end
            end

        end
    end
end

function set_act(d)
    for i,v in ipairs(d) do
        local idx = (v[1]-1)*l1_width + v[2]
        local nd = l1tab[idx]

        for k,n in pairs(nd._link) do
            n._act = n._act + 1
        end
    end
end

function show_belink()
    print("---------  belink ---------")
    local ptab = {}
    for i=1,outwidth do
        ptab[i] = {}
        for j=1,outwidth do
            local idx = (i-1)*outwidth + j
            local nd = l2tab[idx]
            ptab[i][j] = nd._belink
        end
    end
    for i,v in ipairs(ptab) do
        print(table.concat( v, " "))
    end
end

function show_state()
    print("---------  act ---------")
    local ptab = {}
    for i=1,outwidth do
        ptab[i] = {}
        for j=1,outwidth do
            local idx = (i-1)*outwidth + j
            local nd = l2tab[idx]
            ptab[i][j] = nd._act
            nd._act = 0
        end
    end
    for i,v in ipairs(ptab) do
        print(table.concat( v, " "))
    end
end

initdata()
show_belink()

local actvec = {
    {
        {1,1},
        {2,2},
        {3,3},
        {4,4},
    },
    {
        {2,1},
        {2,2},
        {2,3},
        {2,4},
    },
    {
        {1,2},
        {2,2},
        {3,2},
        {4,2},
    },
    {
        {4,1},
        {3,2},
        {2,3},
        {1,4},
    },
}

for i,v in ipairs(actvec) do
    set_act(v)
    show_state()
end