-- 0.执行节点
-- 1.顺序执行,有一个成功就返回成功
-- 2.顺序执行,全部成功返回成功
-- 3.权重随机,

require "split"

local tree = {
    [1] = {
        [1] = {node_type=2,child_node={2,3},child_weight={},action=0,param=0},
        [2] = {node_type=2,child_node={4,5},child_weight={},action=0,param=0},
        [3] = {node_type=3,child_node={6,7},child_weight={100,200},action=0,param=0},
        [4] = {node_type=0,child_node={},child_weight={},action=1,param=0},
        [5] = {node_type=0,child_node={},child_weight={},action=2,param=0},
        [6] = {node_type=0,child_node={},child_weight={},action=3,param=0},
        [7] = {node_type=0,child_node={},child_weight={},action=4,param=0},
    }
}


function create_node( id,cfg )
    local node = {
        cfg = cfg,
        child = {},
    }
    return node
end

local treetab = {}
local nodetab = {}

function init_tree()
    for i,t in ipairs(tree) do
        local tabnode = {}
        nodetab[i] = tabnode
        for id,cfg in ipairs(t) do
            local nd = create_node(id,cfg)
            tabnode[id] = nd
            if id == 1 then
                treetab[i] = nd
            end
        end

        for k,n in pairs(tabnode) do
            if #n.cfg.child_node > 0 then
                for idx,nid in ipairs(n.cfg.child_node) do
                    n.child[idx] = tabnode[nid]
                end
            end
        end
    end
end

local action_func = {
    [1] = function(cfg)
        print("action -- ",cfg.action)
        return true
    end,
    [2] = function(cfg)
        print("action -- ",cfg.action)
        return true
    end,
    [3] = function(cfg)
        print("action -- ",cfg.action)
        return true
    end,
    [4] = function(cfg)
        print("action -- ",cfg.action)
        return true
    end,
}

local next_func = {
    [1] = function( info,list )
        local node = info.n
        local child = list[info.index+1]
        local cn = nil
        if child then
            if child.res then
                info.res = true
                return
            end
            cn = child.n
        end
        local index = 0
        for i=#node.child,1,-1 do
            if node.child[i] == cn then
                break
            else
                index = i
            end
        end
        return node.child[index]
    end,
    [2] = function( info,list )
        local node = info.n
        local child = list[info.index+1]
        local cn = nil
        if child then
            if child.res == false then
                return
            end
            cn = child.n
        end
        local index = 0
        for i=#node.child,1,-1 do
            if node.child[i] == cn then
                break
            else
                index = i
            end
        end
        if index == 0 then
            info.res = true
        end
        return node.child[index]
    end,
    [3] = function( info,list )
        local node = info.n
        local child = list[info.index+1]
        if child then
			info.res = true
            return
        end
        local cfg = node.cfg
        local rval = math.random(cfg.child_weight[#cfg.child_weight])
        local index = 1
        for i,v in ipairs(cfg.child_weight) do
            if rval <= v then
                index = i
                break
            end
        end
        return node.child[index]
    end
}

function next_node( info,list )
    while info do
        local node = info.n

        local cfg = node.cfg
		if cfg.node_type == 0 then
			info = list[info.index-1]
		else
			node = next_func[cfg.node_type](info,list)
			if node == nil then
				list[info.index+1] = nil
				info = list[info.index-1]
				if info == nil then
					return false
				end
			else
				info = {
					n = node,
					res = false,
					index = info.index + 1,
				}
				list[info.index] = info
				return true
			end
		end
    end
    return true
end

function run_node( list )
    local info = list[#list]
    while info do
        local node = info.n
        local cfg = node.cfg
        print("run node_type",cfg.node_type,"action:",cfg.action)
        local res = true
        if cfg.node_type == 0 then
            res = action_func[cfg.action](cfg)
			info.res = res
        end
        if res then
            if next_node(info,list) then
                info = list[#list]
            else
                return false
            end
        else
            -- 没执行完毕
            return false
        end
    end
end

local nodelist = {}

function run_tree( id,list )
    if #list == 0 then
        list[#list+1] = {
            n = treetab[id],
            res = false,
            index = 1,
        }
    end
    run_node(list)
end


-- init_tree()
-- run_tree(1,nodelist)
-- print(math.fmod(10,2))

print(os.time())
