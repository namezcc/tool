require "split"


local data = {}

function getSubTable( d,k )
    if d[k] == nil then
        local tab = {}
        d[k] = tab
        return tab
    end
    return d[k]
end

function getcampSlot( t )
    local c = getSubTable(data,t[1])
    local s = getSubTable(c,t[2])
    return getSubTable(s,t[3])
end

function parseData( str )
    if str == nil then
        return
    end
    local s = string.match(str,"VALUES%((.*)%)")
    local t = Split(s,",")
    local dt = getcampSlot(t)

    dt._type = t[4]
    dt._id = t[5]
    dt._sid = t[6]
end

function psql()
    local str = "UPDATE `mem_country_storage` SET `type`=%s,`id`=%s,`born_sid`=%s WHERE `camp`=%d AND `storage`=%d AND `slot`=%d;"
    for camp,ct in pairs(data) do
        for stor,st in pairs(ct) do
            for slot,dt in pairs(st) do
                print(string.format(str,dt._type,dt._id,dt._sid,camp,stor,slot))
            end
        end
    end
end

readFileLine("log.txt",parseData)
psql()