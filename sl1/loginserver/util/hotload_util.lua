function ReloadModule( name )
	module_name = "module."..name
    local old_module = package.loaded[module_name] or {}

    package.loaded[module_name] = nil
    require (module_name)

    local new_module = package.loaded[module_name]
    for k, v in pairs(new_module) do
		if type(v) == "function" then
			old_module[k] = v
		end
    end

    package.loaded[module_name] = old_module

	local playermod = false
	for i, n in ipairs(mod_name.player_module) do
		if n == name then
			bind_player_func(old_module,name,true)
			playermod = true
			break
		end
	end

	-- 需要init 以重新绑定消息
	if playermod then
		old_module:init()
	else
		old_module:init_func()
	end
	print("hotload mod %s",name)
    return old_module
end

function HotLoadModule( )
    package.loaded["HotLoad"] = nil
    require("HotLoad")
end

function reload_file(name)
	local old = package.loaded[name] or {}

	package.loaded[name] = nil
	require(name)

	local new = package.loaded[name]
	
end

-- 热更常量
function reload_const(file,const_names)
	local oldvec = {}
	for i, n in ipairs(const_names) do
		oldvec[i] = _G[n]
	end

	package.loaded[file] = nil
	require(file)

	for i, n in ipairs(const_names) do
		local nv = _G[n]
		local old = oldvec[i]

		for k, v in pairs(nv) do
			old[k] = v
		end
		_G[n] = old
		print("hot const %s",n)
	end
end