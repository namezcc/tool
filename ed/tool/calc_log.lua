require "split"

local killtab = {}

function set_family_tab( fid,fsid,monsterid,t,rvt )
    local tab = gcSubTable(killtab,fsid*100 + fid)
    local tm = gcSubTable(tab,monsterid)

    tm[#tm + 1] = {
        _t = timeStampTodate(t),
        _tm = t,
        _rvt = rvt,
    }
end

function parse_log( str )
    if string.find(str,"family boss kill") then
        local vec = parse_int_vector(str)
        set_family_tab(vec[2],vec[3],vec[4],vec[1],vec[5] - vec[1])
    elseif string.find(str,"family boss revivr") then
        local vec = parse_int_vector(str)
        set_family_tab(vec[2],vec[3],vec[4],vec[1])
    end
end

function show_kill_time()
    for k,v in pairs(killtab) do
        for mid,tm in pairs(v) do
            local tb = tm[1]._tm
            for i,t in ipairs(tm) do
                if t._rvt then
                    print("die ",t._t,"fid:",k,"mid:",mid,"rvtime:",t._rvt," diff ",t._tm)
                else
                    print("revive ",t._t,"fid:",k,"mid:",mid," diff -------------------- ",t._tm-tb)
                end
                tb = t._tm
            end
        end
    end
end

readFileLine("1.log",parse_log)
show_kill_time()



