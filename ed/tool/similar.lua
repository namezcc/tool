
local multiArray = {}

function multiArray:setDimension( arr )
    self._dms = arr
    self._dmsplus = {}

    local plus = 1
    for i=#arr,1,-1 do
        self._dmsplus[i] = plus
        plus = plus * arr[i]
    end

    self._data = {}
end

function multiArray:getIndex( idxs )
    local index = 0
    if #idxs ~= #self._dms then 
        print("error idxs",#idxs,"need ",#self._dms)
        return 0 
    end

    for i=1,#idxs - 2 do
        index = index + self._dmsplus[i]*(idxs[i] - 1)
    end
    index = index + idxs[#idxs - 1]
    return index,idxs[#idxs]
end

function multiArray:setData( d,idxs )
    local index,li = self:getIndex(idxs)
    if self._data[index] == nil then
        self._data[index] = {}
    end
    self._data[index][li] = d
end

function multiArray:getData( idxs )
    local index,li = self:getIndex(idxs)
    return self._data[index]
end

function multiArray:showData()
    for k,v in pairs(self._data) do
        local str = table.concat( v, "\t")
        print("index",k,str)
    end
end

function redianToAngle( p )
    return p*180/3.1415
end

function vecToAngle( p )
    return redianToAngle(math.atan(p._y/p._x))
end

function vec_minus( p1,p2 )
    return {_x = p1._x - p2._x,_y = p1._y - p2._y}
end

_FIX_DIFF_ANGLE = 5

function calcAnglePer( pv )
    local res = {}

    local maxlen = pv[#pv]._x - pv[1]._x
    local prev = pv[1]

    for i=2,#pv do
        local n = pv[i]
        local point = vec_minus(n,prev)

        local angle = vecToAngle(point)
        local lper = point._x*100 / maxlen

        local node = {_angle = angle,_per=lper}
        res[#res + 1] = node

        prev = n
    end

    -- 合并
    local com = {res[1]}
    local node = res[1]
    local min_ang = node._angle
    local max_ang = node._angle

    for i=2,#res do
        local nx = res[i]
        local combin = true

        if nx._angle > max_ang then
            if nx._angle - min_ang > _FIX_DIFF_ANGLE then
                combin = false
            else
                max_ang = nx._angle
            end
        elseif nx._angle < min_ang then
            if max_ang - nx._angle > _FIX_DIFF_ANGLE then
                combin = false
            else
                min_ang = nx._angle
            end
        end

        if combin then
            node._per = node._per + nx._per
        else
            node = nx
            min_ang = nx._angle
            max_ang = nx._angle
            com[#com + 1] = node
        end
    end

    return com
end

function balenceAnglePer( pv1,pv2 )
    local res1 = {}
    local res2 = {}

    local index1 = 1
    local index2 = 1

    while(pv1[index1] ~= nil and pv2[index2] ~= nil)
    do
        local d1 = pv1[index1]
        local d2 = pv2[index2]

        local diffper = d1._per - d2._per

        if math.abs(diffper) > 1 then
            if diffper > 0 then

                local node = {_angle = d1._angle,_per=d2._per}
                res1[#res1 + 1] = node
                res2[#res2 + 1] = d2

                d1._per = diffper

                index2 = index2 + 1

                -- print("add n1 ang:",node._data._angle,"per:",node._data._per)
            else
                local node = {_angle = d2._angle,_per=d1._per}
                res2[#res2 + 1] = node
                res1[#res1 + 1] = d1

                d2._per = -diffper

                index1 = index1 + 1

                -- print("add n2 ang:",node._data._angle,"per:",node._data._per)
            end
        else
            res1[#res1 + 1] = d1
            res2[#res2 + 1] = d2
            index1 = index1 + 1
            index2 = index2 + 1
        end
    end
    return res1,res2
end

_FIX_Y_DIFF = 10
_FIX_ANGLE_DIFF = 30

function calc_similar( r1,r2 )
    local sm = 0
    local y1 = 0
    local y2 = 0
    for i=1,#r1 do
        local n1 = r1[i]
        local n2 = r2[i]

        if n1 and n2 then
            y1 = y1 + math.tan(n1._angle)*n1._per
            y2 = y2 + math.tan(n2._angle)*n2._per
            local ydiff = math.abs(y1 - y2)
            local ydiffper = 1 - ydiff/_FIX_Y_DIFF
            if ydiffper < 0 then
                ydiffper = 0
            end

            local per = math.abs(n1._angle - n2._angle)/_FIX_ANGLE_DIFF
            per = (1 - per)*n1._per
            if per < 0 then
                per = 0
            end
            per = ydiffper*per
            sm = sm + per
            print("node ",i,"per:",per,"ydiff:",ydiffper)
        end
    end
    return sm
end

function calc_per( y1,y2,ang1,ang2,per1,per2 )
    y1 = y1 + math.tan(ang1)*per1
    y2 = y2 + math.tan(ang2)*per2
    local ydiff = math.abs(y1 - y2)
    local ydiffper = 1 - ydiff/_FIX_Y_DIFF
    if ydiffper < 0 then
        ydiffper = 0
    end

    local per = math.abs(ang1 - ang2)/_FIX_ANGLE_DIFF
    per = (1 - per)*per1
    if per < 0 then
        per = 0
    end
    per = ydiffper*per
    return per,y1,y2
end

function calc_similar_all( r1,r2 )
    local len1 = #r1
    local len2 = #r2

    multiArray:setDimension({len1,len2})

    for i1=1,len1 do
        for j1=1,len2 do
            local resper = 0
            local y1 = 0
            local y2 = 0
            local pm = r1[i1]._per/r2[j1]._per

            for j2=j1-1,1,-1 do
                local i2 = i1 + j2 - j1
                if i2 <= 0 then
                    break
                end

                local n1 = r1[i2]
                local n2 = r2[j2]

                local n2per = n2._per * pm
                local ptmp = 0
                ptmp,y1,y2 = calc_per(y1,y2,n1._angle,n2._angle,n1._per,n2per)
                resper = resper + ptmp
            end

            y1 = 0
            y2 = 0

            for j2=j1,len2 do
                local i2 = i1 + j2 - j1
                if i2 > len1 then
                    break
                end

                local n1 = r1[i2]
                local n2 = r2[j2]

                local n2per = n2._per * pm
                local ptmp = 0
                ptmp,y1,y2 = calc_per(y1,y2,n1._angle,n2._angle,n1._per,n2per)
                resper = resper + ptmp
            end

            multiArray:setData(resper,{i1,j1})
        end
    end

    multiArray:showData()
end

function pringAngper( r )
    print(" --------------------- *************** -------------")
    local n = r

    for i=1,#r do
        local d = r[i]
        print("ang:",d._angle,"per:",d._per)
    end
end

local pvec1 = {
    {_x = 0, _y = 0},
    {_x = 5, _y = 5},
    {_x = 10, _y = 5},
    {_x = 15, _y = 10},
}

local pvec2 = {
    {_x = 0, _y = 0},
    {_x = 1, _y = 0},
    {_x = 2, _y = 1},
    {_x = 3, _y = 0},
}

local res1 = calcAnglePer(pvec1)
local res2 = calcAnglePer(pvec2)

print("org -----------------")
pringAngper(res1)
pringAngper(res2)

-- res1,res2 = balenceAnglePer(res1,res2)

-- print("bal -----------------")

-- pringAngper(res1)
-- pringAngper(res2)

-- print(calc_similar(res1,res2))

calc_similar_all(res1,res2)